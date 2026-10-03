import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../api_client.dart';
import '../server_error_exception.dart';

/// Decodes unpadded base64url the same way the backend's `_b64u_decode`
/// does (`base64.urlsafe_b64decode(value + "=" * (-len(value) % 4))`).
///
/// Dart's [base64Url] codec is lenient about trailing padding, but adding it
/// explicitly keeps this symmetric with [encodeBase64Url] and avoids relying
/// on that leniency.
Uint8List decodeBase64Url(String value) {
  final padding = (4 - value.length % 4) % 4;
  return base64Url.decode(value.padRight(value.length + padding, '='));
}

/// Encodes [bytes] as base64url *without* padding — the wire format every
/// field on this flow uses (`challenge`, `answer`, `challenge_id`).
String encodeBase64Url(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

/// Thrown when the peer server refuses the passport or the challenge answer
/// (401/403/410 from `/api/auth/server-entry` or `/api/auth/server-challenge`).
///
/// This is deliberately *not* routed through ApiClient's auth-failure
/// handling: these two calls carry no bearer token — the passport and the
/// signature are the credentials — so a rejection means "this passport is no
/// good", not "this session expired, log the user out".
class PassportRejectedException implements Exception {
  final String message;
  final int? statusCode;

  const PassportRejectedException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Request body for POST /api/auth/server-entry.
///
/// Field names match the server's JSON keys: `passport` ->
/// `passport_token`, `userId` stays `userId`, and `invite_pin` is optional
/// (required by private servers, ignored by public ones).
class Passport {
  final String passport;
  final String userId;
  final String? invitePin;

  Passport({required this.passport, required this.userId, this.invitePin});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'passport_token': passport,
      'userId': userId,
    };
    if (invitePin != null) {
      json['invite_pin'] = invitePin;
    }
    return json;
  }
}

/// Request body for POST /api/auth/server-challenge.
class ChallengeAnswer {
  final String challengeId;
  final String answer;

  ChallengeAnswer({required this.challengeId, required this.answer});

  Map<String, dynamic> toJson() {
    return {'challenge_id': challengeId, 'answer': answer};
  }
}

/// Response of POST /api/auth/server-entry:
/// `{ "challenge_id": ..., "challenge": ..., "expires_in": 60 }`.
///
/// [challenge] is base64url of the raw random bytes the client must sign;
/// [challengeBytes] is what actually gets fed to Ed25519.
class ChallengeResponse {
  final String challengeId;
  final String challenge;
  final int expiresIn;

  /// When this challenge was received, so [expiresAt]/[isExpired] mean
  /// something — the server's own TTL is only meaningful relative to receipt.
  final DateTime receivedAt;

