
// module_name: identity_crypto
import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../database/app_database.dart';

class IdentityCrypto {
  static final Ed25519 _ed25519 = Ed25519();

  final FlutterSecureStorage storage;

  const IdentityCrypto({
    this.storage = const FlutterSecureStorage(),
  });

  static const _privateKeyName = 'identity:private_key';

  /// Ensures the local identity has both a usable private key in secure
  /// storage and the matching public key in the database.
  ///
  /// Registration creates the identity row before generating this keypair,
  /// so startup must repair rows whose [IdentityData.publicKey] is null.
  /// Returns false when no identity exists yet (for example, before signup).
  Future<bool> ensureIdentityKey({required AppDatabase database}) async {
    final identity = await database.identityDao.getCurrentIdentityOrNull();
    if (identity == null) return false;

    Uint8List publicKey;
    try {
      final privateKey = await loadPrivateKey();
      if (privateKey == null || privateKey.length != 32) {
        throw StateError('Identity private key is missing or invalid.');
      }
      publicKey = await loadPublicKey();
    } catch (_) {
      await generateIdentityKey(database: database);
      return true;
    }

    final encodedPublicKey = base64UrlEncode(publicKey);
    if (identity.publicKey != encodedPublicKey) {
      await database.identityDao.setPublicKey(encodedPublicKey);
    }
    return true;
  }

  Future<void> generateIdentityKey({AppDatabase? database}) async {
    final pair = await _ed25519.newKeyPair();

    final privateKey = await pair.extractPrivateKeyBytes();
    final publicKey = await pair.extractPublicKey();

    await storage.write(
      key: _privateKeyName,
      value: base64UrlEncode(privateKey),
    );

    if (database != null) {
      final current = await database.identityDao.getCurrentIdentityOrNull();

      if (current != null) {
        await database.identityDao.setPublicKey(
          base64UrlEncode(publicKey.bytes),
        );
      }
    }
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

    final pair = await _ed25519.newKeyPairFromSeed(privateKey);

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