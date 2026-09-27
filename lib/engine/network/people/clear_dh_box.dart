// module name: clear_dh_inbox
import 'package:dio/dio.dart';

import '../main_server_client.dart';

class ClearDhInboxService {
  Dio get _dio => MainServerClient.dio;

  const ClearDhInboxService();

  /// Wipes the caller's dh inbox without fetching its contents.
  ///
  /// Use this to discard stale/unwanted dh drops without going through
  /// [CheckDhDropsService.checkDhDrops] first.
  ///
  /// Returns `true` if an inbox existed and was cleared, `false` if the
  /// inbox was already empty.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by MainServerClient's interceptors.
  Future<bool> clearDhInbox() async {
    final response = await _dio.post(
      '/api/connections/clear_dh_inbox',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    final data = response.data as Map<String, dynamic>;
    return data['cleared'] as bool;
  }
}