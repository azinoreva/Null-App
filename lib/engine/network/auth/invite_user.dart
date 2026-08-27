import 'package:dio/dio.dart';

import '../api_client.dart';

/// Represents the response of POST /api/invite-user
class InviteUserResponse {
  final String invitationToken;
  final String inviterUserId;
  final int expiration;

  InviteUserResponse({
    required this.invitationToken,
    required this.inviterUserId,
    required this.expiration,
  });

  factory InviteUserResponse.fromJson(Map<String, dynamic> json) {
    return InviteUserResponse(
      invitationToken: json['invitation_token'] as String,
      inviterUserId: json['inviter_user_id'] as String,
      expiration: json['expiration'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invitation_token': invitationToken,
      'inviter_user_id': inviterUserId,
      'expiration': expiration,
    };
  }

  /// `expiration` here is a duration in seconds (e.g. 1200 = 20 minutes),
  /// not a timestamp, so this computes the actual expiry moment based on
  /// when the response was received.
  DateTime get expiresAt =>
      DateTime.now().add(Duration(seconds: expiration));

  @override
  String toString() =>
      'InviteUserResponse(inviterUserId: $inviterUserId, expiration: ${expiration}s)';
}

class InviteUserService {
  final String serverId;

  Dio get _dio => ApiClient.instance(serverId);

  const InviteUserService({required this.serverId});

  /// Generates a new invitation token for the current user to share.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors.
  Future<InviteUserResponse> inviteUser() async {
    final response = await _dio.post(
      '/api/invite-user',
      options: Options(
        headers: {
          'accept': 'application/json',
        },
      ),
    );

    return InviteUserResponse.fromJson(response.data as Map<String, dynamic>);
  }
}