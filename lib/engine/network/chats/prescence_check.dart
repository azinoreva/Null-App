import 'package:dio/dio.dart';

import '../api_client.dart';

/// Represents the response of POST /api/presence — a map of user_id to
/// online status (true = online, false = offline).
class PresenceResponse {
  final Map<String, bool> presence;

  PresenceResponse({required this.presence});

  factory PresenceResponse.fromJson(Map<String, dynamic> json) {
    return PresenceResponse(
      presence: json.map(
        (key, value) => MapEntry(key, value as bool),
      ),
    );
  }

  Map<String, dynamic> toJson() => presence;

  /// Convenience lookup for a single user's online status.
  /// Returns null if that user id wasn't in the response.
  bool? isOnline(String userId) => presence[userId];

  @override
  String toString() => 'PresenceResponse(presence: $presence)';
}

class PresenceService {
  final String serverId;

  Dio get _dio => ApiClient.instance(serverId);

  const PresenceService({required this.serverId});

  /// Checks online/offline presence for one or more users by id.
  ///
  /// The request body is a raw JSON array of user ids, not an object.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors.
  Future<PresenceResponse> getPresence({
    required List<String> userIds,
  }) async {
    final response = await _dio.post(
      '/api/presence',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: userIds,
    );

    return PresenceResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}