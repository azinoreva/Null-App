import 'package:dio/dio.dart';

import 'user_credentials_service.dart' show Credential;

/// Represents the response of POST /api/auth/challenge
class AuthChallenge {
  final String challengeId;
  final String challenge;
  final int expiresAt;

  AuthChallenge({
    required this.challengeId,
    required this.challenge,
    required this.expiresAt,
  });

  factory AuthChallenge.fromJson(Map<String, dynamic> json) {
    return AuthChallenge(
      challengeId: json['challenge_id'] as String,
      challenge: json['challenge'] as String,
      expiresAt: json['expires_at'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challenge_id': challengeId,
      'challenge': challenge,
      'expires_at': expiresAt,
    };
  }

  DateTime get expiresAtDate =>
      DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);

  bool get isExpired => DateTime.now().isAfter(expiresAtDate);

  @override
  String toString() =>
      'AuthChallenge(challengeId: $challengeId, expiresAt: $expiresAtDate)';
}

/// Step 1 of the per-server auth flow: exchange a signed [Credential]
/// (obtained from /api/users/credentials) for a challenge, which you then
/// sign with the user's private key and submit to a verify/response
/// endpoint to actually get that server's access + refresh tokens.
///
/// This request is unauthenticated (no Bearer header in the original curl)
/// and targets the specific server the credential was issued for — so it
/// uses a plain Dio pointed at that server's baseUrl rather than
/// ApiClient.instance(serverId), since ApiClient's interceptor would try
/// to attach a token for a server we don't have one for yet.
class AuthChallengeService {
  /// [baseUrl] is the target server's URL (e.g. ServerInfo.serverUrl),
  /// not a serverId already registered with ApiClient — this call happens
  /// before that server has any tokens.
  Future<AuthChallenge> requestChallenge({
    required String baseUrl,
    required Credential credential,
  }) async {
    final dio = Dio(BaseOptions(baseUrl: baseUrl));

    final response = await dio.post(
      '/api/auth/challenge',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'credential': credential.toJson(),
      },
    );

    return AuthChallenge.fromJson(response.data as Map<String, dynamic>);
  }
}