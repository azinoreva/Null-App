// module name: create_invite
import 'package:dio/dio.dart';

import '../api_client.dart';

// represents a single item returned by /api/account/invite-contact
class SendContact {
  final String userId;
  final String passcode;
  final String deeplink;
  final String serverId;

  SendContact({
    required this.userId,
    required this.passcode,
    required this.deeplink,
    required this.serverId,
  });

  factory SendContact.fromJson(Map<String, dynamic> json) {
    return SendContact(
      userId: json['user_id'] as String,
      passcode: json['passcode'] as String,
      deeplink: json['deeplink'] as String,
      serverId: json['server_id'] as String,
    );
  }
}

// The response body of /api/account/invite-contact is the same shape as
// SendContact itself (no wrapping key), so this is just an alias rather
// than a separate class with duplicate fields.
typedef SendContactResponse = SendContact;

class SendContactService {
  final String serverId;

  Dio get _dio => ApiClient.instance(serverId);

  const SendContactService({required this.serverId});

  /// Generates a one-time invite (passcode + deeplink) for the CURRENT
  /// user to share with someone else — [publicKey] is the current user's
  /// own public key (not the recipient's), which the recipient's client
  /// uses to establish a secure/encrypted channel back once they accept
  /// the invite via the deeplink.
  ///
  /// The returned SendContact.userId is the current user's id (it matches
  /// the JWT subject in the auth token) — it identifies who the invite is
  /// FROM, not who it's being sent to. The actual recipient isn't known to
  /// the server at this point; you share the deeplink out-of-band
  /// (SMS, share sheet, etc.) however you like.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors.
  Future<SendContactResponse> generateInvite({
    required String publicKey,
  }) async {
    final response = await _dio.post(
      '/api/account/invite-contact',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'public_key': publicKey,
      },
    );

    return SendContactResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}