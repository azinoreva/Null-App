// module name: get_contact
import 'package:dio/dio.dart';

import '../api_client.dart';

class ContactInfo {
  final String nickname;
  final String title;
  final String bio;
  final String publicKey;

  /// May be `null` — the sender is not required to include an avatar.
  final String? avatar;

  final String contactId;
  final String serverId;

  const ContactInfo({
    required this.nickname,
    required this.title,
    required this.bio,
    required this.publicKey,
    this.avatar,
    required this.contactId,
    required this.serverId,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      nickname: json['nickname'] as String,
      title: json['title'] as String,
      bio: json['bio'] as String,
      publicKey: json['public_key'] as String,
      avatar: json['avatar'] as String?,
      contactId: json['contact_id'] as String,
      serverId: json['server_id'] as String,
    );
  }
}

class GetContactService {
  final String serverId;

  Dio get _dio => ApiClient.instance(serverId);

  const GetContactService({required this.serverId});

  /// Looks up a contact's profile info by [contactKey].
  ///
  /// Returns the contact's nickname, title, bio, public key, optional avatar,
  /// plus resolved [ContactInfo.contactId] and [ContactInfo.serverId]
  /// identifying the underlying account.
  ///
  /// Errors (404 for an unknown/expired/consumed key, 429 for rate limiting)
  /// surface as [DioException]s from ApiClient.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors.
  Future<ContactInfo> getContact({
    required String contactKey,
  }) async {
    final response = await _dio.post(
      '/api/connections/get_contact',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'contact_key': contactKey,
      },
    );

    return ContactInfo.fromJson(response.data as Map<String, dynamic>);
  }
}