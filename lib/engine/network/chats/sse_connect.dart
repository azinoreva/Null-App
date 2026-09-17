import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../api_client.dart';
import '../../task_queue.dart';
import '../../functions_list.dart' show incomingMessageTaskName;
import 'pull_messages.dart';

/// A single parsed SSE event, per the spec's `event` / `data` / `id` fields,
/// tagged with which server it came from.
class SseEvent {
  final String serverId;

  /// Defaults to "message" if the server didn't send an explicit `event:`
  /// line, matching the SSE spec.
  final String event;
  final String data;
  final String? id;

  SseEvent({
    required this.serverId,
    required this.event,
    required this.data,
    this.id,
  });

  /// Convenience: parses [data] as JSON. Throws if it isn't valid JSON.
  dynamic get json => jsonDecode(data);

  @override
  String toString() =>
      'SseEvent(serverId: $serverId, event: $event, id: $id, data: $data)';
}

/// One server's SSE connection: owns its own base URL, its own
/// Last-Event-ID (never shared across servers), its own reconnect/backoff
/// state, and its own byte buffer. Not used directly — managed by [SseHub].
class _SseConnection {
  final String serverId;
  final String baseUrl;
  final String path;
  final void Function(SseEvent event) _dispatch;
  final void Function(String serverId, Object error)? _onError;
  final void Function(String serverId)? _onConnected;
  final void Function(String serverId)? _onDisconnected;

  final Dio _dio;
  StreamSubscription<Uint8List>? _subscription;

  String? _lastEventId;
  bool _manuallyClosed = false;
  bool _opening = false;
  bool isConnected = false;
  bool _authFailed = false;
  Timer? _reconnectTimer;
  Duration _reconnectDelay = const Duration(seconds: 2);

  _SseConnection({
    required this.serverId,
    required this.baseUrl,
    required this.path,
    required void Function(SseEvent event) dispatch,
    void Function(String serverId, Object error)? onError,
    void Function(String serverId)? onConnected,
    void Function(String serverId)? onDisconnected,
  }) : _dispatch = dispatch,
       _onError = onError,
       _onConnected = onConnected,
       _onDisconnected = onDisconnected,
       _dio = Dio(BaseOptions(baseUrl: baseUrl));

  Future<void> connect() async {
    _manuallyClosed = false;
    _authFailed = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _open();
  }

  void disconnect() {
    _manuallyClosed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _subscription?.cancel();
    _subscription = null;
    isConnected = false;
  }

  Future<void> _open() async {
    if (_opening || _manuallyClosed) return;
    _opening = true;
    try {
      final accessToken = await ApiClient.getAccessToken(serverId);
      final headers = <String, dynamic>{
        'accept': 'text/event-stream',
        'cache-control': 'no-cache',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };
      // Only attach Last-Event-ID on reconnects for THIS server, never on
      // its first connect, and never mixed up with another server's id.
      if (_lastEventId != null) {
        headers['Last-Event-ID'] = _lastEventId;
      }

      final response = await _dio.get<ResponseBody>(
        path,
        options: Options(
          headers: headers,
          responseType: ResponseType.stream,
          receiveTimeout: Duration.zero, // long-lived connection
        ),
      );

      isConnected = true;
      _reconnectDelay = const Duration(seconds: 2);
      _onConnected?.call(serverId);

      final buffer = StringBuffer();

      _subscription = response.data!.stream.listen(
        (chunk) {
          buffer.write(utf8.decode(chunk, allowMalformed: true));
          _drainBuffer(buffer);
        },
        onError: (Object error, StackTrace st) => _handleDrop(error),
        onDone: () {
          if (!_manuallyClosed) {
            _handleDrop(StateError('SSE stream closed by server'));
          }
        },
        cancelOnError: true,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        if (_authFailed) return;
        final newToken = await ApiClient.refreshAccessToken(serverId);
        if (newToken != null && !_manuallyClosed) {
          _opening = false;
          await _open();
          return;
        }
        _authFailed = true;
        await ApiClient.handleAuthFailure(serverId);
        return;
      }
      _handleDrop(error);
    } catch (error) {
      _handleDrop(error);
    } finally {
      _opening = false;
    }
  }

