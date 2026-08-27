import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../api_client.dart';

/// Represents a single server entry from GET /api/servers.
class ServerInfo {
  final String serverId;
  final String serverName;
  final String serverUrl;
  final String mediaUrl;
  final int mediaSizeLimit;
  final int mediaTimer;
  final int maxPayload;
  final int capabilities;

  ServerInfo({
    required this.serverId,
    required this.serverName,
    required this.serverUrl,
    required this.mediaUrl,
    required this.mediaSizeLimit,
    required this.mediaTimer,
    required this.maxPayload,
    required this.capabilities,
  });

  factory ServerInfo.fromJson(Map<String, dynamic> json) {
    return ServerInfo(
      serverId: json['serverId'] as String,
      serverName: json['serverName'] as String,
      serverUrl: json['serverUrl'] as String,
      mediaUrl: json['mediaUrl'] as String,
      mediaSizeLimit: json['mediaSizeLimit'] as int,
      mediaTimer: json['mediaTimer'] as int,
      maxPayload: json['maxPayload'] as int,
      capabilities: json['capabilities'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serverId': serverId,
      'serverName': serverName,
      'serverUrl': serverUrl,
      'mediaUrl': mediaUrl,
      'mediaSizeLimit': mediaSizeLimit,
      'mediaTimer': mediaTimer,
      'maxPayload': maxPayload,
      'capabilities': capabilities,
    };
  }

  @override
  String toString() =>
      'ServerInfo(serverId: $serverId, serverName: $serverName, serverUrl: $serverUrl)';
}

/// Represents the response of GET /api/servers
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
/// This call itself has to go to a server ApiClient already knows about —
/// typically your main/bootstrap server (the one the user originally
/// logged into). Register that one with ApiClient.registerServer(...)
/// first, then call this with its serverId.
class ServerDirectoryService {
  final String _mainServerId;

  ServerDirectoryService({required String mainServerId})
      : _mainServerId = mainServerId;

  Future<ServerListResponse> getServers() async {
    final dio = ApiClient.instance(_mainServerId);

    final response = await dio.get(
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
  /// step, using each server's own [ServerInfo.serverUrl] as its baseUrl.
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

    for (final server in result.servers) {
      ApiClient.registerServer(
        serverId: server.serverId,
        baseUrl: server.serverUrl,
        onAuthFailure: onAuthFailureFor(server),
      );
    }

    return result.servers;
  }
}