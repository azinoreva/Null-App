import 'package:dio/dio.dart';

import '../main_server_client.dart';

/// Represents the response of POST /api/new-passport:
/// `{ "passport": "<b64u(payload)>.<hex signature>", "expires": 2592000 }`
class NewPassportResponse {
  final String passport;
  final int expires;

  NewPassportResponse({required this.passport, required this.expires});

  factory NewPassportResponse.fromJson(Map<String, dynamic> json) {
    return NewPassportResponse(
      passport: json['passport'] as String,
      expires: json['expires'] as int,
    );
  }

  Duration get lifetime => Duration(seconds: expires);

  @override
  String toString() => 'NewPassportResponse(expires: $expires)';
}

/// Re-mints the account passport against a known identity public key.
///
/// A passport is signed by the *main server* (every server in a federation
/// verifies it with the same shared `SERVER_PRIVATE_KEY`), so it cannot be
/// derived on the device — it has to be asked for. It carries `exp` (30 days)
/// and the public key it was minted for, which is why [publicKey] is a
/// parameter: re-minting with a different key than the one the peer will be
/// asked to verify against would lock you out.
///
/// Goes through [MainServerClient] rather than ApiClient because this is a
/// main-service route requiring the login access token; that client also
/// handles the Bearer header and the 401 refresh-and-retry.
class PassportService {
  Dio get _client => MainServerClient.dio;

  /// Asks the main server for a fresh passport bound to [publicKey].
  Future<NewPassportResponse> newPassport({required String publicKey}) async {
    final response = await _client.post(
      '/api/new-passport',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {'public_key': publicKey},
    );

    return NewPassportResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