  ChallengeResponse({
    required this.challengeId,
    required this.challenge,
    required this.expiresIn,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  factory ChallengeResponse.fromJson(
    Map<String, dynamic> json, {
    DateTime? receivedAt,
  }) {
    return ChallengeResponse(
      challengeId: json['challenge_id'] as String,
      challenge: json['challenge'] as String,
      expiresIn: json['expires_in'] as int,
      receivedAt: receivedAt,
    );
  }

  /// The raw challenge bytes to sign.
  Uint8List get challengeBytes => decodeBase64Url(challenge);

  Duration get lifetime => Duration(seconds: expiresIn);

  DateTime get expiresAt => receivedAt.add(lifetime);

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  String toString() =>
      'ChallengeResponse(challengeId: $challengeId, expiresIn: $expiresIn)';
}

/// Response of POST /api/auth/server-challenge (and of the legacy single-step
/// sign-in): the per-server token pair.
class SignInReturn {
  final String accessToken;
  final String refreshToken;
  final int expires;

  SignInReturn({
    required this.accessToken,
    required this.refreshToken,
    required this.expires,
  });

  factory SignInReturn.fromJson(Map<String, dynamic> json) {
    return SignInReturn(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expires: json['expires'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires': expires,
    };
  }

  DateTime get expiresAtDate =>
      DateTime.fromMillisecondsSinceEpoch(expires * 1000);

  bool get isExpired => DateTime.now().isAfter(expiresAtDate);

  @override
  String toString() => 'SignInReturn(expiresAt: $expiresAtDate)';
}

/// The two-step passport exchange a client performs to join a server:
///
/// 1. `POST /api/auth/server-entry` with the passport → the server verifies it
///    (signed by the main server's key, unexpired, matching `userId`) and
///    answers with a random challenge.
/// 2. The client signs those challenge bytes with the Ed25519 identity key
///    registered at signup and calls `POST /api/auth/server-challenge` with
///    the signature, proving it still holds the private half of the key the
///    server has on file. Only then does the server mint a token pair.
///
/// Both calls are unauthenticated (`skipAuth`), so they never carry a bearer
/// token and never trigger the refresh/logout interceptor chain.
class ServerEntryService {
  static const _skipAuth = {'skipAuth': true};

  /// Step 1: hand over the passport and receive the challenge to sign.
  Future<ChallengeResponse> serverEntry({
    required String serverId,
    required String passport,
    required String userId,
    String? invitePin,
  }) async {
    final response = await _post(
      serverId: serverId,
      path: '/api/auth/server-entry',
      data: Passport(
        passport: passport,
        userId: userId,
        invitePin: invitePin,
      ).toJson(),
      // A peer on the unpatched Null-KIB lets verify_passport's ValueError
      // escape, so a bad or expired passport comes back as a 500 rather than
      // the documented 403. Treat it as a rejection here so the caller can
      // re-mint instead of reporting an opaque server error.
      serverErrorIsRejection: true,
    );

    return ChallengeResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Step 2: return the Ed25519 [signature] over the challenge bytes and
  /// receive the per-server token pair.
  Future<SignInReturn> serverChallenge({
    required String serverId,
    required String challengeId,
    required Uint8List signature,
  }) async {
    final response = await _post(
      serverId: serverId,
      path: '/api/auth/server-challenge',
      data: ChallengeAnswer(
        challengeId: challengeId,
        answer: encodeBase64Url(signature),
      ).toJson(),
    );

    return SignInReturn.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Response<dynamic>> _post({
    required String serverId,
    required String path,
    required Map<String, dynamic> data,
    bool serverErrorIsRejection = false,
  }) async {
    try {
      return await ApiClient.instance(serverId).post(
        path,
        options: Options(
          extra: _skipAuth,
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        data: data,
      );
    } on DioException catch (e) {
      // 401 reaches us as a raw DioException (see the skipAuth opt-out in
      // ApiClient's error interceptor); every other 4xx is rethrown by that
      // same interceptor as a ServerErrorException.
      final rejection = _asRejection(
        e.response?.statusCode,
        _detailFromBody(e.response?.data),
        serverErrorIsRejection: serverErrorIsRejection,
      );
      if (rejection != null) throw rejection;
      rethrow;
    } on ServerErrorException catch (e) {
      final rejection = _asRejection(
        e.statusCode,
        e.message,
        serverErrorIsRejection: serverErrorIsRejection,
      );
      throw rejection ?? e;
    }
  }

  /// Maps the status codes the server uses to refuse this flow onto
  /// [PassportRejectedException]. Returns null for anything else (timeouts,
  /// socket errors) so callers can still tell a network blip from a refused
  /// credential.
  ///
  /// 404 lands here on purpose: a peer that predates the challenge flow has no
  /// `/api/auth/server-*` route at all, which is a refusal to join rather than
  /// a transient failure. 5xx only counts when [serverErrorIsRejection] is set,
  /// since a 5xx is otherwise a real server fault.
  static PassportRejectedException? _asRejection(
    int? statusCode,
    String? detail, {
    bool serverErrorIsRejection = false,
  }) {
    final isRejection =
        statusCode == 401 ||
        statusCode == 403 ||
        statusCode == 404 ||
        statusCode == 410 ||
        (serverErrorIsRejection && statusCode != null && statusCode >= 500);
    if (!isRejection) return null;

    return PassportRejectedException(
      detail ?? 'Server rejected the passport (HTTP $statusCode).',
      statusCode: statusCode,
    );
  }

  static String? _detailFromBody(Object? body) {
    if (body is Map && body['detail'] != null) {
      return body['detail'].toString();
    }
    return null;
  }
}
