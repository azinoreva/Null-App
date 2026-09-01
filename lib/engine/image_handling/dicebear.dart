import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';

/// Holds both the raw image bytes and its Base64 representation.
class AvatarData {
  final Uint8List bytes;
  final String base64;

  AvatarData(this.bytes) : base64 = base64Encode(bytes);
}

/// Service that fetches avatar images from the Dicebear API.
class DicebearService {
  static const String _baseUrl = 'https://api.dicebear.com/7.x/avataaars/png';

  /// Fetches an avatar for the given [seed] and returns both bytes and Base64.
  ///
  /// You can customise the avatar with optional parameters (size, background, etc.).
  /// See: https://www.dicebear.com/how-to-use/http-api/
  Future<AvatarData> getAvatarData(
    String seed, {
    int size = 256,
    String? backgroundColor,
    // Add more parameters as needed, e.g.:
    // bool? flip,
    // String? hairColor,
  }) async {
    final queryParams = <String, String>{
      'seed': seed,
      'size': size.toString(),
    };
    if (backgroundColor != null) {
      queryParams['backgroundColor'] = backgroundColor;
    }
    // Append other options here...

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return AvatarData(response.bodyBytes);
    } else {
      throw Exception('Failed to load avatar: ${response.statusCode}');
    }
  }
}