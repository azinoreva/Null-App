import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class NullPrimitives {
  static final X25519 x25519 = X25519();

  static final Ed25519 ed25519 = Ed25519();

  static final Hkdf hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

  static final Xchacha20Poly1305Aead aead = Xchacha20Poly1305Aead();

  static Future<SimpleKeyPair> generateDhKeyPair() {
    return x25519.newKeyPair();
  }

  static Future<SimpleKeyPair> generateIdentityKeyPair() {
    return ed25519.newKeyPair();
  }

  static Future<Uint8List> publicKeyBytes(SimpleKeyPair pair) async {
    final key = await pair.extract();

    return Uint8List.fromList(key.publicKey.bytes);
  }

  static Future<Uint8List> privateKeyBytes(SimpleKeyPair pair) async {
    final key = await pair.extract();

    return Uint8List.fromList(key.bytes);
  }

  static Future<Uint8List> dh({
    required Uint8List privateKey,
    required Uint8List publicKey,
  }) async {
    final pair = SimpleKeyPairData(
      privateKey,
      publicKey: SimplePublicKey(
        await _x25519PublicFromPrivate(privateKey),
        type: KeyPairType.x25519,
      ),
      type: KeyPairType.x25519,
    );

    final remote = SimplePublicKey(publicKey, type: KeyPairType.x25519);

    final secret = await x25519.sharedSecretKey(
      keyPair: pair,
      remotePublicKey: remote,
    );

    return Uint8List.fromList(await secret.extractBytes());
  }

  static Future<Uint8List> hkdfDerive({
    required Uint8List key,
    required String info,
  }) async {
    final result = await hkdf.deriveKey(
      secretKey: SecretKey(key),
      info: Uint8List.fromList(info.codeUnits),
    );

    return Uint8List.fromList(await result.extractBytes());
  }

  static Future<Uint8List> sign({
    required Uint8List privateKey,
    required Uint8List data,
  }) async {
    final pair = SimpleKeyPairData(privateKey, type: KeyPairType.ed25519);

    final signature = await ed25519.sign(data, keyPair: pair);

    return Uint8List.fromList(signature.bytes);
  }

  static Future<bool> verify({
    required Uint8List publicKey,
    required Uint8List signature,
    required Uint8List data,
  }) async {
    return ed25519.verify(
      data,
      signature: Signature(
        signature,
        publicKey: SimplePublicKey(publicKey, type: KeyPairType.ed25519),
      ),
    );
  }

  static Future<SecretBox> encrypt({
    required Uint8List key,
    required Uint8List plaintext,
    required Uint8List aad,
  }) {
    return aead.encrypt(plaintext, secretKey: SecretKey(key), aad: aad);
  }

  static Future<Uint8List> decrypt({
    required Uint8List key,
    required SecretBox box,
    required Uint8List aad,
  }) async {
    return Uint8List.fromList(
      await aead.decrypt(box, secretKey: SecretKey(key), aad: aad),
    );
  }

  static Future<Uint8List> _x25519PublicFromPrivate(
    Uint8List privateKey,
  ) async {
    final pair = await x25519.newKeyPairFromSeed(privateKey);

    return publicKeyBytes(pair);
  }
}
