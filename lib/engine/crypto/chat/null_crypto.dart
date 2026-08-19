import 'dart:typed_data';

import 'null_handshake.dart';
import 'null_models.dart';
import 'null_ratchet.dart';

class NullCrypto {
  static Future<NullIdentity> createIdentity() {
    return NullHandshake.generateIdentity();
  }

  static Future<NullConversationState> initializeConversation({
    required Uint8List peerIdentityPublicKey,
    required Uint8List myRatchetPrivateKey,
    required Uint8List myRatchetPublicKey,
    required Uint8List peerRatchetPublicKey,
    required Uint8List sharedSecret,
    required bool initiator,
  }) {
    return NullRatchet.initialize(
      peerIdentityPublicKey: peerIdentityPublicKey,
      myRatchetPrivateKey: myRatchetPrivateKey,
      myRatchetPublicKey: myRatchetPublicKey,
      peerRatchetPublicKey: peerRatchetPublicKey,
      sharedSecret: sharedSecret,
      initiator: initiator,
    );
  }

  static Future<NullRatchetResult> encrypt({
    required NullConversationState state,
    required Uint8List plaintext,
    Uint8List? associatedData,
  }) {
    return NullRatchet.encrypt(
      state: state,
      plaintext: plaintext,
      associatedData: associatedData ?? Uint8List(0),
    );
  }

  static Future<NullRatchetResult> decrypt({
    required NullConversationState state,
    required NullEncryptedMessage message,
    Uint8List? associatedData,
  }) {
    return NullRatchet.decrypt(
      state: state,
      message: message,
      associatedData: associatedData ?? Uint8List(0),
    );
  }

  static Future<Uint8List> signRatchetKey({
    required Uint8List identityPrivateKey,
    required Uint8List ratchetPublicKey,
  }) {
    return NullHandshake.signRatchetKey(
      identityPrivateKey: identityPrivateKey,
      ratchetPublicKey: ratchetPublicKey,
    );
  }

  static Future<bool> verifyRatchetKey({
    required Uint8List identityPublicKey,
    required Uint8List ratchetPublicKey,
    required Uint8List signature,
  }) {
    return NullHandshake.verifyRatchetKey(
      identityPublicKey: identityPublicKey,
      ratchetPublicKey: ratchetPublicKey,
      signature: signature,
    );
  }
}
