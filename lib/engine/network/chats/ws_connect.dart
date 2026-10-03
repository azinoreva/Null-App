import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/io.dart';

import '../api_client.dart';
import '../main_server_client.dart';
import '../auth_failure_handler.dart';
import '../../task_queue.dart';
import '../../functions_list.dart' show incomingMessageTaskName;
import 'message_ack.dart';
import 'pull_messages.dart' show QueuedMessage;

/// Close code the server uses for a missing or invalid bearer token.
const int _closePolicyViolation = 1008;

/// Close code the server uses when the user already holds a live socket.
const int _closeAlreadyConnected = 1009;

/// Close code the server uses when admission is rate limited or the global
/// connection cap is full.
const int _closeTryAgainLater = 1013;

/// A single frame received from a server's WebSocket, tagged with which server
/// it came from.
///
/// The server sends these shapes:
/// * `{"message": <MessageEmit>}` — an inbound message for this user. Queued
///   for local processing; the server keeps its copy until we ack.
/// * `{"type": "pong"}` — reply to a client ping (keepalive).
/// * `{"message_sent": {...}}` — a message this client pushed was accepted.
/// * `{"error": "..."}` — a frame was rejected.
class WsEvent {
  final String serverId;

  /// The raw decoded frame.
  final Map<String, dynamic> json;

  WsEvent({required this.serverId, required this.json});

  /// The frame's kind. Derived from the shape rather than a `type` field
  /// because only `pong` carries an explicit type on the wire.
  String get type {
    if (json['type'] == 'pong') return 'pong';
    if (json.containsKey('message')) return 'message';
    if (json.containsKey('message_sent')) return 'message_sent';
    if (json.containsKey('error')) return 'error';
    return 'unknown';
  }

  /// The inbound message the server pushed, if this frame carries one.
  QueuedMessage? get message {
    final value = json['message'];
    if (value is! Map<String, dynamic>) return null;
    try {
      return QueuedMessage.fromJson(value);
    } catch (_) {
      return null;
    }
  }

  /// The delivery result the server returned for a message we pushed.
  Map<String, dynamic>? get messageSent {
    final value = json['message_sent'];
    return value is Map<String, dynamic> ? value : null;
  }

  /// The server's error text, if this frame is an error.
  String? get error {
    final value = json['error'];
    return value is String ? value : null;
  }

  @override
  String toString() => 'WsEvent(serverId: $serverId, type: $type, json: $json)';
}

/// One server's WebSocket connection: owns its own base URL, its own
/// reconnect/backoff state, and its own keepalive timer. Not used directly —
/// managed by [WsHub].
class _WsConnection {
  final String serverId;
  final String baseUrl;
  final String path;

  /// Whether this is the main/authority server, decided by the caller when the
  /// server is added rather than inferred from [serverId].
  ///
  /// It matters because the two kinds of server hold entirely separate
  /// credentials: the main server's pair comes from signing in and is
  /// refreshed (and invalidated) by [MainServerClient], while every other
  /// server's pair comes from the passport/challenge handshake and is
  /// refreshed by [ApiClient] under its own id. Server ids are arbitrary, so
  /// this cannot be worked out later from the id alone.
  final bool isMainServer;

  final void Function(WsEvent event) _dispatch;
  final void Function(String serverId, Object error)? _onError;
  final void Function(String serverId)? _onConnected;
  final void Function(String serverId)? _onDisconnected;

  /// How often to send `{"type":"ping"}`. The server refreshes this user's
  /// presence lease on every frame it receives, and that lease only lives
  /// `PRESENCE_TTL_SECONDS` (20s), so this must stay comfortably below it.
  static const Duration pingInterval = Duration(seconds: 10);

  /// How close a token may get to its `exp` before the socket stops trusting
  /// it and refreshes first. Wide enough to absorb clock skew and a slow
  /// handshake, narrow enough that the token is still fresh on arrival.
  static const Duration _tokenRefreshMargin = Duration(minutes: 5);

  /// Floor on how often a rejected handshake may trigger a refresh. A refused
  /// upgrade carries no status, so without this an unreachable server would
  /// cost a `/api/refresh` call on every reconnect attempt.
  static const Duration _authRetryCooldown = Duration(seconds: 30);

  IOWebSocketChannel? _channel;
  StreamSubscription<Object?>? _subscription;
  Timer? _pingTimer;

  bool _manuallyClosed = false;
  bool _opening = false;
  bool _dropped = false;
  bool isConnected = false;
  bool _authFailed = false;
  DateTime? _lastAuthRetry;
  Timer? _reconnectTimer;
  Duration _reconnectDelay = const Duration(seconds: 2);

