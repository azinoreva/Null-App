// module name: send_contact_rebound
import 'package:dio/dio.dart';

import '../api_client.dart';

/// Result of creating a shareable contact invite.
class SendContactResult {

  final String message;

  const SendContactResult({
    required this.message
  });

  factory SendContactResult.fromJson(Map<String, dynamic> json) {
    return SendContactResult(
      message: json['message'] as String
    );
  }
}

class SendContactReboundService {
  final String serverId;

  Dio get _dio => ApiClient.instance(serverId);

  const SendContactReboundService({required this.serverId});


  /// Sends the current user's contact/profile info to generate an invite.
  /// Returns a string in json
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors.
  Future<SendContactResult> sendContact({
    required String nickname,
    required String title,
    required String bio,
    required String publicKey,
    required String avatar,
    required String contactKey
   
  }) async {
   

    final response = await _dio.post(
      '/api/connections/send_contact_rebound',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {
          'nickname': nickname,
          'title': title,
          'bio': bio,
          'public_key': publicKey,
          'avatar': avatar,
          'contact_key': contactKey,
      },
    );

    return SendContactResult.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}