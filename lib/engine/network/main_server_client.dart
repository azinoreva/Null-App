import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_failure_handler.dart';
import 'server_error_exception.dart';

/// Shared Dio client for the single, stable main/authority server.
///
/// The base URL is resolved from `SERVER_URL` in the loaded `.env` file.
///
/// Unlike [ApiClient] (multi-server, per-server token stores), this client
/// is authenticated with the user's *login* tokens — the access token that
/// `/api/sign-in` returns for the main server (`server_1`). The tokens are
/// kept under dedicated keys in secure storage and auto-refresh on 401 via
/// `/api/refresh`, retrying the failed request once. The unauthenticated
/// endpoints `/api/sign-in` and `/api/refresh` never get a Bearer header.
class MainServerClient {
  MainServerClient._();

  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'main_server_access_token';
  static const _refreshTokenKey = 'main_server_refresh_token';

  static Dio? _dio;

  // Prevents multiple simultaneous refresh calls when several requests
  // fail with 401 at once.
  static Completer<String?>? _refreshCompleter;

  /// The id of the main/authority server, from `SERVER` in `.env`
  /// (defaults to `server_1`).
  static String get serverId => dotenv.env['SERVER'] ?? 'server_1';

  /// Initializes the shared Dio instance using `SERVER_URL` from dotenv.
  /// Call this again any time the environment configuration changes.
  static Future<void> init({
    Duration connectTimeout = const Duration(seconds: 5),
    Duration receiveTimeout = const Duration(seconds: 3),
  }) async {
    final baseUrl = dotenv.env['SERVER_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      throw StateError(
        'No SERVER_URL configured in the .env file for the main server.',
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
        onRequest: (options, handler) async {
          if (_isPublicPath(options.path)) {
            handler.next(options);
            return;
          }
          final accessToken = await getAccessToken();
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
        onError: (DioException error, handler) async {
          final statusCode = error.response?.statusCode;

          if (statusCode != null && statusCode >= 400 && statusCode != 401) {
            final detail = _extractDetail(error);
            throw ServerErrorException(detail, statusCode: statusCode);
          }

          if (statusCode != 401) {
            handler.next(error);
            return;
          }

          // Bad credentials on the sign-in endpoint — nothing to refresh.
          if (_isPublicPath(error.requestOptions.path)) {
            handler.next(error);
            return;
          }

          // Avoid infinite loop if the refresh-retry request itself 401s.
          final alreadyRetried = error.requestOptions.extra['retried'] == true;
          if (alreadyRetried) {
            await _expireSession();
            handler.next(error);
            return;
          }

          try {
            final newAccessToken = await refreshAccessToken();

            if (newAccessToken == null) {
              await _expireSession();
              handler.next(error);
              return;
            }

            // Retry the original request with the new token.
            final retryOptions = error.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            retryOptions.extra['retried'] = true;

            final response = await _dio!.fetch(retryOptions);
            handler.resolve(response);
          } catch (_) {
            await _expireSession();
            handler.next(error);
          }
        },
      ),
    );
  }

  static bool _isPublicPath(String path) =>
      path == '/api/sign-in' || path == '/api/refresh';

  static Future<void> _expireSession() async {
    await clearTokens();
    await redirectToLogin();
  }

  // --- Token storage (the main-server login credentials) ----------------

  /// Stores the token pair returned by `/api/sign-in` as the main-server
  /// (login) credentials this client authenticates every request with.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// The current main-server access token, or null if not logged in.
  static Future<String?> getAccessToken() =>
      _storage.read(key: _accessTokenKey);

  /// The current main-server refresh token, or null if not logged in.
  static Future<String?> getRefreshToken() =>
      _storage.read(key: _refreshTokenKey);

  /// Deletes the stored main-server tokens (e.g. on logout).
  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Refreshes the main-server access token via `/api/refresh`, coalescing
  /// concurrent callers into a single request. Returns the new access token,
  /// or null if the refresh failed (e.g. refresh token missing or expired).
  static Future<String?> refreshAccessToken() async {
    final inFlight = _refreshCompleter;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final refreshToken = await getRefreshToken();
      final baseUrl = dotenv.env['SERVER_URL'];

      if (refreshToken == null || baseUrl == null || baseUrl.isEmpty) {
        completer.complete(null);
        return null;
      }

      // Plain Dio instance (no interceptors) to avoid recursive 401 handling.
      final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));

      final response = await refreshDio.post(
        '/api/refresh',
        options: Options(
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $refreshToken',
          },
        ),
      );

      final newAccessToken = response.data['access_token'] as String?;
      final newRefreshToken = response.data['refresh_token'] as String?;

      if (newAccessToken == null) {
        completer.complete(null);
        return null;
      }

      await saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken ?? refreshToken,
      );

      completer.complete(newAccessToken);
      return newAccessToken;
    } catch (_) {
      completer.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
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