  _WsConnection({
    required this.serverId,
    required this.baseUrl,
    required this.path,
    required this.isMainServer,
    required void Function(WsEvent event) dispatch,
    void Function(String serverId, Object error)? onError,
    void Function(String serverId)? onConnected,
    void Function(String serverId)? onDisconnected,
  }) : _dispatch = dispatch,
       _onError = onError,
       _onConnected = onConnected,
       _onDisconnected = onDisconnected;

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
    _stopSockets();
    isConnected = false;
  }

  /// Pushes [frame] to the server. Returns false if the socket isn't open, so
  /// the caller can fall back to `POST /api/message`.
  bool send(Map<String, dynamic> frame) {
    final channel = _channel;
    if (!isConnected || channel == null) return false;
    try {
      channel.sink.add(jsonEncode(frame));
      return true;
    } catch (_) {
      _handleDrop(StateError('WebSocket send failed'));
      return false;
    }
  }

  Future<void> _open() async {
    if (_opening || _manuallyClosed) return;
    _opening = true;
    _dropped = false;
    try {
      // Two attempts: the second one exists purely to carry a freshly
      // refreshed token, because the server's rejection of a bad token
      // happens *before* `accept()` and reaches us with no close code to
      // inspect.
      for (var attempt = 0; attempt < 2 && !_manuallyClosed; attempt++) {
        final accessToken = await _freshTokenFor(serverId);
        if (accessToken == null) {
          _authFailed = true;
          _onError?.call(serverId, StateError('No access token for WebSocket'));
          await _handleAuthFailureFor(serverId);
          return;
        }

        final channel = await _handshake(accessToken);
        if (channel != null) {
          _attach(channel);
          return;
        }

        if (_manuallyClosed) return;

        // A rejected upgrade is indistinguishable from "server is
        // unreachable" here, so the only cause we can act on is a token the
        // server no longer accepts. Refresh once and retry — but not more
        // often than the cooldown, so a genuinely down server doesn't turn
        // into a refresh storm.
        final mayRetry = attempt == 0 && _authRetryReady();
        if (!mayRetry) break;

        _lastAuthRetry = DateTime.now();
        if (await _refreshFor(serverId) == null) break;
      }

      _handleDrop(StateError('WebSocket handshake rejected'));
    } finally {
      _opening = false;
    }
  }

  /// Opens the socket and completes the upgrade. Returns null when the
  /// handshake fails for any reason — a refused token, a rate limit, or the
  /// server simply not being there.
  Future<IOWebSocketChannel?> _handshake(String accessToken) async {
    final channel = IOWebSocketChannel.connect(
      _buildUri(),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      connectTimeout: const Duration(seconds: 15),
      // NOTE: no protocol-level pingInterval here. The server never reads
      // control frames, so dart:io's keepalive pings would not refresh the
      // presence lease; [pingInterval] below sends the JSON ping instead.
    );

    try {
      // Nothing may be written to the sink until the handshake completes.
      await channel.ready;
      return channel;
    } catch (_) {
      unawaited(channel.sink.close());
      return null;
    }
  }

  void _attach(IOWebSocketChannel channel) {
    if (_manuallyClosed) {
      unawaited(channel.sink.close());
      return;
    }

    _channel = channel;
    isConnected = true;
    _reconnectDelay = const Duration(seconds: 2);
    _onConnected?.call(serverId);

    _subscription = channel.stream.listen(
      (raw) => _onFrame(raw),
      onError: (Object error, StackTrace st) => _handleDrop(error),
      onDone: () => _handleDrop(
        StateError('WebSocket closed by server (code: ${channel.closeCode})'),
      ),
      cancelOnError: true,
    );

    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(pingInterval, (_) => _sendPing());
  }

  /// Returns a token safe to put on the wire, refreshing first when the stored
  /// one is missing or about to expire.
  ///
  /// Reading `exp` out of the JWT is what keeps a long-lived socket from ever
  /// presenting a dead token: without it the only signal is the server
  /// refusing the upgrade, which is indistinguishable from an outage. A token
  /// whose payload can't be read is used as-is and left to the reactive path.
  Future<String?> _freshTokenFor(String serverId) async {
    var token = await _accessTokenFor(serverId);
    final expiry = _tokenExpiry(token);

    final needsRefresh =
        token == null ||
        (expiry != null &&
            !expiry.isAfter(DateTime.now().add(_tokenRefreshMargin)));

    if (needsRefresh) {
      // Fall back to the stored token if the refresh fails but it hasn't
      // actually expired yet — better a stale-but-live socket than none.
      final refreshed = await _refreshFor(serverId);
      if (refreshed != null) token = refreshed;
    }

    return token;
  }

  /// The `exp` claim of a JWT access token, or null when it isn't a readable
  /// JWT. Only used to decide when to refresh — never to trust the token,
  /// which is the server's job on the handshake.
  static DateTime? _tokenExpiry(String? token) {
    if (token == null) return null;
    final parts = token.split('.');
    if (parts.length < 2) return null;

    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(parts[1])),
      ) as Map<String, dynamic>;
      final exp = payload['exp'];
      if (exp is! num) return null;
      return DateTime.fromMillisecondsSinceEpoch(
        exp.toInt() * 1000,
        isUtc: true,
      );
    } catch (_) {
      return null;
    }
  }

  bool _authRetryReady() =>
      _lastAuthRetry == null ||
      DateTime.now().difference(_lastAuthRetry!) >= _authRetryCooldown;

  void _sendPing() {
    final channel = _channel;
    if (!isConnected || channel == null) return;
    try {
      channel.sink.add(jsonEncode(<String, dynamic>{'type': 'ping'}));
    } catch (error) {
      _handleDrop(error);
    }
  }

  void _onFrame(Object? raw) {
    if (_manuallyClosed) return;
    if (raw is! String || raw.isEmpty) return;

    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      // A frame we can't parse is not worth tearing the socket down for.
      return;
    }
    if (decoded is! Map<String, dynamic>) return;

    _dispatch(WsEvent(serverId: serverId, json: decoded));
  }

  /// Builds the `ws(s)://.../api/messages/ws` URL from the server's base URL,
  /// preserving any path prefix the base URL carries.
  Uri _buildUri() {
    final base = Uri.parse(baseUrl);
    final scheme = (base.scheme == 'https' || base.scheme == 'wss')
        ? 'wss'
        : 'ws';

    var prefix = base.path;
    if (prefix.endsWith('/')) {
      prefix = prefix.substring(0, prefix.length - 1);
    }

    return base.replace(
      scheme: scheme,
      path: '$prefix$path',
      query: null,
      fragment: null,
    );
  }

  /// Whether a close code the server chose after accepting the socket just
  /// means "try again shortly".
  ///
  /// `1009` (already connected elsewhere) and `1013` (admission throttled / at
  /// the cap) both mean the previous socket's presence lease may still be
  /// held, so reconnecting immediately would only be rejected again. Neither
  /// is a real error state, so neither is surfaced.
  static bool _isRetryableClose(int? closeCode) =>
      closeCode == _closeAlreadyConnected || closeCode == _closeTryAgainLater;

  Future<void> reconnectIfNeeded() async {
    if (isConnected || _manuallyClosed || _authFailed) return;
    await _open();
  }

  // Credential plumbing, routed on [isMainServer] rather than on the id.

  Future<String?> _accessTokenFor(String serverId) => isMainServer
      ? MainServerClient.getAccessToken()
      : ApiClient.getAccessToken(serverId);

  Future<String?> _refreshFor(String serverId) => isMainServer
      ? MainServerClient.refreshAccessToken()
      : ApiClient.refreshAccessToken(serverId);

  /// Ends the session, but only for the main server.
  ///
  /// A peer that will not take our token is a dead link to one server, not a
  /// logged-out user — see [respondToServerAuthFailure]. Its token pair is also
  /// left alone rather than deleted, so a later attempt can still refresh it.
  Future<void> _handleAuthFailureFor(String serverId) =>
      respondToServerAuthFailure(serverId);

  void _stopSockets() {
    _pingTimer?.cancel();
    _pingTimer = null;
    unawaited(_subscription?.cancel());
    _subscription = null;
    unawaited(_channel?.sink.close());
    _channel = null;
  }

  void _handleDrop(Object error) {
    if (_manuallyClosed || _dropped) return;
    _dropped = true;

    final channel = _channel;
    final closeCode = channel?.closeCode;
    final closeReason = channel?.closeReason;

    if (isConnected) {
      isConnected = false;
      _onDisconnected?.call(serverId);
    }

    _stopSockets();

    // A rejected token is the only close worth escalating; the rest just
    // back off.
    if (closeCode == _closePolicyViolation) {
      if (_authFailed) return;
      unawaited(_recoverFromAuthFailure());
      return;
    }

    if (!_isRetryableClose(closeCode)) {
      _onError?.call(
        serverId,
        closeCode == null
            ? error
            : StateError('WebSocket closed: $closeCode $closeReason'),
      );
    }

    if (_manuallyClosed || _authFailed) return;
    _scheduleReconnect();
  }

  Future<void> _recoverFromAuthFailure() async {
    _lastAuthRetry = DateTime.now();
    final newToken = await _refreshFor(serverId);
    if (newToken != null && !_manuallyClosed) {
      _opening = false;
      await _open();
      return;
    }
    _authFailed = true;
    _onError?.call(serverId, StateError('WebSocket token rejected'));
    await _handleAuthFailureFor(serverId);
  }

  void _scheduleReconnect() {
    if (_reconnectTimer != null || _manuallyClosed || _authFailed) return;

    // 1009/1013 mean our previous lease may still be held, so back off
    // rather than reconnecting immediately and hammering the endpoint.
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

/// Manages WebSocket connections across multiple independent servers.
///
/// Each server gets its own socket with its own base URL and its own
/// reconnect/backoff loop. This is the "control box": register handlers once,
/// then add/remove servers as the app needs to talk to them.
///
/// Inbound messages arrive pushed down the socket as `{"message": ...}` and
/// are handed straight to the local task queue; there is no polling. A message
/// stays on the server until the receive task has written it to the local
/// database and [ReceivedMessageAcks] has confirmed it, so a dropped socket
/// costs a redelivery rather than a lost message.
///
/// Each socket keeps its own credential healthy without help from HTTP: it
/// reads the `exp` off the stored access token and refreshes through
/// [ApiClient] before a handshake that would present a dead one, and refreshes
/// once more if an upgrade is refused — the server rejects a bad token before
/// `accept()`, which is the only way to learn the token died. One hub per user
/// means at most one socket per server, so this costs a refresh call per server
/// whose token is near expiry, and nothing at all for the others.
///
/// Usage:
/// ```dart
/// final hub = WsHub();
///
/// // Global handler — fires for this frame type regardless of which
/// // server it came from; use event.serverId to tell them apart.
/// hub.on('message', (event) {
///   print('[${event.serverId}] inbound: ${event.message}');
/// });
///
/// hub.onConnected((serverId) => print('$serverId connected'));
/// hub.onDisconnected((serverId) => print('$serverId dropped'));
/// hub.onError((serverId, error) => print('$serverId error: $error'));
///
/// await hub.addServer('server_SHRU', 'https://one.example.com', isMainServer: false);
/// await hub.addServer('server_1fjrijjj', 'https://two.example.com', isMainServer: false);
///
/// // push a message over the socket (returns false if not connected)
/// hub.send('server-1', messageJson);
///
/// // later:
/// hub.removeServer('server-1');
/// hub.disconnectAll();
/// ```
class WsHub {
  static const String _defaultPath = '/api/messages/ws';

  final Map<String, _WsConnection> _connections = {};
  final Map<String, List<void Function(WsEvent event)>> _handlers = {};
  final Map<String, Set<String>> _handledMessageIds = {};

  /// Cap on remembered message ids per server, so a server that never acks
  /// can't grow this forever. Entries are dropped as they are acked, so in
  /// practice this only bounds the push-to-ack window.
  static const int _maxTrackedMessageIds = 2000;

  void Function(String serverId, Object error)? _onError;
  void Function(String serverId)? _onConnected;
  void Function(String serverId)? _onDisconnected;
  final TaskQueue? _taskQueue;
  Timer? _watchdogTimer;

  WsHub({TaskQueue? taskQueue}) : _taskQueue = taskQueue {
    // Once the server confirms a message, it won't be replayed on reconnect,
    // so the hub no longer needs to suppress it.
    ReceivedMessageAcks.instance.onAcked = forgetMessage;

    // Nothing pushes on a dead socket, so this watchdog only exists to bring
    // dropped sockets back; it deliberately does no message fetching.
    _watchdogTimer = Timer.periodic(_watchdogInterval, (_) {
      unawaited(_reconnectAll());
    });
  }

  /// How often to check for dropped sockets.
  static const Duration _watchdogInterval = Duration(seconds: 10);

  /// Queues [message] for local processing under [serverId].
  ///
  /// Returns false if this id was already handed to the task queue, which
  /// happens legitimately: the server replays its unacknowledged queue when a
  /// socket reconnects, so a message that arrived but hasn't been persisted
  /// yet can be sent twice.
  bool handleMessage(String serverId, QueuedMessage message) {
    if (_taskQueue == null) return false;

    final seen = _handledMessageIds.putIfAbsent(serverId, () => <String>{});
    if (!seen.add(message.messageId)) return false;
    while (seen.length > _maxTrackedMessageIds) {
      seen.remove(seen.first);
    }

    unawaited(
      _enqueue(serverId, incomingMessageTaskName(message.messageType), message),
    );
    return true;
  }

  Future<void> _enqueue(
    String serverId,
    String taskName,
    QueuedMessage message,
  ) async {
    try {
      await _taskQueue!.queueTask(
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
    } catch (error) {
      // Nothing was queued, so let the server replay it on reconnect.
      forgetMessage(serverId, message.messageId);
      _onError?.call(serverId, error);
    }
  }

  /// Stops suppressing [messageId] for [serverId].
  void forgetMessage(String serverId, String messageId) {
    _handledMessageIds[serverId]?.remove(messageId);
  }

  /// Registers a handler for a given frame type across ALL currently and
  /// subsequently added servers. Use [WsEvent.serverId] inside the handler to
  /// distinguish which server it came from.
  void on(String type, void Function(WsEvent event) handler) {
    _handlers.putIfAbsent(type, () => []).add(handler);
  }

  void off(String type, void Function(WsEvent event) handler) {
    _handlers[type]?.remove(handler);
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
  /// socket.
  List<String> get activeServerIds => _connections.keys.toList();

  bool isConnected(String serverId) =>
      _connections[serverId]?.isConnected ?? false;

  bool isAuthFailed(String serverId) =>
      _connections[serverId]?._authFailed ?? false;

  /// Pushes [frame] to [serverId] over its socket. Returns false when that
  /// server isn't connected, so the caller can fall back to the HTTP route.
  bool send(String serverId, Map<String, dynamic> frame) =>
      _connections[serverId]?.send(frame) ?? false;

  /// Brings back any socket that is down. Inbound messages are not fetched
  /// here: the server replays its unacknowledged queue on connect.
  ///
  /// Connections are recovered concurrently. A user can be on up to 8 servers
  /// at once, and one handshake can burn its full 15s connect timeout, so
  /// awaiting them in turn would let a single dead server hold the other seven
  /// down for minutes.
  Future<void> _reconnectAll() async {
    await Future.wait(
      _connections.values.map((connection) async {
        try {
          await connection.reconnectIfNeeded();
        } catch (error) {
          _onError?.call(connection.serverId, error);
        }
      }),
    );
  }

  /// Opens a socket to [serverId] at [baseUrl]. If a connection for this
  /// [serverId] already exists, it's replaced (the old one is disconnected
  /// first) so re-adding a server with a new URL works as expected.
  ///
  /// [isMainServer] must say whether this is the main/authority server. It
  /// decides both which token pair the socket authenticates with and whether a
  /// refusal from this server may sign the user out, so it is passed in
  /// explicitly instead of being guessed from [serverId] — server ids are
  /// arbitrary and only the caller knows which one it added.
  Future<void> addServer(
    String serverId,
    String baseUrl, {
    required bool isMainServer,
    String path = _defaultPath,
  }) async {
    // Replace any existing connection for this server id cleanly.
    _connections[serverId]?.disconnect();

    final connection = _WsConnection(
      serverId: serverId,
      baseUrl: baseUrl,
      path: path,
      isMainServer: isMainServer,
      dispatch: _dispatch,
      onError: _onError,
      onConnected: _onConnected,
      onDisconnected: _onDisconnected,
    );

    _connections[serverId] = connection;
    await connection.connect();
  }

  /// Closes and forgets the socket for [serverId]. No-op if it wasn't open.
  void removeServer(String serverId) {
    _connections.remove(serverId)?.disconnect();
    _handledMessageIds.remove(serverId);
    ReceivedMessageAcks.instance.forgetServer(serverId);
  }

  /// Disconnects every server's socket (handlers stay registered).
  void disconnectAll() {
    for (final connection in _connections.values) {
      connection.disconnect();
    }
  }

  /// Stops the watchdog and closes every server connection.
  void dispose() {
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
    if (ReceivedMessageAcks.instance.onAcked == forgetMessage) {
      ReceivedMessageAcks.instance.onAcked = null;
    }
    disconnectAll();
  }

  void _dispatch(WsEvent event) {
    if (event.type == 'message') {
      final message = event.message;
      if (message != null) {
        // Hand it to the local pipeline; acknowledgement happens later, once
        // the receive task has written it to the database.
        handleMessage(event.serverId, message);
      }
    }

    for (final handler in _handlers[event.type] ?? const []) {
      handler(event);
    }
  }
}
