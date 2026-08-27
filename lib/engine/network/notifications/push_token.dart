import 'package:dio/dio.dart';

import '../api_client.dart';

/// Represents the response of POST /api/account/push-notification-token
class PushNotificationTokenResponse {
  final String status;
  final String message;

  PushNotificationTokenResponse({
    required this.status,
    required this.message,
  });

  factory PushNotificationTokenResponse.fromJson(Map<String, dynamic> json) {
    return PushNotificationTokenResponse(
      status: json['status'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }

  bool get isSuccess => status == 'success';

  @override
  String toString() =>
      'PushNotificationTokenResponse(status: $status, message: $message)';
}

class PushNotificationService {
  final String serverId;

  Dio get _dio => ApiClient.instance(serverId);

  const PushNotificationService({required this.serverId});

  /// Sends the device's push notification token (e.g. FCM token) to the
  /// server so it can be associated with the current account.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors.
  Future<PushNotificationTokenResponse> updatePushNotificationToken({
    required String token,
  }) async {
    final response = await _dio.post(
      '/api/account/push-notification-token',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'token': token,
      },
    );

    return PushNotificationTokenResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}