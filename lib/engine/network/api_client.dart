import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../utils/server_list.dart';
import 'server_error_exception.dart';

/// Manages API clients for multiple servers. Each server has its own
/// baseUrl, its own Dio instance, and its own access/refresh tokens —
/// stored under server-scoped keys in secure storage — so tokens for one
/// server are never mixed up with another's.
///
/// Register each server once at startup (or whenever the app learns about
/// a new server, e.g. after fetching a list of servers):
///
/// ```dart
/// ApiClient.registerServer(
///   serverId: 'server-1',
///   baseUrl: 'https://server1.example.com',
///   onAuthFailure: () {
///     navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
///   },
/// );
/// ```
///
/// Then use `ApiClient.instance('server-1')` anywhere as a normal Dio
/// client for that server.
class ApiClient {
  ApiClient._();

  static const _storage = FlutterSecureStorage();

  static final Map<String, Dio> _clients = {};
  static final Map<String, String> _baseUrls = {};
  static final Map<String, VoidCallback> _onAuthFailureCallbacks = {};

  // Prevents multiple simultaneous refresh calls for the SAME server when
  // several of that server's requests fail with 401 at once. Scoped per
  // server id so one server refreshing never blocks or interferes with
  // another.
  static final Map<String, Completer<String?>> _refreshCompleters = {};

  /// The Dio client for [serverId]. Throws if that server hasn't been
  /// registered via [registerServer] yet.
  static Dio instance(String serverId) {
    final dio = _clients[serverId];
    if (dio == null) {
      throw StateError(
        'ApiClient.registerServer() must be called for "$serverId" before '
        'ApiClient.instance("$serverId") is used.',
      );
    }
    return dio;
  }

  /// All currently registered server ids.
  static List<String> get registeredServerIds => _clients.keys.toList();

  static bool isRegistered(String serverId) => _clients.containsKey(serverId);

  /// Registers a server, creating a Dio instance for it with its own
  /// request/response interceptors for auth. Safe to call again for the
  /// same [serverId] (e.g. to update its baseUrl) — this replaces the
  /// existing client for that id.
  ///
  /// The base URL is resolved from the persisted server list (SharedPreferences
  /// via [ServerListService.lookup]) unless [baseUrl] is given explicitly —
  /// needed only for servers that haven't been persisted yet (e.g. a directory
  /// fetched from another server).
  static Future<void> registerServer({
    required String serverId,
    String? baseUrl,
    required VoidCallback onAuthFailure,
    Duration connectTimeout = const Duration(seconds: 5),
    Duration receiveTimeout = const Duration(seconds: 3),
  }) async {
    final resolvedBaseUrl = baseUrl ?? await _resolveServerUrl(serverId);

    _baseUrls[serverId] = resolvedBaseUrl;
    _onAuthFailureCallbacks[serverId] = onAuthFailure;

    final dio = Dio(
      BaseOptions(
        baseUrl: resolvedBaseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await getAccessToken(serverId);
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

          // Avoid infinite loop if the refresh-retry request itself gets a 401.
          final alreadyRetried = error.requestOptions.extra['retried'] == true;
          if (alreadyRetried) {
            await handleAuthFailure(serverId);
            handler.next(error);
            return;
          }

          try {
            final newAccessToken = await refreshAccessToken(serverId);

            if (newAccessToken == null) {
              await handleAuthFailure(serverId);
              handler.next(error);
              return;
            }

            // Retry the original request with the new token.
            final retryOptions = error.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            retryOptions.extra['retried'] = true;

            final response = await _clients[serverId]!.fetch(retryOptions);
            handler.resolve(response);
          } catch (_) {
            await handleAuthFailure(serverId);
            handler.next(error);
          }
        },
      ),
    );

    _clients[serverId] = dio;
  }

  /// Resolves a server's base URL from the persisted server list. Throws if
  /// the server isn't in the list (so the failure is loud in dev).
  static Future<String> _resolveServerUrl(String serverId) async {
    final server = await ServerListService.lookup(serverId);
    final url = server?.serverUrl;
    if (url == null || url.isEmpty) {
      throw StateError(
        'No URL stored for server "$serverId" in the server list. '
        'Register it via ServerListService first, or pass baseUrl explicitly.',
      );
    }
    return url;
  }

  /// Removes a server's client and its stored tokens entirely (e.g. when
  /// the user disconnects from that server / logs out of it specifically).
  static Future<void> unregisterServer(String serverId) async {
    _clients.remove(serverId);
    _baseUrls.remove(serverId);
    _onAuthFailureCallbacks.remove(serverId);
    _refreshCompleters.remove(serverId);
    await _storage.delete(key: _accessTokenKey(serverId));
    await _storage.delete(key: _refreshTokenKey(serverId));
  }

  // --- Token storage, scoped per server ---------------------------------

  static String _accessTokenKey(String serverId) => 'access_token_$serverId';
  static String _refreshTokenKey(String serverId) =>
      'refresh_token_$serverId';

  /// Reads [serverId]'s access token from secure storage, or null if not
  /// signed in to that server.
  static Future<String?> getAccessToken(String serverId) =>
      _storage.read(key: _accessTokenKey(serverId));

  /// Reads [serverId]'s refresh token from secure storage, or null.
  static Future<String?> getRefreshToken(String serverId) =>
      _storage.read(key: _refreshTokenKey(serverId));

  /// Stores an access/refresh token pair for [serverId] — call this after
  /// login, or anywhere else you obtain fresh tokens for a server.
  static Future<void> saveTokens({
    required String serverId,
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey(serverId), value: accessToken);
    await _storage.write(
      key: _refreshTokenKey(serverId),
      value: refreshToken,
    );
  }

  /// Refreshes [serverId]'s access token via that server's `/api/refresh`
  /// endpoint, coalescing concurrent callers for the SAME server into a
  /// single network request. Returns the new access token, or null if the
  /// refresh failed (e.g. refresh token missing or expired).
  static Future<String?> refreshAccessToken(String serverId) async {
    final inFlight = _refreshCompleters[serverId];
    if (inFlight != null) {
      // A refresh for this server is already in flight — wait for it
      // instead of firing another.
      return inFlight.future;
    }

    final completer = Completer<String?>();
    _refreshCompleters[serverId] = completer;

    try {
      final refreshToken = await getRefreshToken(serverId);
      final baseUrl = _baseUrls[serverId];

      if (refreshToken == null || baseUrl == null) {
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
        serverId: serverId,
        accessToken: newAccessToken,
        refreshToken: newRefreshToken ?? refreshToken,
      );

      completer.complete(newAccessToken);
      return newAccessToken;
    } catch (_) {
      completer.complete(null);
      return null;
    } finally {
      _refreshCompleters.remove(serverId);
    }
  }

  /// Clears [serverId]'s stored tokens and invokes the onAuthFailure
  /// callback registered for that server (e.g. to send the user to login).
  static Future<void> handleAuthFailure(String serverId) async {
    await _storage.delete(key: _accessTokenKey(serverId));
    await _storage.delete(key: _refreshTokenKey(serverId));
    _onAuthFailureCallbacks[serverId]?.call();
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