// module name: send_contact
import 'package:dio/dio.dart';

import '../main_server_client.dart';
import '../server_error_exception.dart';
import 'wire_servers.dart';

/// Result of creating a shareable contact invite.
class SendContactResult {
  /// Deeplink URL to share with the recipient, e.g.
  /// `https://null.app/server_1/c/{contact_key}`.
  final String url;

  /// Seconds until the invite expires (server-confirmed, may differ
  /// slightly from what was requested if the server clamped it).
  final int expiresIn;

  /// Whether the invite is single-use (destroyed on first fetch).
  final bool oneTime;

  final String contactKey;

  const SendContactResult({
    required this.url,
    required this.expiresIn,
    required this.oneTime,
    required this.contactKey,
  });

  factory SendContactResult.fromJson(Map<String, dynamic> json) {
    return SendContactResult(
      url: json['url'] as String,
      expiresIn: json['expires_in'] as int,
      oneTime: json['one_time'] as bool,
      contactKey: json['contact_key'] as String,
    );
  }
}

class SendContactService {
  Dio get _dio => MainServerClient.dio;

  const SendContactService();

  /// Minimum / maximum / default expiry, mirroring the backend contract.
  static const int minExpirySeconds = 60;
  static const int maxExpirySeconds = 48 * 60 * 60; // 48 hours
  static const int defaultExpirySeconds = 10 * 60;  // 10 minutes

  /// Sends the current user's contact/profile info to generate an invite.
  ///
  /// The caller chooses how long the invite lives ([expiresInSeconds], clamped
  /// to [minExpirySeconds]..[maxExpirySeconds]) and whether it is
  /// single-use ([oneTime]).
  ///
  /// Returns a [SendContactResult] containing the invite deeplink URL
  /// (e.g. `https://null.app/server_1/c/{passcode}`) to be shared with the
  /// recipient, who consumes it via the receive-contact flow.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by MainServerClient's interceptors.
  Future<SendContactResult> sendContact({
    required String nickname,
    required String title,
    required String bio,
    required String publicKey,
    required String avatar,
    required List<String> servers,
    int expiresInSeconds = defaultExpirySeconds,
    bool oneTime = false,
  }) async {
    // Defensive clamp so a bad caller can't produce a 422 from the server.
    final clampedExpiry = expiresInSeconds.clamp(
      minExpirySeconds,
      maxExpirySeconds,
    );

    try {
      final response = await _dio.post(
        '/api/send_contact',
        options: Options(
          // The default client receive timeout (3s) is too short for the
          // invite generation round-trip; give the server ample headroom so
          // a slow response doesn't abort the request.
          receiveTimeout: const Duration(seconds: 20),
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'contact': {
            'nickname': nickname,
            'title': title,
            'bio': bio,
            'public_key': publicKey,
            'avatar': avatar,
            'servers': writeServersToJson(servers),
          },
          'expires_in': clampedExpiry,
          'one_time': oneTime,
        },
      );

      return SendContactResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      // Convert transport-level failures (timeouts, no connection) into a
      // readable error instead of leaking the raw DioException. HTTP errors
      // are already translated to ServerErrorException by the interceptor.
      throw ServerErrorException(
        'Could not create the contact invite. Please check your connection '
        'and try again.',
        statusCode: error.response?.statusCode ?? 0,
      );
    }
  }
}