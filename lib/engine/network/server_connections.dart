import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../utils/server_list.dart';
import '../task_queue.dart';
import 'api_client.dart';
import 'auth_failure_handler.dart';
import 'chats/ws_connect.dart';

/// Live link state for one server's WebSocket connection.
enum WsStatus {
  /// The connection is being (re)opened.
  connecting,

  /// The socket is open and able to push messages.
  connected,

  /// The socket dropped; the watchdog will bring it back.
  reconnecting,

  /// The server is not currently watched.
  idle,
}

/// Ties the persisted [ServerListService] to the app's live server sockets.
///
/// On [start] it loads the server list, registers every server with
/// [ApiClient], and opens a [WsHub] socket for each one. Afterwards it
/// keeps in step with the list (servers added later get connected, removed
/// ones get dropped) and runs a watchdog so no server's socket is ever left
/// down for long — the underlying hub reconnects each connection with its own
/// exponential backoff, and [statuses] lets the UI reflect all of it.
///
/// Usage:
/// ```dart
/// final service = ServerConnectionService(
///   serverList: ServerListService(),
///   taskQueue: taskQueue,
/// );
/// await service.start(); // load list + open every server's socket
/// service.statuses;       // Map<serverId, WsStatus>
/// ```
class ServerConnectionService extends ChangeNotifier {
  ServerConnectionService({
    required this._serverList,
    required this._taskQueue,
  });

  /// How often the watchdog re-checks the list and re-opens anything that
  /// slipped through (the hub also reconnects internally on its own cadence).
  static const Duration _watchdogInterval = Duration(seconds: 10);

  final ServerListService _serverList;
  final TaskQueue _taskQueue;

  WsHub? _hub;
  bool _started = false;
  Timer? _watchdog;

  final Map<String, WsStatus> _statuses = {};

  /// Live connection status per server id.
  Map<String, WsStatus> get statuses => Map.unmodifiable(_statuses);

  /// The underlying hub (null until [start]); useful for pushing messages
  /// over a server's socket, e.g. `service.hub?.send(serverId, message)`.
  WsHub? get hub => _hub;

  /// Loads the server list and opens a socket for every server in it, then
  /// keeps them alive. Safe to call once.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    await _serverList.init();

    final hub = WsHub(taskQueue: _taskQueue);
    _hub = hub;

    hub.onConnected((serverId) {
      _statuses[serverId] = WsStatus.connected;
      notifyListeners();
    });
    hub.onDisconnected((serverId) {
      _statuses[serverId] = WsStatus.reconnecting;
      notifyListeners();
    });
    hub.onError((serverId, error) {
      _statuses[serverId] = WsStatus.reconnecting;
      notifyListeners();
    });

    // Keep in step with the list: adding/updating/removing a server while the
    // app runs is reflected in the subscriptions.
    _serverList.addListener(_syncToServerList);

    await _syncToServerList();

    _watchdog = Timer.periodic(_watchdogInterval, (_) {
      unawaited(_syncToServerList());
    });
  }

  bool isConnected(String serverId) => _hub?.isConnected(serverId) ?? false;

  /// Explicitly re-opens one server's subscription (e.g. a manual retry in
  /// the UI). No-op if the server isn't in the list.
  Future<void> reconnect(String serverId) async {
    final hub = _hub;
    if (hub == null) return;
    if (_serverList.getServer(serverId) == null) return;
    hub.removeServer(serverId);
    _statuses.remove(serverId);
    await _syncToServerList();
  }

  Future<void> _syncToServerList() async {
    final hub = _hub;
    if (hub == null || !_started) return;

    // Only servers with a real URL are connectable.
    final wanted = <String, ServerConfig>{
      for (final server in _serverList.servers)
        if (server.serverUrl.trim().isNotEmpty) server.serverId: server,
    };
    final wantedIds = wanted.keys.toSet();

    // Forget servers that were removed from the list.
    for (final serverId in _statuses.keys.toList()) {
      if (!wantedIds.contains(serverId)) {
        hub.removeServer(serverId);
        _statuses.remove(serverId);
      }
    }

    // Connect servers that aren't already being managed by the hub, so the
    // watchdog never churns an existing (or mid-reconnect) subscription.
    for (final server in wanted.values) {
      if (hub.activeServerIds.contains(server.serverId)) continue;

      // Server ids are arbitrary, so this is the one place that knows which
      // of them is the main server. It decides two things downstream: which
      // token pair the socket uses, and whether a refusal here may sign the
      // user out (only the main server's may).
      final isMainServer = isMainServerId(server.serverId);

      if (!ApiClient.isRegistered(server.serverId)) {
        await ApiClient.registerServer(
          serverId: server.serverId,
          onAuthFailure: serverAuthFailureCallbackFor(server.serverId),
        );
      }

      _statuses[server.serverId] = WsStatus.connecting;
      notifyListeners();

      await hub.addServer(
        server.serverId,
        server.serverUrl,
        isMainServer: isMainServer,
      );
    }
  }

  /// Stops the watchdog and tears down every subscription.
  void stop() {
    _watchdog?.cancel();
    _watchdog = null;
    _hub?.dispose();
    _hub = null;
    _started = false;
    _serverList.removeListener(_syncToServerList);
    _statuses.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
