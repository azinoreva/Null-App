import 'package:dio/dio.dart';

import '../api_client.dart';
import 'check_updates.dart' show UpdateMedia;

/// Represents the response of POST /api/updates (creating a new update)
class CreateUpdateResponse {
  final String updateId;
  final String userId;
  final String nickname;
  final String text;
  final int expires;
  final UpdateMedia? media;

  CreateUpdateResponse({
    required this.updateId,
    required this.userId,
    required this.nickname,
    required this.text,
    required this.expires,
    this.media,
  });

  factory CreateUpdateResponse.fromJson(Map<String, dynamic> json) {
    return CreateUpdateResponse(
      updateId: json['update_id'] as String,
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      text: json['text'] as String,
      expires: json['expires'] as int,
      media: json['media'] != null
          ? UpdateMedia.fromJson(json['media'] as Map<String, dynamic>)
          : null,
    );
  }

  /// `expires` is a duration in seconds (e.g. 604800 = 7 days),
  /// not a timestamp, so this computes the actual expiry moment based on
  /// when the response was received.
  DateTime get expiresAt => DateTime.now().add(Duration(seconds: expires));
}

/// Represents the response of POST /api/check_update_progress
class UpdateProgress {
  final String updateId;
  final int views;
  final int likes;
  final int follows;
  final int dislikes;

  UpdateProgress({
    required this.updateId,
    required this.views,
    required this.likes,
    required this.follows,
    required this.dislikes,
  });

  factory UpdateProgress.fromJson(Map<String, dynamic> json) {
    return UpdateProgress(
      updateId: json['update_id'] as String,
      views: json['views'] as int,
      likes: json['likes'] as int,
      follows: json['follows'] as int,
      dislikes: json['dislikes'] as int,
    );
  }
}

/// Represents the response of POST /api/mark_update_read
class MarkUpdateReadResponse {
  final String updateId;
  final bool recorded;

  MarkUpdateReadResponse({
    required this.updateId,
    required this.recorded,
  });

  factory MarkUpdateReadResponse.fromJson(Map<String, dynamic> json) {
    return MarkUpdateReadResponse(
      updateId: json['update_id'] as String,
      recorded: json['recorded'] as bool,
    );
  }
}

class UpdatesActionsService {
  final String serverId;

  Dio get _dio => ApiClient.instance(serverId);

  const UpdatesActionsService({required this.serverId});

  /// Creates a new update (post). [media] is optional.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors.
  Future<CreateUpdateResponse> createUpdate({
    required String nickname,
    required String text,
    required String category,
    required String hashtag,
    UpdateMedia? media,
  }) async {
    final response = await _dio.post(
      '/api/updates',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'nickname': nickname,
        if (media != null) 'media': media.toJson(),
        'text': text,
        'category': category,
        'hashtag': hashtag,
      },
    );

    return CreateUpdateResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Fetches engagement counters (views, likes, follows, dislikes) for an
  /// update. update_id is sent as a query parameter with an empty body,
  /// matching the original curl call.
  Future<UpdateProgress> checkUpdateProgress({
    required String updateId,
  }) async {
    final response = await _dio.post(
      '/api/check_update_progress',
      queryParameters: {
        'update_id': updateId,
      },
      options: Options(
        headers: {
          'accept': 'application/json',
        },
      ),
    );

    return UpdateProgress.fromJson(response.data as Map<String, dynamic>);
  }

  /// Records a user's interaction with an update after viewing it
  /// (like, dislike, follow, or unfollow the poster).
  ///
  /// Only set the flag(s) relevant to the action being recorded; the others
  /// default to false.
  Future<MarkUpdateReadResponse> markUpdateRead({
    required String updateId,
    bool like = false,
    bool follow = false,
    bool dislike = false,
    bool unfollow = false,
  }) async {
    final response = await _dio.post(
      '/api/mark_update_read',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'update_id': updateId,
        'like': like,
        'follow': follow,
        'dislike': dislike,
        'unfollow': unfollow,
      },
    );

    return MarkUpdateReadResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}