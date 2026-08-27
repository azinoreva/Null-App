import 'package:dio/dio.dart';

import '../api_client.dart';

/// Represents the response of POST /api/messages/ack
class AckMessagesResponse {
  final int deleted;

  AckMessagesResponse({required this.deleted});

  factory AckMessagesResponse.fromJson(Map<String, dynamic> json) {
    return AckMessagesResponse(
      deleted: json['deleted'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deleted': deleted,
    };
  }

  @override
  String toString() => 'AckMessagesResponse(deleted: $deleted)';
}

class MessagesService {
  final String serverId;

  Dio get _dio => ApiClient.instance(serverId);

  const MessagesService({required this.serverId});

  /// Acknowledges receipt of one or more messages by id, so the server can
  /// delete them (e.g. after they've been delivered/processed locally).
  ///
  /// The request body is a raw JSON array of message ids, not an object.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors.
  Future<AckMessagesResponse> ackMessages({
    required List<String> messageIds,
  }) async {
    final response = await _dio.post(
      '/api/messages/ack',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: messageIds,
    );

    return AckMessagesResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}