import 'package:dio/dio.dart';

import '../api_client.dart';

/// Represents the "media" object attached to an update, if any.
class UpdateMedia {
  final String mediaUrl;
  final String mediaType;
  final String mediaDescription;

  UpdateMedia({
    required this.mediaUrl,
    required this.mediaType,
    required this.mediaDescription,
  });

  factory UpdateMedia.fromJson(Map<String, dynamic> json) {
    return UpdateMedia(
      mediaUrl: json['media_url'] as String,
      mediaType: json['media_type'] as String,
      mediaDescription: json['media_description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'media_url': mediaUrl,
      'media_type': mediaType,
      'media_description': mediaDescription,
    };
  }
}

/// Represents a single item returned by POST /api/get_updates
class Update {
  final String nickname;
  final UpdateMedia? media;
  final String text;
  final String category;
  final String hashtag;
  final String updateId;

  Update({
    required this.nickname,
    this.media,
    required this.text,
    required this.category,
    required this.hashtag,
    required this.updateId,
  });

  factory Update.fromJson(Map<String, dynamic> json) {
    return Update(
      nickname: json['nickname'] as String,
      media: json['media'] != null
          ? UpdateMedia.fromJson(json['media'] as Map<String, dynamic>)
          : null,
      text: json['text'] as String,
      category: json['category'] as String,
      hashtag: json['hashtag'] as String,
      updateId: json['update_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'media': media?.toJson(),
      'text': text,
      'category': category,
      'hashtag': hashtag,
      'update_id': updateId,
    };
  }

  @override
  String toString() =>
      'Update(updateId: $updateId, nickname: $nickname, category: $category, hashtag: $hashtag)';
}

class UpdatesService {
  final String serverId;

  Dio get _dio => ApiClient.instance(serverId);

  const UpdatesService({required this.serverId});

  /// Fetches a page of updates from POST /api/get_updates.
  ///
  /// Filtering is optional. Pass at most one of [category], [categories],
  /// [hashtags], or [userIds]; omit them all to get the full feed. [before]
  /// and [limit] control pagination and are always sent.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors.
  Future<List<Update>> getUpdates({
    String? category,
    List<String>? categories,
    List<String>? hashtags,
    List<String>? userIds,
    int before = 0,
    int limit = 20,
  }) async {
    final data = <String, dynamic>{'before': before, 'limit': limit};

    if (category != null) data['category'] = category;
    if (categories != null && categories.isNotEmpty) {
      data['categories'] = categories;
    }
    if (hashtags != null && hashtags.isNotEmpty) data['hashtags'] = hashtags;
    if (userIds != null && userIds.isNotEmpty) data['user_ids'] = userIds;

    final response = await _dio.post(
      '/api/get_updates',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: data,
    );

    final list = response.data as List<dynamic>;
    return list
        .map((item) => Update.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
