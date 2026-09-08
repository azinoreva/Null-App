/// Thrown when the backend returns a 4xx or 5xx error response.
/// Carries the human-readable message from the response's "detail" field.
class ServerErrorException implements Exception {
  final String message;
  final int statusCode;

  ServerErrorException(this.message, {required this.statusCode});

  @override
  String toString() => message;
}
