import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model matching your server JSON structure.
class ServerConfig {
  final String serverId;
  final String serverName;
  final String serverUrl;
  final String mediaUrl;
  final String serverType;
  final int mediaSizeLimit;
  final int mediaTimer;
  final int maxPayload;
  final int capabilities;

  const ServerConfig({
    required this.serverId,
    required this.serverName,
    required this.serverUrl,
    required this.mediaUrl,
    required this.serverType,
    required this.mediaSizeLimit,
    required this.mediaTimer,
    required this.maxPayload,
    required this.capabilities,
  });

  factory ServerConfig.fromJson(Map<String, dynamic> json) => ServerConfig(
        serverId: json['serverId'] as String,
        serverName: json['serverName'] as String,
        serverUrl: json['serverUrl'] as String,
        mediaUrl: json['mediaUrl'] as String,
        serverType: json['serverType'] as String,
        mediaSizeLimit: json['mediaSizeLimit'] as int,
        mediaTimer: json['mediaTimer'] as int,
        maxPayload: json['maxPayload'] as int,
        capabilities: json['capabilities'] as int,
      );

  Map<String, dynamic> toJson() => {
        'serverId': serverId,
        'serverName': serverName,
        'serverUrl': serverUrl,
        'mediaUrl': mediaUrl,
        'serverType': serverType,
        'mediaSizeLimit': mediaSizeLimit,
        'mediaTimer': mediaTimer,
        'maxPayload': maxPayload,
        'capabilities': capabilities,
      };

  ServerConfig copyWith({
    String? serverId,
    String? serverName,
    String? serverUrl,
    String? mediaUrl,
    String? serverType,
    int? mediaSizeLimit,
    int? mediaTimer,
    int? maxPayload,
    int? capabilities,
  }) {
    return ServerConfig(
      serverId: serverId ?? this.serverId,
      serverName: serverName ?? this.serverName,
      serverUrl: serverUrl ?? this.serverUrl,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      serverType: serverType ?? this.serverType,
      mediaSizeLimit: mediaSizeLimit ?? this.mediaSizeLimit,
      mediaTimer: mediaTimer ?? this.mediaTimer,
      maxPayload: maxPayload ?? this.maxPayload,
      capabilities: capabilities ?? this.capabilities,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServerConfig && other.serverId == serverId);

  @override
  int get hashCode => serverId.hashCode;

  @override
  String toString() => 'ServerConfig($serverId, $serverName)';
}

/// Thrown when an operation references a serverId that isn't in the list,
/// or tries to add one that already exists.
class ServerListException implements Exception {
  final String message;
  ServerListException(this.message);
  @override
  String toString() => 'ServerListException: $message';
}

/// CRUD manager for the server list, persisted to SharedPreferences as JSON.
///
/// Usage:
///   final service = ServerListService();
///   await service.init();              // loads the cached list
///   service.servers;                   // read the current list
///   await service.addServer(newServer);
///   await service.updateServer('server_1', (s) => s.copyWith(serverName: 'New name'));
///   await service.removeServer('server_1');
class ServerListService extends ChangeNotifier {
  static const _serverListKey = 'server_list';

  List<ServerConfig> _servers = [];
  bool _initialized = false;

  /// Read-only view of the current server list.
  List<ServerConfig> get servers => List.unmodifiable(_servers);
  bool get isInitialized => _initialized;

  /// Call once (e.g. in main() or a splash/init screen) before reading
  /// or mutating the list.
  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _servers = _readFrom(prefs);
    _initialized = true;
    notifyListeners();
  }

  List<ServerConfig> _readFrom(SharedPreferences prefs) {
    final raw = prefs.getString(_serverListKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => ServerConfig.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupt cache: start empty rather than crash.
      return [];
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _serverListKey,
      jsonEncode(_servers.map((s) => s.toJson()).toList()),
    );
  }

  /// Look up a single server by id, or null if it doesn't exist.
  ServerConfig? getServer(String serverId) {
    final match = _servers.where((s) => s.serverId == serverId);
    return match.isNotEmpty ? match.first : null;
  }

  /// Resolves [serverId]'s persisted config without keeping a long-lived
  /// instance around — handy for one-shot lookups (e.g. API client setup).
  /// Returns null if the server isn't in the list.
  static Future<ServerConfig?> lookup(String serverId) async {
    final service = ServerListService();
    await service.init();
    return service.getServer(serverId);
  }

  /// Replace the entire list (e.g. after fetching an updated list from
  /// your backend) and persist it.
  Future<void> setServerList(List<ServerConfig> newServers) async {
    _servers = List.of(newServers);
    await _persist();
    notifyListeners();
  }

  /// Add a new server. Throws if a server with the same id already exists.
  Future<void> addServer(ServerConfig server) async {
    if (_servers.any((s) => s.serverId == server.serverId)) {
      throw ServerListException(
        'A server with id "${server.serverId}" already exists.',
      );
    }
    _servers = [..._servers, server];
    await _persist();
    notifyListeners();
  }

  /// Edit an existing server. Pass either a full replacement [server], or
  /// an [update] callback that receives the current config and returns the
  /// edited one (handy with copyWith). Exactly one of the two must be given.
  Future<void> updateServer(
    String serverId, {
    ServerConfig? server,
    ServerConfig Function(ServerConfig current)? update,
  }) async {
    assert(
      (server != null) ^ (update != null),
      'Pass exactly one of `server` or `update`.',
    );
    final index = _servers.indexWhere((s) => s.serverId == serverId);
    if (index == -1) {
      throw ServerListException('No server found with id "$serverId".');
    }
    final edited = server ?? update!(_servers[index]);
    final updatedList = List<ServerConfig>.of(_servers);
    updatedList[index] = edited;
    _servers = updatedList;
    await _persist();
    notifyListeners();
  }

  /// Remove a server by id. No-op (returns false) if it isn't found.
  Future<bool> removeServer(String serverId) async {
    final existed = _servers.any((s) => s.serverId == serverId);
    if (!existed) return false;
    _servers = _servers.where((s) => s.serverId != serverId).toList();
    await _persist();
    notifyListeners();
    return true;
  }

  /// Clears the cached list and reverts to an empty list.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_serverListKey);
    _servers = [];
    notifyListeners();
  }
}