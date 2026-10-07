// module name: check_contact
import 'package:dio/dio.dart';

import '../main_server_client.dart';
import 'wire_servers.dart';

/// A single contact found in the caller's inbox.
///
/// This is the server's `Contact` model plus the two fields the server
/// stamps on at drop time (`contact_id` and the sender's `servers`).
class ReceivedContact {
  /// The user id of whoever dropped this contact. Set by the server from
  /// the sender's JWT, so it can be trusted as the sender's identity.
  final String contactId;

  /// The server id the sender dropped from (relevant in multi-server
  /// setups).
  final List<String> servers;

  /// The name of the contact.
  final String nickname;

  /// The title of the contact.
  final String title;

  /// The bio of the contact.
  final String bio;

  /// The Ed25519 identity public key of the contact.
  final String publicKey;

  /// The contact's X25519 (Diffie-Hellman) public key, urlsafe base64.
  /// Null if the sender didn't include one.
  final String? dhPublicKey;

  /// The avatar of the contact (encoded string). Null if not provided.
  final String? avatar;

  const ReceivedContact({
    required this.contactId,
    required this.servers,
    required this.nickname,
    required this.title,
    required this.bio,
    required this.publicKey,
    this.dhPublicKey,
    this.avatar,
  });

  factory ReceivedContact.fromJson(Map<String, dynamic> json) {
    return ReceivedContact(
      contactId: json['contact_id'] as String,
      servers: readServersFromJson(json),
      nickname: json['nickname'] as String,
      title: json['title'] as String,
      bio: json['bio'] as String,
      publicKey: json['public_key'] as String,
      dhPublicKey: json['dh_public_key'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'contact_id': contactId,
        'servers': servers,
        'nickname': nickname,
        'title': title,
        'bio': bio,
        'public_key': publicKey,
        'dh_public_key': dhPublicKey,
        'avatar': avatar,
      };
}

class CheckContactService {
  Dio get _dio => MainServerClient.dio;

  const CheckContactService();

  /// Fetches any contacts left in the caller's inbox.
  ///
  /// This atomically fetches and clears the inbox server-side, so each
  /// [ReceivedContact] is delivered exactly once. Call this once on app
  /// open (alongside checking dh drops) rather than polling, and persist
  /// the results right away, because they can't be fetched again.
  ///
  /// Returns an empty list if the inbox is empty. There is at most one
  /// entry per sender, since a newer drop from the same sender overwrites
  /// the older one.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by MainServerClient's interceptors.
  Future<List<ReceivedContact>> checkContact() async {
    final response = await _dio.post(
      '/api/check_contact',
      options: Options(
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    final data = response.data as Map<String, dynamic>;
    final contacts = data['contacts'] as List<dynamic>;

    return contacts
        .map((e) => ReceivedContact.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
