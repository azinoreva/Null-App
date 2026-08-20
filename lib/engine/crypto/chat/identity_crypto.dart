import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class IdentityCrypto {
  static final Ed25519 _ed25519 = Ed25519();

  final FlutterSecureStorage storage;

  const IdentityCrypto({
    this.storage = const FlutterSecureStorage(),
  });

  static const _privateKeyName = 'identity:private_key';

  Future<void> generateIdentityKey() async {
    final pair = await _ed25519.newKeyPair();

    final privateKey =
        await pair.extractPrivateKeyBytes();

    await storage.write(
      key: _privateKeyName,
      value: base64UrlEncode(privateKey),
    );
  }

  Future<Uint8List?> loadPrivateKey() async {
    final value = await storage.read(
      key: _privateKeyName,
    );

    if (value == null) {
      return null;
    }

    return Uint8List.fromList(
      base64Url.decode(value),
    );
  }

  Future<Uint8List> loadPublicKey() async {
    final privateKey = await loadPrivateKey();

    if (privateKey == null) {
      throw StateError(
        'Identity private key does not exist.',
      );
    }

    final pair = SimpleKeyPairData(
      privateKey,
      type: KeyPairType.ed25519,
    );

    final publicKey = await pair.extractPublicKey();

    return Uint8List.fromList(publicKey.bytes);
  }

  Future<Uint8List> sign(List<int> data) async {
    final privateKey = await loadPrivateKey();

    if (privateKey == null) {
      throw StateError(
        'Identity private key does not exist.',
      );
    }

    final publicKey = SimplePublicKey(
      await loadPublicKey(),
      type: KeyPairType.ed25519,
    );

    final pair = SimpleKeyPairData(
      privateKey,
      publicKey: publicKey,
      type: KeyPairType.ed25519,
    );

    final signature = await _ed25519.sign(
      data,
      keyPair: pair,
    );

    return Uint8List.fromList(signature.bytes);
  }

  static Future<bool> verify({
    required List<int> data,
    required Uint8List signatureBytes,
    required Uint8List publicKeyBytes,
  }) async {
    if (publicKeyBytes.length != 32) {
      throw ArgumentError(
        'Ed25519 public key must be 32 bytes.',
      );
    }

    final publicKey = SimplePublicKey(
      publicKeyBytes,
      type: KeyPairType.ed25519,
    );

    final signature = Signature(
      signatureBytes,
      publicKey: publicKey,
    );

    return _ed25519.verify(
      data,
      signature: signature,
    );
  }
}