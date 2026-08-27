import 'package:dio/dio.dart';

import '../main_server_client.dart';

/// Represents the response of POST /api/create-new-user-preprocess
class CreateUserPreprocessResponse {
  final String phoneNumber;
  final bool otpSent;
  final String message;

  CreateUserPreprocessResponse({
    required this.phoneNumber,
    required this.otpSent,
    required this.message,
  });

  factory CreateUserPreprocessResponse.fromJson(Map<String, dynamic> json) {
    return CreateUserPreprocessResponse(
      phoneNumber: json['phone_number'] as String,
      otpSent: json['otp_sent'] as bool,
      message: json['message'] as String,
    );
  }

  @override
  String toString() =>
      'CreateUserPreprocessResponse(phoneNumber: $phoneNumber, otpSent: $otpSent)';
}

/// Represents the response of POST /api/create-new-user-postprocess
class CreateUserPostprocessResponse {
  final String userId;
  final String saltVersion;
  final String securityToken;
  final int schemaVersion;
  final String recoveryType;
  final int invitationCount;

  CreateUserPostprocessResponse({
    required this.userId,
    required this.saltVersion,
    required this.securityToken,
    required this.schemaVersion,
    required this.recoveryType,
    required this.invitationCount,
  });

  factory CreateUserPostprocessResponse.fromJson(Map<String, dynamic> json) {
    return CreateUserPostprocessResponse(
      userId: json['user_id'] as String,
      saltVersion: json['salt_version'] as String,
      securityToken: json['security_token'] as String,
      schemaVersion: json['schema_version'] as int,
      recoveryType: json['recovery_type'] as String,
      invitationCount: json['invitation_count'] as int,
    );
  }

  @override
  String toString() =>
      'CreateUserPostprocessResponse(userId: $userId, recoveryType: $recoveryType)';
}

/// Handles new-user registration against the main server — the one
/// stable, authoritative backend (unlike the dynamically discovered
/// per-user servers from /api/servers), so this does NOT go through
/// ApiClient's multi-server registry — it shares MainServerClient.dio
/// instead. Call MainServerClient.init(baseUrl: ...) once at app startup.
///
/// Both calls are unauthenticated — there's no user/token yet at this
/// point in the flow — so no auth interceptor is needed here at all.
class UserRegistrationService {
  Dio get _client => MainServerClient.dio;

  /// Step 1: submit a phone number to kick off registration. The server
  /// sends an OTP/pin to that number, valid for 10 minutes.
  Future<CreateUserPreprocessResponse> preprocess({
    required String phoneNumber,
  }) async {
    final response = await _client.post(
      '/api/create-new-user-preprocess',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'phone_number': phoneNumber,
      },
    );

    return CreateUserPreprocessResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Step 2: complete registration by submitting the OTP [pin] received
  /// from [preprocess], along with the chosen [password] and an
  /// [encryptedBlob] (client-side encrypted payload — e.g. wrapped key
  /// material — produced before this call, not by this service).
  ///
  /// On success, save [CreateUserPostprocessResponse.userId] and
  /// [CreateUserPostprocessResponse.securityToken] as needed by your auth
  /// flow (this endpoint does not return access/refresh tokens — those
  /// come from wherever your login step is, separately).
  Future<CreateUserPostprocessResponse> postprocess({
    required String phoneNumber,
    required String pin,
    required String password,
    required String encryptedBlob,
  }) async {
    final response = await _client.post(
      '/api/create-new-user-postprocess',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'phone_number': phoneNumber,
        'pin': pin,
        'password': password,
        'encrypted_blob': encryptedBlob,
      },
    );

    return CreateUserPostprocessResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}