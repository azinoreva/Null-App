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

/// The kind of push notification being triggered.
enum PushNotificationType {
  message,
  ping;

  String get wireValue => name;
}

/// Represents the response of POST /api/account/send_push_notification.
///
/// No response body was shown for this endpoint, so this assumes the same
/// {status, message} shape as the token-update endpoint above. If the real
/// response differs, adjust fromJson accordingly.
class SendPushNotificationResponse {
  final String status;
  final String message;

  SendPushNotificationResponse({
    required this.status,
    required this.message,
  });

  factory SendPushNotificationResponse.fromJson(Map<String, dynamic> json) {
    return SendPushNotificationResponse(
      status: json['status'] as String,
      message: json['message'] as String,
    );
  }

  bool get isSuccess => status == 'success';
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

  /// Triggers a push notification to [userId].
  ///
  /// - For a "ping" (no content, e.g. a wake-up/attention nudge), pass
  ///   `type: PushNotificationType.ping` and leave [message] null.
  /// - For a "message" notification, pass `type: PushNotificationType.message`
  ///   along with the [message] text to show.
  ///
  /// [message] is only included in the request body when non-null, so a
  /// ping's body matches the second curl exactly (no "message" key at all).
  Future<SendPushNotificationResponse> sendPushNotification({
    required String userId,
    required PushNotificationType type,
    String? message,
  }) async {
    final response = await _dio.post(
      '/api/account/send_push_notification',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'user_id': userId,
        'notification_type': type.wireValue,
        if (message != null) 'message': message,
      },
    );

    return SendPushNotificationResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}