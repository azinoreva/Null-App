//module name: servers

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../utils/server_list.dart';
import '../../../utils/server_model.dart';
import '../api_client.dart';
import '../main_server_client.dart';

// The server value types live in `utils/server_model.dart` so the API layer
// and the local persistence layer can't drift apart. Re-exported here
// because this is where callers already expect to find them.
export '../../../utils/server_model.dart'
    show ServerType, MediaType, ServerMedia;

/// Mirrors backend `Server`.
class ServerInfo {
  final String serverId;
  final String serverName;
  final String serverUrl;
  final ServerType serverType;
  final int maxPayload;          // max text length for a post message
  final String colour;
  final String about;
  final List<String>? categories; // backend: Optional[List[Categories]]
  final bool annotated;
  final bool disabled;
  final String? location;
  final ServerMedia? media;

  ServerInfo({
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

  // Convenience getters so existing code that used flat fields still works.
  String? get mediaUrl => media?.url;
  int? get mediaSizeLimit => media?.size;
  int? get mediaTimer => media?.timer;

  factory ServerInfo.fromJson(Map<String, dynamic> json) {
    return ServerInfo(
      serverId: json['serverId'] as String,
      serverName: json['serverName'] as String,
      serverUrl: json['serverUrl'] as String,
      serverType: ServerType.fromJson(json['serverType'] as String),
      maxPayload: json['maxPayload'] as int,
      colour: json['colour'] as String,
      about: json['about'] as String,
      annotated: json['annotated'] as bool,
      disabled: json['disabled'] as bool? ?? false,
      location: json['location'] as String?,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      media: json['media'] == null
          ? null
          : ServerMedia.fromJson(json['media'] as Map<String, dynamic>),
    );
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

  /// The persistable form of this server. Both models carry the same
  /// fields, so nothing is dropped on the way into the local list.
  ServerConfig toConfig() => ServerConfig(
        serverId: serverId,
        serverName: serverName,
        serverUrl: serverUrl,
        serverType: serverType,
        maxPayload: maxPayload,
        colour: colour,
        about: about,
        annotated: annotated,
        disabled: disabled,
        location: location,
        categories: categories,
        media: media,
      );

  @override
  String toString() =>
      'ServerInfo(serverId: $serverId, serverName: $serverName, serverUrl: $serverUrl)';
}




class ServerListResponse {
  final List<ServerInfo> servers;

  ServerListResponse({required this.servers});

  factory ServerListResponse.fromJson(Map<String, dynamic> json) {
    return ServerListResponse(
      servers: (json['servers'] as List<dynamic>)
          .map((item) => ServerInfo.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Fetches the directory of servers the user has access to.
///
/// Directory requests always go to the env-configured main server through
/// [MainServerClient].
class ServerDirectoryService {
  ServerDirectoryService();

  Future<ServerListResponse> getServers() async {
    final response = await MainServerClient.dio.get(
      '/api/servers',
      options: Options(
        headers: {
          'accept': 'application/json',
        },
      ),
    );

    return ServerListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetches the server list and registers each one with ApiClient in one
  /// step. Every discovered server is also persisted into the app's server
  /// list ([ServerListService.lookup] is what ApiClient reads URLs from), so
  /// a re-registration later can resolve `serverUrl` on its own.
  ///
  /// Note: registering a server here only creates its Dio client — it does
  /// NOT by itself give that server valid tokens. You still need to obtain
  /// and save an access/refresh token pair for each new server (e.g. via
  /// your credentials exchange flow) before requests to it will succeed;
  /// until then, its requests will 401 and immediately hit [onAuthFailure].
  ///
  /// Returns the list of servers that were (re-)registered.
  Future<List<ServerInfo>> discoverAndRegisterServers({
    required VoidCallback Function(ServerInfo server) onAuthFailureFor,
  }) async {
    final result = await getServers();
    final serverList = ServerListService();
    await serverList.init();

    for (final server in result.servers) {
      // The directory is the single source of truth: drop any stale copy
      // first so every field (not just the URL) is refreshed from the
      // response, then persist the current one.
      if (serverList.getServer(server.serverId) != null) {
        await serverList.removeServer(server.serverId);
      }
      await serverList.addServer(server.toConfig());

      await ApiClient.registerServer(
        serverId: server.serverId,
        onAuthFailure: onAuthFailureFor(server),
      );
    }

    return result.servers;
  }
}


