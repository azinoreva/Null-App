import 'dart:convert';

import 'package:dio/dio.dart';

import '../../utils/server_list.dart';
import 'server_error_exception.dart';

/// Shared Dio client for the single, stable main/authority server.
///
/// The base URL is resolved from the persisted server list (SharedPreferences
/// via [ServerListService.lookup]), defaulting to the conventional `server_1`
/// id — so the URL always follows whatever the app has stored, with no
/// environment variable involved.
class MainServerClient {
  MainServerClient._();

  static Dio? _dio;

  /// Initializes the shared Dio instance using the persisted [serverId]'s
  /// `serverUrl`. Call this again any time you want to swap servers — it
  /// re-reads the current URL from the server list.
  static Future<void> init({
    String serverId = 'server_1',
    Duration connectTimeout = const Duration(seconds: 5),
    Duration receiveTimeout = const Duration(seconds: 3),
  }) async {
    final server = await ServerListService.lookup(serverId);
    final baseUrl = server?.serverUrl;
    if (baseUrl == null || baseUrl.isEmpty) {
      throw StateError(
        'No URL stored for main server "$serverId" in the server list.',
      );
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio?.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, handler) {
          final statusCode = error.response?.statusCode;
          if (statusCode != null && statusCode >= 400 && statusCode != 401) {
            final detail = _extractDetail(error);
            throw ServerErrorException(detail, statusCode: statusCode);
          }
          handler.next(error);
        },
      ),
    );
  }

  static Dio get dio {
    final client = _dio;
    if (client == null) {
      throw StateError('MainServerClient.init() must be called before use.');
    }
    return client;
  }

  /// Extracts the backend error message from a DioException's response.
  /// The backend always returns "detail" for 4xx/5xx errors; falls back to
  /// the HTTP status text if "detail" is missing.
  static String _extractDetail(DioException error) {
    final data = error.response?.data;
    final map = data is Map
        ? data
        : data is String && data.isNotEmpty
            ? _tryDecodeJson(data)
            : null;
    if (map != null) {
      final detail = map['detail'];
      if (detail != null && detail.toString().isNotEmpty) {
        return detail.toString();
      }
    }
    return error.response?.statusMessage ??
        error.message ??
        'Request failed (${error.response?.statusCode}).';
  }

  /// Best-effort parse of a JSON-encoded error body (e.g. when the backend
  /// replies without a JSON Content-Type, so Dio leaves it as a String).
  /// Returns null if [raw] isn't a JSON object.
  static Map? _tryDecodeJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? decoded : null;
    } catch (_) {
      return null;
    }
  }
}