import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _passwordVerifierKey = 'auth.password.verifier.v1';

const _secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(resetOnError: false),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
);

/// Stores only a salted one-way verifier for the password used by the local
/// account. The password itself is never persisted.
final class LocalPasswordVerifier {
  LocalPasswordVerifier._();

  static final _hashAlgorithm = Sha256();

  static Future<void> save(String password) async {
    final salt = Uint8List.fromList(
      List<int>.generate(32, (_) => Random.secure().nextInt(256)),
    );
    final digest = await _hash(password, salt);
    await _secureStorage.write(
      key: _passwordVerifierKey,
      value: '${base64UrlEncode(salt)}.${base64UrlEncode(digest.bytes)}',
    );
  }

  static Future<bool> verify(String password) async {
    final stored = await _secureStorage.read(key: _passwordVerifierKey);
    if (stored == null) return false;

    final parts = stored.split('.');
    if (parts.length != 2) return false;

    try {
      final salt = base64Url.decode(parts[0]);
      final expected = base64Url.decode(parts[1]);
      final actual = (await _hash(password, salt)).bytes;
      return _constantTimeEquals(actual, expected);
    } on FormatException {
      return false;
    }
  }

  static Future<void> delete() =>
      _secureStorage.delete(key: _passwordVerifierKey);

  static Future<Hash> _hash(String password, List<int> salt) {
    return _hashAlgorithm.hash([...salt, ...utf8.encode(password)]);
  }

  static bool _constantTimeEquals(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    var difference = 0;
    for (var index = 0; index < left.length; index++) {
      difference |= left[index] ^ right[index];
    }
    return difference == 0;
  }
}
