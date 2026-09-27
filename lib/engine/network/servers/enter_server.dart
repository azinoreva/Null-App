import 'package:dio/dio.dart';

import '../api_client.dart';

/// Represents the payload sent to POST /api/server-entry.
///
/// Field names use aliases to match the server's expected JSON keys:
/// `passport` -> `passport_token`, `userId` stays `userId`, and
/// `invite_pin` is optional.
class Passport {
  final String passport;
  final String userId;
  final String? invitePin;

  Passport({
    required this.passport,
    required this.userId,
    this.invitePin,
  });

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

/// Represents the response of POST /api/server-entry,
/// i.e. { "access_token": ..., "refresh_token": ..., "expires": ... }
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
  String toString() =>
      'SignInReturn(expiresAt: $expiresAtDate)';
}

class ServerEntryService {
  /// Exchanges a passport for a fresh access/refresh token pair via
  /// POST /api/server-entry.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors, where applicable.
  Future<SignInReturn> serverEntry({
    required String serverId,
    required String passport,
    required String userId,
    String? invitePin,
  }) async {
    final response = await ApiClient.instance(serverId).post(
      '/api/server-entry',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: Passport(
        passport: passport,
        userId: userId,
        invitePin: invitePin,
      ).toJson(),
    );

    return SignInReturn.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}