  Future<void> reconnectIfNeeded() async {
    if (isConnected || _manuallyClosed || _authFailed) return;
    await _open();
  }

  void _drainBuffer(StringBuffer buffer) {
    final content = buffer.toString();
    final parts = content.split('\n\n');
    if (parts.length < 2) return; // no complete event yet

    buffer.clear();
    buffer.write(parts.last);

    for (var i = 0; i < parts.length - 1; i++) {
      _parseAndDispatch(parts[i]);
    }
  }

  void _parseAndDispatch(String rawEvent) {
    String eventName = 'message';
    final dataLines = <String>[];
    String? id;

    for (final line in rawEvent.split('\n')) {
      if (line.startsWith(':')) continue; // comment / keep-alive
      if (line.startsWith('event:')) {
        eventName = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        dataLines.add(line.substring(5).trim());
      } else if (line.startsWith('id:')) {
        id = line.substring(3).trim();
      }
    }

    if (dataLines.isEmpty) return;

    if (id != null && id.isNotEmpty) {
      _lastEventId = id; // scoped to this connection only
    }

    _dispatch(
      SseEvent(
        serverId: serverId,
        event: eventName,
        data: dataLines.join('\n'),
        id: id,
      ),
    );
  }

  void _handleDrop(Object error) {
    if (isConnected) {
      isConnected = false;
      _onDisconnected?.call(serverId);
    }
    _onError?.call(serverId, error);

    _subscription?.cancel();
    _subscription = null;

    if (_manuallyClosed || _authFailed) return;

    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectTimer != null || _manuallyClosed || _authFailed) return;

    final delay = _reconnectDelay;
    _reconnectDelay = Duration(
      seconds: (_reconnectDelay.inSeconds * 2).clamp(2, 60),
    );
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      unawaited(reconnectIfNeeded());
    });
  }
}

/// Manages SSE subscriptions across multiple independent servers.
///
/// Each server gets its own connection with its own base URL, its own
/// Last-Event-ID tracking (so one server's reconnect never sends another
/// server's event id), and its own reconnect/backoff loop. This is the
/// "control box": register handlers once, then add/remove servers as the
/// app needs to subscribe to them.
///
/// Usage:
/// ```dart
/// final hub = SseHub();
///
/// // Global handler — fires for this event name regardless of which
/// // server it came from; use event.serverId to tell them apart.
/// hub.on('message', (event) {
///   final data = event.json;
///   print('[${event.serverId}] $data');
/// });
///
/// hub.onConnected((serverId) => print('$serverId connected'));
/// hub.onDisconnected((serverId) => print('$serverId dropped'));
/// hub.onError((serverId, error) => print('$serverId error: $error'));
///
/// await hub.addServer('server-1', 'https://server1.example.com');
/// await hub.addServer('server-2', 'https://server2.example.com');
///
/// // later:
/// hub.removeServer('server-1');
/// hub.disconnectAll();
/// ```
class SseHub {
  static const String _defaultPath = '/api/subscribe';
  static const Duration keepAliveInterval = Duration(seconds: 45);

  final Map<String, _SseConnection> _connections = {};
  final Map<String, List<void Function(SseEvent event)>> _handlers = {};

  void Function(String serverId, Object error)? _onError;
  void Function(String serverId)? _onConnected;
  void Function(String serverId)? _onDisconnected;
  Future<void> Function(String serverId)? _pullMessages;
  final TaskQueue? _taskQueue;
  Timer? _keepAliveTimer;

  SseHub({
    Future<void> Function(String serverId)? pullMessages,
    TaskQueue? taskQueue,
  }) : _pullMessages = pullMessages,
       _taskQueue = taskQueue {
    if (_pullMessages == null && _taskQueue != null) {
      _pullMessages = _pullAndQueueMessages;
    }
    _keepAliveTimer = Timer.periodic(keepAliveInterval, (_) {
      unawaited(_checkConnections());
    });
  }

