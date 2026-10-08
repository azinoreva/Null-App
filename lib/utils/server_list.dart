import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../engine/network/main_server_client.dart';
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
/// Two lists live side by side in SharedPreferences:
///  * the normal list ([servers], key `server_list`) — capped at
///    [ServerListService.maxServers] entries, and the only one the websocket
///    hub connects to (`ServerConnectionService`);
///  * the extra list ([extraServers], key `extra_server_list`) — joinable
///    once the normal list is full ([canJoinExtraServers]). An extra server
///    is a full peer — directory entry, `ApiClient` registration, passport
///    exchange, HTTP calls — the only difference is it never gets a
///    websocket (`ServerConnectionService` reads the normal list), which is
///    why the updates feed polls the normal list *and* this one.
///
/// Usage:
///   final service = ServerListService();
///   await service.init();              // loads the cached lists
///   service.servers;                   // read the normal list
///   await service.addServer(newServer);
///   await service.updateServer('server_1', (s) => s.copyWith(serverName: 'New name'));
///   await service.removeServer('server_1');
class ServerListService extends ChangeNotifier {
  /// How many servers a user may hold in the normal (websocket-connected)
  /// list. Once full, further servers are joined into [extraServers].
  static const int maxServers = 8;

  static const _serverListKey = 'server_list';
  static const _extraServerListKey = 'extra_server_list';

  List<ServerConfig> _servers = [];
  List<ServerConfig> _extraServers = [];
  bool _initialized = false;

  /// Read-only view of the current normal server list.
  List<ServerConfig> get servers => List.unmodifiable(_servers);

  /// Read-only view of the extra servers list.
  List<ServerConfig> get extraServers => List.unmodifiable(_extraServers);

  /// True once the normal list holds [maxServers] servers — the point at
  /// which a user may start joining extra servers.
  bool get canJoinExtraServers => _servers.length >= maxServers;

  bool get isInitialized => _initialized;

