import 'package:dio/dio.dart';

import '../api_client.dart';

/// Represents the "credential" object returned by
/// POST /api/users/credentials
class Credential {
  final int version;
  final String userId;
  final String serverId;
  final String userPublicKey;
  final int issuedAt;
  final int expiresAt;
  final String signature;

  Credential({
    required this.version,
    required this.userId,
    required this.serverId,
    required this.userPublicKey,
    required this.issuedAt,
    required this.expiresAt,
    required this.signature,
  });

  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      version: json['version'] as int,
      userId: json['user_id'] as String,
      serverId: json['server_id'] as String,
      userPublicKey: json['user_public_key'] as String,
      issuedAt: json['issued_at'] as int,
      expiresAt: json['expires_at'] as int,
      signature: json['signature'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'user_id': userId,
      'server_id': serverId,
      'user_public_key': userPublicKey,
      'issued_at': issuedAt,
      'expires_at': expiresAt,
      'signature': signature,
    };
  }

  DateTime get issuedAtDate =>
      DateTime.fromMillisecondsSinceEpoch(issuedAt * 1000);

  DateTime get expiresAtDate =>
      DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);

  bool get isExpired => DateTime.now().isAfter(expiresAtDate);

  @override
  String toString() => 'Credential(userId: $userId, serverId: $serverId, '
      'version: $version, expiresAt: $expiresAtDate)';
}

/// Wraps the full response of POST /api/users/credentials,
/// i.e. { "credential": { ... } }
class CredentialResponse {
  final Credential credential;

  CredentialResponse({required this.credential});

  factory CredentialResponse.fromJson(Map<String, dynamic> json) {
    return CredentialResponse(
      credential: Credential.fromJson(
        json['credential'] as Map<String, dynamic>,
      ),
    );
  }
}

class UserCredentialsService {
  final String serverId;

  Dio get _dio => ApiClient.instance(serverId);

  const UserCredentialsService({required this.serverId});

  /// Requests a signed credential, from this service's [serverId] (your
  /// main/bootstrap server), for a DIFFERENT server the user wants to log
  /// into — [targetServerId]. These are often different: e.g. call
  /// credentials on 'main' asking for a credential scoped to 'server_1'.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors.
  Future<CredentialResponse> getCredentials({
    required String targetServerId,
    required String userPublicKey,
  }) async {
    final response = await _dio.post(
      '/api/users/credentials',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'server_id': targetServerId,
        'user_public_key': userPublicKey,
      },
    );

    return CredentialResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}