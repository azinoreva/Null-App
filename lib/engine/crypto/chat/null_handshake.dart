import 'dart:typed_data';

import 'null_models.dart';
import 'null_primitives.dart';

class NullHandshake {
  static Future<NullIdentity> generateIdentity() async {
    final pair = await NullPrimitives.generateIdentityKeyPair();

    return NullIdentity(
      signingPublicKey: await NullPrimitives.publicKeyBytes(pair),
      signingPrivateKey: await NullPrimitives.privateKeyBytes(pair),
    );
  }

  static Future<Uint8List> signRatchetKey({
    required Uint8List identityPrivateKey,
    required Uint8List ratchetPublicKey,
  }) {
    return NullPrimitives.sign(
      privateKey: identityPrivateKey,
      data: ratchetPublicKey,
    );
  }

  static Future<bool> verifyRatchetKey({
    required Uint8List identityPublicKey,
    required Uint8List ratchetPublicKey,
    required Uint8List signature,
  }) {
    return NullPrimitives.verify(
      publicKey: identityPublicKey,
      signature: signature,
      data: ratchetPublicKey,
    );
  }
}
