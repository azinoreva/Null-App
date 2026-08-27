import 'package:dio/dio.dart';

import '../api_client.dart';

/// Represents a comment as returned by the comments endpoints.
///
/// [replyTo] and [atUser] are only relevant for replies (comments on a
/// comment) and are nullable since top-level comments and the
/// check_comments listing don't include them.
class Comment {
  final String updateId;
  final String commentId;
  final String userId;
  final String nickname;
  final String text;
  final String? replyTo;
  final String? atUser;

  Comment({
    required this.updateId,
    required this.commentId,
    required this.userId,
    required this.nickname,
    required this.text,
    this.replyTo,
    this.atUser,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      updateId: json['update_id'] as String,
      commentId: json['comment_id'] as String,
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      text: json['text'] as String,
      replyTo: json['reply_to'] as String?,
      atUser: json['at_user'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'update_id': updateId,
      'comment_id': commentId,
      'user_id': userId,
      'nickname': nickname,
      'text': text,
      if (replyTo != null) 'reply_to': replyTo,
      if (atUser != null) 'at_user': atUser,
    };
  }

  bool get isReply => replyTo != null;

  @override
  String toString() =>
      'Comment(commentId: $commentId, nickname: $nickname, text: $text)';
}

/// Represents the response of POST /api/check_comments
class CheckCommentsResponse {
  final String updateId;
  final List<Comment> comments;

  CheckCommentsResponse({
    required this.updateId,
    required this.comments,
  });

  factory CheckCommentsResponse.fromJson(Map<String, dynamic> json) {
    return CheckCommentsResponse(
      updateId: json['update_id'] as String,
      comments: (json['comments'] as List<dynamic>)
          .map((item) => Comment.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CommentsService {
  final String serverId;

  Dio get _dio => ApiClient.instance(serverId);

  const CommentsService({required this.serverId});

  /// Posts a top-level comment on an update.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors.
  Future<Comment> commentToPost({
    required String updateId,
    required String nickname,
    required String text,
  }) async {
    final response = await _dio.post(
      '/api/comment_to_post',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'update_id': updateId,
        'nickname': nickname,
        'text': text,
      },
    );

    return Comment.fromJson(response.data as Map<String, dynamic>);
  }

  /// Posts a reply to an existing comment on an update.
  ///
  /// [replyTo] is the comment_id being replied to.
  /// [atUser] is the display handle of the user being replied to (e.g. "@Azino").
  Future<Comment> commentToComment({
    required String updateId,
    required String replyTo,
    required String atUser,
    required String nickname,
    required String text,
  }) async {
    final response = await _dio.post(
      '/api/comment_to_comment',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'update_id': updateId,
        'reply_to': replyTo,
        'at_user': atUser,
        'nickname': nickname,
        'text': text,
      },
    );

    return Comment.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetches all comments (and replies) for a given update.
  ///
  /// Note: update_id is sent as a query parameter, and the request body
  /// is empty, matching the original curl call.
  Future<CheckCommentsResponse> checkComments({
    required String updateId,
  }) async {
    final response = await _dio.post(
      '/api/check_comments',
      queryParameters: {
        'update_id': updateId,
      },
      options: Options(
        headers: {
          'accept': 'application/json',
        },
      ),
    );

    return CheckCommentsResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}