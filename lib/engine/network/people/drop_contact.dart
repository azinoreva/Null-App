// module name: drop_contact
import 'package:dio/dio.dart';

import '../main_server_client.dart';

/// The contact being dropped. Mirrors the server's `Contact` model.
///
/// The server adds `contact_id` (the sender's user id) and `server_id`
/// itself, so don't send those.
class Contact {
  static const int maxNicknameLength = 50;
  static const int maxTitleLength = 100;
  static const int maxBioLength = 500;
  static const int maxPublicKeyLength = 128;
  static const int maxDhPublicKeyLength = 128;
  static const int maxAvatarLength = 29000;

  /// The name of the contact.
  final String nickname;

  /// The title of the contact.
  final String title;

  /// The bio of the contact.
  final String bio;

  /// The Ed25519 identity public key of the contact.
  final String publicKey;

  /// The contact's X25519 (Diffie-Hellman) public key, urlsafe base64.
  /// Needed to seal a dh key to them. Omit if unknown.
  final String? dhPublicKey;

  /// The avatar of the contact (encoded string, max 29000 chars).
  final String? avatar;

  const Contact({
    required this.nickname,
    required this.title,
    required this.bio,
    required this.publicKey,
    this.dhPublicKey,
    this.avatar,
  });

  /// Throws [ArgumentError] if any field exceeds the server's limits, so
  /// you get a clear local error instead of a 422 from the server.
  void validate() {
    _checkMax('nickname', nickname, maxNicknameLength);
    _checkMax('title', title, maxTitleLength);
    _checkMax('bio', bio, maxBioLength);
    _checkMax('publicKey', publicKey, maxPublicKeyLength);
    _checkMax('dhPublicKey', dhPublicKey, maxDhPublicKeyLength);
    _checkMax('avatar', avatar, maxAvatarLength);
  }

  static void _checkMax(String name, String? value, int max) {
    if (value != null && value.length > max) {
      throw ArgumentError.value(
        '${value.length} chars',
        name,
        'must be at most $max characters',
      );
    }
  }

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'title': title,
        'bio': bio,
        'public_key': publicKey,
        if (dhPublicKey != null) 'dh_public_key': dhPublicKey,
        if (avatar != null) 'avatar': avatar,
      };
}

class DropContactService {
  Dio get _dio => MainServerClient.dio;

  const DropContactService();

  /// Max length enforced server-side for `recipient_id`.
  static const int maxRecipientIdLength = 128;

  /// Drops a contact directly into [recipientId]'s inbox.
  ///
  /// Unlike send_contact, this produces no shareable link. Only the
  /// recipient can retrieve it, via their inbox check. Dropping again for
  /// the same recipient overwrites your previous pending drop to them.
  ///
  /// [expiresIn] is in seconds. If omitted, the server default is used;
  /// the server rejects values outside its min/max range (max 48 hours)
  /// with a 422.
  ///
  /// Pass [selfId] to fail fast locally if you try to drop to yourself.
  /// Otherwise the server returns a 400, which surfaces as a
  /// [DioException]. Invalid field lengths throw [ArgumentError].
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by MainServerClient's interceptors.
  Future<String> dropContact({
    required String recipientId,
    required Contact contact,
    int? expiresIn,
    String? selfId,
  }) async {
    if (recipientId.isEmpty || recipientId.length > maxRecipientIdLength) {
      throw ArgumentError.value(
        recipientId,
        'recipientId',
        'must be 1-$maxRecipientIdLength characters',
      );
    }
    if (selfId != null && recipientId == selfId) {
      throw ArgumentError("You can't drop a contact for yourself");
    }
    contact.validate();

    final response = await _dio.post(
      '/api/drop_contact',
      data: {
        'recipient_id': recipientId,
        'contact': contact.toJson(),
        if (expiresIn != null) 'expires_in': expiresIn,
      },
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    final data = response.data as Map<String, dynamic>;
    return data['message'] as String;
  }
}