  /// Supplies the HTTP fallback used when a server's SSE stream is down.
  void onPullMessages(Future<void> Function(String serverId) callback) {
    _pullMessages = callback;
  }

  Future<void> _pullAndQueueMessages(String serverId) async {
    final queue = _taskQueue;
    if (queue == null) return;

    final messages = await MessagesQueueService(serverId: serverId)
        .getMessages();
    for (final message in messages) {
      final taskName = incomingMessageTaskName(message.messageType);
      await queue.queueTask(
        functionName: taskName,
        serverId: serverId,
        taskData: taskName,
        args: [
          message.senderId,
          message.messageId,
          message.logicalId,
          message.messageType,
          message.message,
        ],
      );
    }
  }

  /// Registers a handler for a given SSE `event:` name across ALL
  /// currently and subsequently added servers. Use [event.serverId] inside
  /// the handler to distinguish which server it came from.
  void on(String eventName, void Function(SseEvent event) handler) {
    _handlers.putIfAbsent(eventName, () => []).add(handler);
  }

  void off(String eventName, void Function(SseEvent event) handler) {
    _handlers[eventName]?.remove(handler);
  }

  void onError(void Function(String serverId, Object error) callback) {
    _onError = callback;
  }

  void onConnected(void Function(String serverId) callback) {
    _onConnected = callback;
  }

  void onDisconnected(void Function(String serverId) callback) {
    _onDisconnected = callback;
  }

  /// Which server ids currently have an active (connecting or connected)
  /// subscription.
  List<String> get activeServerIds => _connections.keys.toList();

  bool isConnected(String serverId) =>
      _connections[serverId]?.isConnected ?? false;

  bool isAuthFailed(String serverId) =>
      _connections[serverId]?._authFailed ?? false;

  Future<void> _checkConnections() async {
    for (final entry in _connections.entries) {
      if (entry.value.isConnected || entry.value._authFailed) continue;
      try {
        await _pullMessages?.call(entry.key);
      } catch (error) {
        _onError?.call(entry.key, error);
      }
      await entry.value.reconnectIfNeeded();
    }
  }

  /// Opens a subscription to [serverId] at [baseUrl]. If a connection for
  /// this [serverId] already exists, it's replaced (the old one is
  /// disconnected first) so re-adding a server with a new URL works as
  /// expected.
  Future<void> addServer(
    String serverId,
    String baseUrl, {
    String path = _defaultPath,
  }) async {
    // Replace any existing connection for this server id cleanly.
    _connections[serverId]?.disconnect();

    final connection = _SseConnection(
      serverId: serverId,
      baseUrl: baseUrl,
      path: path,
      dispatch: _dispatch,
      onError: _onError,
      onConnected: _onConnected,
      onDisconnected: _onDisconnected,
    );

    _connections[serverId] = connection;
    await connection.connect();
  }

  /// Closes and forgets the subscription for [serverId]. No-op if it
  /// wasn't subscribed.
  void removeServer(String serverId) {
    _connections.remove(serverId)?.disconnect();
  }

  /// Disconnects every server's subscription (handlers stay registered).
  void disconnectAll() {
    for (final connection in _connections.values) {
      connection.disconnect();
    }
  }

  /// Stops the health timer and closes every server connection.
  void dispose() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
    disconnectAll();
  }

  void _dispatch(SseEvent event) {
    if (event.event == 'message') {
      unawaited(_enqueueMessage(event));
    }
    for (final handler in _handlers[event.event] ?? const []) {
      handler(event);
    }
  }

  Future<void> _enqueueMessage(SseEvent event) async {
    final queue = _taskQueue;
    if (queue == null) return;

    final data = event.json as Map<String, dynamic>;
    await queue.queueTask(
      functionName: incomingMessageTaskName(data['messageType'] as int),
      serverId: event.serverId,
      taskData: incomingMessageTaskName(data['messageType'] as int),
      args: [
        data['sender_id'] as String,
        data['messageId'] as String,
        data['logicalId'] as String,
        data['messageType'] as int,
        data['message'] as String,
      ],
    );
  }
}
