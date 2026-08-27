import 'package:dio/dio.dart';

import '../api_client.dart';
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
/// password, and saves the resulting tokens into ApiClient so the main
/// server is immediately usable via ApiClient.instance(mainServerId).
///
/// Uses MainServerClient (the shared, single-backend client) for the
/// request itself, since sign-in is unauthenticated and happens before
/// any tokens exist — but stores the result through ApiClient, since from
/// this point on the main server behaves like any other registered server
/// (its own access/refresh tokens, auto-refresh-on-401, etc.).
class SignInService {
  /// [mainServerId] is whatever id you use when calling
  /// ApiClient.registerServer(...) for the main server (e.g. 'main') —
  /// tokens are saved under that id so ApiClient.instance('main') works
  /// right after sign-in succeeds.
  Future<SignInResponse> signIn({
    required String mainServerId,
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

    await ApiClient.saveTokens(
      serverId: mainServerId,
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );

    return result;
  }
}