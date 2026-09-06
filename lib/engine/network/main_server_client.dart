import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Shared Dio client for the single, stable main/authority server.
class MainServerClient {
  MainServerClient._();

  static Dio? _dio;

  /// Initializes the shared Dio instance using the `MAIN_SERVER_URL`
  /// environment variable (loaded via dotenv).
  ///
  /// Call this again any time you want to swap the base URL – it will
  /// re‑read the current value from the environment.
  static void init({
    Duration connectTimeout = const Duration(seconds: 5),
    Duration receiveTimeout = const Duration(seconds: 3),
  }) {
    final baseUrl = dotenv.env['MAIN_SERVER_URL'] ?? 'http://default';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {'Content-Type': 'application/json'},
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
}