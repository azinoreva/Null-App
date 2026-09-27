import 'package:dio/dio.dart';

import '../api_client.dart';

/// Represents the payload sent to POST /exchange-servers.
class UserIdRequest {
  final String userId;

  UserIdRequest({required this.userId});

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
    };
  }
}

/// Represents the response, i.e. { "server_ids": ["...", "..."] }
class ServersResponse {
  final List<String> serverIds;

  ServersResponse({required this.serverIds});

  factory ServersResponse.fromJson(Map<String, dynamic> json) {
    return ServersResponse(
      serverIds: (json['server_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
}

class ExchangeServersService {
  /// Requests the list of server ids associated with [userId].
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors, where applicable.
  Future<ServersResponse> exchangeServers({
    required String serverId,
    required String userId,
  }) async {
    final response = await ApiClient.instance(serverId).post(
      '/exchange-servers',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: UserIdRequest(userId: userId).toJson(),
    );

    return ServersResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}