import 'package:dio/dio.dart';

import '../api_client.dart';

/// Represents the response of POST /api/account/change-password
class ChangePasswordResponse {
  final String message;

  ChangePasswordResponse({required this.message});

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      message: json['message'] as String,
    );
  }

  @override
  String toString() => 'ChangePasswordResponse(message: $message)';
}

/// Handles account password changes. This is authenticated (Bearer token
/// present in the original curl), so — unlike registration/sign-in — it
/// goes through ApiClient.instance(serverId) as usual.
class AccountService {
  final String serverId;

  Dio get _dio => ApiClient.instance(serverId);

  const AccountService({required this.serverId});

  /// Changes the current user's password.
  ///
  /// [encryptedBlob] is the client-side re-encrypted payload (e.g. key
  /// material re-wrapped under the new password) produced before this
  /// call, not by this service — same pattern as during registration.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors.
  Future<ChangePasswordResponse> changePassword({
    required String encryptedBlob,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _dio.post(
      '/api/account/change-password',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'encrypted_blob': encryptedBlob,
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );

    return ChangePasswordResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}