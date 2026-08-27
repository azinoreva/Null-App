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
    return SendMessageResponse(
      messageSent: json['message_sent'] as int,
    );
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
      response.data as Map<String, dynamic>,
    );
  }
}