import 'package:dio/dio.dart';

import '../api_client.dart';

/// Represents the response of GET /api/invitation_count
class InvitationCount {
  final int remaining;
  final int nextReset;

  InvitationCount({
    required this.remaining,
    required this.nextReset,
  });

  factory InvitationCount.fromJson(Map<String, dynamic> json) {
    return InvitationCount(
      remaining: json['remaining'] as int,
      nextReset: json['next_reset'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'remaining': remaining,
      'next_reset': nextReset,
    };
  }

  DateTime get nextResetDate =>
      DateTime.fromMillisecondsSinceEpoch(nextReset * 1000);

  @override
  String toString() =>
      'InvitationCount(remaining: $remaining, nextReset: $nextResetDate)';
}

class InvitationService {
  final String serverId;

  Dio get _dio => ApiClient.instance(serverId);

  const InvitationService({required this.serverId});

  /// Fetches how many invitations the current user has left,
  /// and when the count next resets.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors.
  Future<InvitationCount> getInvitationCount() async {
    final response = await _dio.get(
      '/api/invitation_count',
      options: Options(
        headers: {
          'accept': 'application/json',
        },
      ),
    );

    return InvitationCount.fromJson(response.data as Map<String, dynamic>);
  }
}