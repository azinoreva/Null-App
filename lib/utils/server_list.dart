import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'server_model.dart';

/// Locally persisted mirror of a server, field for field identical to the
/// backend's `Server` payload (see `ServerInfo` in
/// `engine/network/servers/servers.dart`).
///
/// The JSON shape produced by [toJson] is exactly the shape consumed by the
/// API, so a config can round-trip through either without losing fields.
/// Older records persisted with the previous flat media shape are still read
/// by [fromJson] so an upgrade doesn't drop connected servers.
class ServerConfig {
  final String serverId;
  final String serverName;
  final String serverUrl;
  final ServerType serverType;
  final int maxPayload; // max text length for a post message
  final String colour;
  final String about;
  final List<String>? categories; // backend: Optional<List[Categories]]
  final bool annotated;
  final bool disabled;
  final String? location;
  final ServerMedia? media;

  const ServerConfig({
    required this.serverId,
    required this.serverName,
    required this.serverUrl,
    required this.serverType,
    required this.maxPayload,
    required this.colour,
    required this.about,
    required this.annotated,
    this.disabled = false,
    this.categories,
    this.location,
    this.media,
  });

  /// Convenience getters so callers that only care about one media limit
  /// don't have to unwrap [media].
  String? get mediaUrl => media?.url;
  int? get mediaSizeLimit => media?.size;
  int? get mediaTimer => media?.timer;

  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      serverId: json['serverId'] as String? ?? '',
      serverName: json['serverName'] as String? ?? '',
      serverUrl: json['serverUrl'] as String? ?? '',
      serverType: ServerType.tryFromJson(json['serverType']) ?? ServerType.public,
      maxPayload: (json['maxPayload'] as num?)?.toInt() ?? 5,
      colour: json['colour'] as String? ?? '',
      about: json['about'] as String? ?? '',
      annotated: json['annotated'] as bool? ?? false,
      disabled: json['disabled'] as bool? ?? false,
      location: json['location'] as String?,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      media: _mediaFromJson(json),
    );
  }

  /// Reads the nested `media` object, falling back to the flat
  /// `mediaUrl`/`mediaSizeLimit`/`mediaTimer` keys written by older versions.
  static ServerMedia? _mediaFromJson(Map<String, dynamic> json) {
    final media = ServerMedia.tryFromJson(json['media']);
    if (media != null) return media;

    final url = json['mediaUrl'];
    if (url is! String || url.isEmpty) return null;

    final size = (json['mediaSizeLimit'] as num?)?.toInt() ??
        (json['mediaSize'] as num?)?.toInt() ??
        0;
    final timer = (json['mediaTimer'] as num?)?.toInt() ?? 0;

    return ServerMedia(url: url, size: size, timer: timer, mediaType: const []);
  }

  Map<String, dynamic> toJson() => {
        'serverId': serverId,
        'serverName': serverName,
        'serverUrl': serverUrl,
        'serverType': serverType.toJson(),
        'maxPayload': maxPayload,
        'colour': colour,
        'about': about,
        'annotated': annotated,
        'disabled': disabled,
        'location': location,
        'categories': categories,
        'media': media?.toJson(),
      };

  ServerConfig copyWith({
    String? serverId,
    String? serverName,
    String? serverUrl,
    ServerType? serverType,
    int? maxPayload,
    String? colour,
    String? about,
    List<String>? categories,
    bool? annotated,
    bool? disabled,
    String? location,
    ServerMedia? media,
    bool clearLocation = false,
    bool clearCategories = false,
    bool clearMedia = false,
  }) {
    return ServerConfig(
      serverId: serverId ?? this.serverId,
      serverName: serverName ?? this.serverName,
      serverUrl: serverUrl ?? this.serverUrl,
      serverType: serverType ?? this.serverType,
      maxPayload: maxPayload ?? this.maxPayload,
      colour: colour ?? this.colour,
      about: about ?? this.about,
      annotated: annotated ?? this.annotated,
      disabled: disabled ?? this.disabled,
      location: clearLocation ? null : (location ?? this.location),
      categories: clearCategories ? null : (categories ?? this.categories),
      media: clearMedia ? null : (media ?? this.media),
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
      final servers = <ServerConfig>[];
      for (final entry in decoded) {
        try {
          servers.add(
            ServerConfig.fromJson(Map<String, dynamic>.from(entry as Map)),
          );
        } catch (_) {
          // Skip the unreadable entry rather than losing the whole list.
        }
      }
      return servers;
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