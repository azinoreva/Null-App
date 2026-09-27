// module_name: dh_identity_crypto
//
// Long-term X25519 identity keys used for sealed-box "dh drop" key
// delivery. The matching public key is what the app shares in contact
// cards (identity.publicKey), so other clients can seal a DH drop to us.
// The private half never leaves secure storage.

import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DhIdentityCrypto {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _privateKeyName = 'identity:x25519_private_key';

  static const int _keyLength = 32;

  /// Returns the stored X25519 identity private key, generating and
  /// persisting a fresh one the first time it is called.
  static Future<Uint8List> ensurePrivateKey() async {
    final existing = await _storage.read(key: _privateKeyName);
    if (existing != null && existing.isNotEmpty) {
      return Uint8List.fromList(base64Url.decode(existing));
    }

    final pair = await X25519().newKeyPair();
    final privateKey = await pair.extractPrivateKeyBytes();
    await _storage.write(
      key: _privateKeyName,
      value: base64UrlEncode(privateKey),
    );
    return Uint8List.fromList(privateKey);
  }

  /// The stored X25519 identity private key. Throws when none exists yet —
  /// call [ensurePrivateKey] once at startup.
  static Future<Uint8List> loadPrivateKey() async {
    final existing = await _storage.read(key: _privateKeyName);
    if (existing == null || existing.isEmpty) {
      throw StateError('No X25519 identity key exists yet.');
    }
    return Uint8List.fromList(base64Url.decode(existing));
  }

  /// The X25519 identity public key matching the stored private key.
  static Future<Uint8List> loadPublicKey() async {
    final privateKey = await loadPrivateKey();
    return derivePublicKey(privateKey);
  }

  /// Derives the X25519 public key for [privateKey].
  static Future<Uint8List> derivePublicKey(Uint8List privateKey) async {
    if (privateKey.length != _keyLength) {
      throw ArgumentError('X25519 private key must be $_keyLength bytes.');
    }
    final pair = await X25519().newKeyPairFromSeed(privateKey);
    final publicKey = await pair.extractPublicKey();
    return Uint8List.fromList(publicKey.bytes);
  }
}