  /// Call once (e.g. in main() or a splash/init screen) before reading
  /// or mutating the lists.
  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _servers = _readFrom(prefs, _serverListKey);
    _extraServers = _readFrom(prefs, _extraServerListKey);
    _initialized = true;
    notifyListeners();
  }

  /// The ids of the persisted normal list, in order — what contact-sharing
  /// flows read out of SharedPreferences when they need "the user's
  /// servers". A fresh instance is used, so the returned ids always reflect
  /// what is on disk right now.
  static Future<List<String>> readServerIds() async {
    final service = ServerListService();
    await service.init();
    return [for (final server in service.servers) server.serverId];
  }

  /// The server id to treat as *the* server for something that only stores
  /// one id (e.g. a row in `conversations`): the first of [servers] if the
  /// contact published any, otherwise the first id of our own normal list,
  /// otherwise the built-in main server id.
  static Future<String> primaryServerIdFor(List<String> servers) async {
    if (servers.isNotEmpty) return servers.first;
    final local = await readServerIds();
    if (local.isNotEmpty) return local.first;
    return MainServerClient.serverId;
  }

  List<ServerConfig> _readFrom(SharedPreferences prefs, String key) {
    final raw = prefs.getString(key);
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

  Future<void> _persistExtras() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _extraServerListKey,
      jsonEncode(_extraServers.map((s) => s.toJson()).toList()),
    );
  }

  /// Look up a single server by id, or null if it doesn't exist.
  ServerConfig? getServer(String serverId) {
    final match = _servers.where((s) => s.serverId == serverId);
    return match.isNotEmpty ? match.first : null;
  }

  /// Resolves [serverId]'s persisted config without keeping a long-lived
  /// instance around — handy for one-shot lookups (e.g. API client setup).
  /// Searches the normal list first, then the extra list, so a server that
  /// is only polled over HTTP still resolves to a URL.
  /// Returns null if the server isn't in either list.
  static Future<ServerConfig?> lookup(String serverId) async {
    final service = ServerListService();
    await service.init();
    final inNormal = service.getServer(serverId);
    if (inNormal != null) return inNormal;
    return service.getExtraServer(serverId);
  }

  /// Replace the entire list (e.g. after fetching an updated list from
  /// your backend) and persist it. Throws if it would exceed [maxServers].
  Future<void> setServerList(List<ServerConfig> newServers) async {
    if (newServers.length > maxServers) {
      throw ServerListException(
        'The normal server list holds at most $maxServers servers.',
      );
    }
    _servers = List.of(newServers);
    await _persist();
    notifyListeners();
  }

  /// Add a new server to the normal list. Throws if a server with the same
  /// id already exists anywhere, or when the normal list is already at
  /// [maxServers] (join an extra server instead).
  Future<void> addServer(ServerConfig server) async {
    if (_containsServer(server.serverId)) {
      throw ServerListException(
        'A server with id "${server.serverId}" already exists.',
      );
    }
    if (canJoinExtraServers) {
      throw ServerListException(
        'The normal server list is limited to $maxServers servers. '
        'Join it as an extra server instead.',
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

  // ---------------------------------------------------------------------
  // Extra servers: the second persisted list. Only joinable once the
  // normal list is full; what they're ultimately used for is defined by
  // the caller — this class just owns their persistence.
  // ---------------------------------------------------------------------

  /// Whether [serverId] already exists in either list.
  bool _containsServer(String serverId) =>
      _servers.any((s) => s.serverId == serverId) ||
      _extraServers.any((s) => s.serverId == serverId);

  /// Look up a single extra server by id, or null if it doesn't exist.
  ServerConfig? getExtraServer(String serverId) {
    final match = _extraServers.where((s) => s.serverId == serverId);
    return match.isNotEmpty ? match.first : null;
  }

  /// Replace the entire extra-server list and persist it.
  Future<void> setExtraServerList(List<ServerConfig> newServers) async {
    _extraServers = List.of(newServers);
    await _persistExtras();
    notifyListeners();
  }

  /// Add a server to the extra list. Throws when the normal list isn't at
  /// [maxServers] yet (extras unlock at the cap) or when the id already
  /// exists in either list.
  Future<void> addExtraServer(ServerConfig server) async {
    if (!canJoinExtraServers) {
      throw ServerListException(
        'Extra servers unlock once the normal list holds '
        '$maxServers servers.',
      );
    }
    if (_containsServer(server.serverId)) {
      throw ServerListException(
        'A server with id "${server.serverId}" already exists.',
      );
    }
    _extraServers = [..._extraServers, server];
    await _persistExtras();
    notifyListeners();
  }

  /// Edit an existing extra server (same contract as [updateServer]).
  Future<void> updateExtraServer(
    String serverId, {
    ServerConfig? server,
    ServerConfig Function(ServerConfig current)? update,
  }) async {
    assert(
      (server != null) ^ (update != null),
      'Pass exactly one of `server` or `update`.',
    );
    final index = _extraServers.indexWhere((s) => s.serverId == serverId);
    if (index == -1) {
      throw ServerListException('No extra server found with id "$serverId".');
    }
    final edited = server ?? update!(_extraServers[index]);
    final updatedList = List<ServerConfig>.of(_extraServers);
    updatedList[index] = edited;
    _extraServers = updatedList;
    await _persistExtras();
    notifyListeners();
  }

  /// Remove an extra server by id. No-op (returns false) if it isn't found.
  Future<bool> removeExtraServer(String serverId) async {
    final existed = _extraServers.any((s) => s.serverId == serverId);
    if (!existed) return false;
    _extraServers =
        _extraServers.where((s) => s.serverId != serverId).toList();
    await _persistExtras();
    notifyListeners();
    return true;
  }

  /// Clears both cached lists and reverts to empty lists.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_serverListKey);
    await prefs.remove(_extraServerListKey);
    _servers = [];
    _extraServers = [];
    notifyListeners();
  }
}