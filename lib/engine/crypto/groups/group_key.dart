import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// Generates and validates symmetric group encryption keys.
///
/// Group keys are 256-bit random values.
///
/// These are the keys stored in the encrypted SQLite database:
///
///   K1
///   K2
///   K3
///   ...
class GroupKey {
  GroupKey._();

  static final AesGcm _cipher = AesGcm.with256bits();

  /// Generate a new random 256-bit group key.
  static Future<String> generate() async {
    final key = await _cipher.newSecretKey();
    final bytes = await key.extractBytes();

    return base64UrlEncode(bytes);
  }

  /// Convert a stored group key into a SecretKey.
  static SecretKey fromBase64(String encoded) {
    final bytes = base64Url.decode(encoded);

    if (bytes.length != 32) {
      throw FormatException(
        'Group key must contain exactly 32 bytes.',
      );
    }

    return SecretKey(bytes);
  }

  /// Validate a stored group key.
  static bool isValid(String encoded) {
    try {
      final bytes = base64Url.decode(encoded);
      return bytes.length == 32;
    } catch (_) {
      return false;
    }
  }
}