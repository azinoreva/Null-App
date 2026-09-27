import 'package:dio/dio.dart';

import '../api_client.dart';

/// Represents the payload sent to POST /add-servers.
class Servers {
  final List<String> serverIds;

  Servers({required this.serverIds});

  Map<String, dynamic> toJson() {
    return {
      'server_ids': serverIds,
    };
  }
}

/// Represents the response of POST /add-servers,
/// i.e. { "message": "Servers saved successfully" }
class AddServersResponse {
  final String message;

  AddServersResponse({required this.message});

  factory AddServersResponse.fromJson(Map<String, dynamic> json) {
    return AddServersResponse(
      message: json['message'] as String,
    );
  }
}

class AddServersService {
  /// Sends a list of [serverIds] to POST /add-servers.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors, where applicable.
  Future<AddServersResponse> addServers({
    required String serverId,
    required List<String> serverIds,
  }) async {
    final response = await ApiClient.instance(serverId).post(
      '/add-servers',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: Servers(serverIds: serverIds).toJson(),
    );

    return AddServersResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}