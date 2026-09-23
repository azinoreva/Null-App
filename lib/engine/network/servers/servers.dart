//module name: servers

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../utils/server_list.dart';
import '../api_client.dart';
import '../main_server_client.dart';

/// Represents a single server entry from GET /api/servers.
class ServerInfo {
  final String serverId;
  final String serverName;
  final String serverUrl;
  final String mediaUrl;
  final String serverType;
  final int mediaSizeLimit;
  final int mediaTimer;
  final int maxPayload;
  final int capabilities;

  ServerInfo({
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

  factory ServerInfo.fromJson(Map<String, dynamic> json) {
    return ServerInfo(
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
  }

  Map<String, dynamic> toJson() {
    return {
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
      final existing = serverList.getServer(server.serverId);
      if (existing == null) {
        await serverList.addServer(
          ServerConfig(
            serverId: server.serverId,
            serverName: server.serverName,
            serverUrl: server.serverUrl,
            mediaUrl: server.mediaUrl,
            serverType: server.serverType,
            mediaSizeLimit: server.mediaSizeLimit,
            mediaTimer: server.mediaTimer,
            maxPayload: server.maxPayload,
            capabilities: server.capabilities,
          ),
        );
      } else if (existing.serverUrl != server.serverUrl) {
        await serverList.updateServer(
          server.serverId,
          server: existing.copyWith(serverUrl: server.serverUrl),
        );
      }

      await ApiClient.registerServer(
        serverId: server.serverId,
        onAuthFailure: onAuthFailureFor(server),
      );
    }

    return result.servers;
  }
}