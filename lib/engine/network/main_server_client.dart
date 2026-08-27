import 'package:dio/dio.dart';

/// Shared Dio client for the single, stable main/authority server —
/// distinct from ApiClient's multi-server registry, since there's exactly
/// one main server, not a dynamic set of them.
///
/// Call [init] once at app startup; any service that talks to the main
/// server (registration, sign-in, etc.) reuses [dio] rather than each
/// creating its own client.
class MainServerClient {
  MainServerClient._();

  static Dio? _dio;

  static void init({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 5),
    Duration receiveTimeout = const Duration(seconds: 3),
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  static Dio get dio {
    final client = _dio;
    if (client == null) {
      throw StateError(
        'MainServerClient.init() must be called before use.',
      );
    }
    return client;
  }
}