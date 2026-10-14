import 'package:dio/dio.dart';

import '../api_client.dart';

/// Represents a single recipient in the "recipient_ids" list.
class MessageRecipient {
  final String userId;
  final String userName;

  MessageRecipient({
    required this.userId,
    required this.userName,
  });

  factory MessageRecipient.fromJson(Map<String, dynamic> json) {
    return MessageRecipient(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
    };
  }
}

/// Represents the response of POST /api/message
class SendMessageResponse {
  final int messageSent;

  SendMessageResponse({required this.messageSent});

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(messageSent: _parseTimestamp(json['message_sent']));
  }

  /// The server reports acceptance as a Unix timestamp (seconds), but the
  /// exact shape varies: a bare int, a numeric string, or an object (the same
  /// `{"message_sent": {...}}` envelope the WebSocket uses). A 200 must never
  /// throw just because the body didn't match, or the durable send task would
  /// treat an accepted message as failed and retry it endlessly.
  static int _parseTimestamp(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? 0;
    if (raw is Map) {
      for (final key in const ['timestamp', 'message_sent', 'messageSent', 'at']) {
        final value = raw[key];
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value) ?? 0;
      }
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'message_sent': messageSent,
    };
  }

  /// `message_sent` is a Unix timestamp (seconds) of when the server
  /// accepted the message.
  DateTime get messageSentDate =>
      DateTime.fromMillisecondsSinceEpoch(messageSent * 1000);

  @override
  String toString() => 'SendMessageResponse(messageSentDate: $messageSentDate)';
}

class SendMessageService {
  final String serverId;

  Dio get _dio => ApiClient.instance(serverId);

  const SendMessageService({required this.serverId});

  /// Sends a message to one or more recipients within a conversation.
  ///
  /// [serverId] is the server the message is destined for (written into the
  /// request body); the class's own id is only the server the request is
  /// actually posted to. They differ when we forward through one of our own
  /// servers to a contact we share no server with — the receiving server
  /// routes the message on to [serverId].
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors.
  Future<SendMessageResponse> sendMessage({
    required List<MessageRecipient> recipientIds,
    required String messageId,
    required String logicalId,
    required String conversationId,
    required int messageType,
    required String message,
    required int messageOrder,
    required String nonce,
    required int senderSequence,
    required String serverId,
  }) async {
    final response = await _dio.post(
      '/api/message',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'recipient_ids': recipientIds.map((r) => r.toJson()).toList(),
        'serverId': serverId,
        'messageId': messageId,
        'logicalId': logicalId,
        'conversationId': conversationId,
        'messageType': messageType,
        'message': message,
        'messageOrder': messageOrder,
        'nonce': nonce,
        'senderSequence': senderSequence,
      },
    );

    return SendMessageResponse.fromJson(
      response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : const <String, dynamic>{},
    );
  }
}