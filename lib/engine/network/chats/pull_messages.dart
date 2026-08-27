import 'package:dio/dio.dart';

import '../api_client.dart';

/// Represents a single item returned by GET /api/messages
class QueuedMessage {
  final String senderId;
  final String conversationId;
  final String messageId;
  final String logicalId;
  final int messageType;
  final String message;
  final int messageOrder;
  final String nonce;
  final int timestamp;
  final int protocolVersion;
  final int serverId;
  final int senderSequence;

  QueuedMessage({
    required this.senderId,
    required this.conversationId,
    required this.messageId,
    required this.logicalId,
    required this.messageType,
    required this.message,
    required this.messageOrder,
    required this.nonce,
    required this.timestamp,
    required this.protocolVersion,
    required this.serverId,
    required this.senderSequence,
  });

  factory QueuedMessage.fromJson(Map<String, dynamic> json) {
    return QueuedMessage(
      senderId: json['sender_id'] as String,
      conversationId: json['conversation_id'] as String,
      messageId: json['messageId'] as String,
      logicalId: json['logicalId'] as String,
      messageType: json['messageType'] as int,
      message: json['message'] as String,
      messageOrder: json['messageOrder'] as int,
      nonce: json['nonce'] as String,
      timestamp: json['timestamp'] as int,
      protocolVersion: json['protocolVersion'] as int,
      serverId: json['serverId'] as int,
      senderSequence: json['senderSequence'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender_id': senderId,
      'conversation_id': conversationId,
      'messageId': messageId,
      'logicalId': logicalId,
      'messageType': messageType,
      'message': message,
      'messageOrder': messageOrder,
      'nonce': nonce,
      'timestamp': timestamp,
      'protocolVersion': protocolVersion,
      'serverId': serverId,
      'senderSequence': senderSequence,
    };
  }

  DateTime get timestampDate =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  @override
  String toString() =>
      'QueuedMessage(messageId: $messageId, senderId: $senderId, message: $message)';
}

class MessagesQueueService {
  final String serverId;

  Dio get _dio => ApiClient.instance(serverId);

  const MessagesQueueService({required this.serverId});

  /// Fetches all queued/undelivered messages for the current user.
  /// Typically followed by MessagesService.ackMessages(...) once each
  /// message has been processed locally.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors.
  Future<List<QueuedMessage>> getMessages() async {
    final response = await _dio.get(
      '/api/messages',
      options: Options(
        headers: {
          'accept': 'application/json',
        },
      ),
    );

    final list = response.data as List<dynamic>;
    return list
        .map((item) => QueuedMessage.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}