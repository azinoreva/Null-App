import 'package:dio/dio.dart';

import '../main_server_client.dart';

/// Represents the response of POST /api/sign-in
class SignInResponse {
  final String accessToken;
  final String refreshToken;
  final int expires;

  SignInResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expires,
  });

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expires: json['expires'] as int,
    );
  }
}

/// Signs a returning user in on the main server using phone number +
/// password, and saves the returned tokens as the main-server (login)
/// credentials used by [MainServerClient] — the only consumer of these
/// tokens. They are intentionally NOT stored in [ApiClient], whose
/// per-server token store is reserved for other servers.
class SignInService {
  Future<SignInResponse> signIn({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await MainServerClient.dio.post(
      '/api/sign-in',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'phone_number': phoneNumber,
        'password': password,
      },
    );

    final result = SignInResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    await MainServerClient.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );

    return result;
  }
}