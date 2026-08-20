import 'dart:typed_data';

import 'crypto_types.dart';
import 'identity_crypto.dart';
import 'key_exchange.dart';
import 'message_crypto.dart';
import 'ratchet_store.dart';
import 'symmetric_ratchet.dart';

class NullCrypto {
  final IdentityCrypto identity;
  final RatchetStore ratchetStore;

  const NullCrypto({
    required this.identity,
    required this.ratchetStore,
  });

  // ------------------------------------------------------------
  // IDENTITY
  // ------------------------------------------------------------

  Future<void> createIdentityKey() {
    return identity.generateIdentityKey();
  }

  Future<Uint8List> getIdentityPublicKey() {
    return identity.loadPublicKey();
  }

  // ------------------------------------------------------------
  // INITIAL KEY EXCHANGE
  // ------------------------------------------------------------

  Future<DhKeyPair> createEphemeralKey() {
    return KeyExchange.generateEphemeralKeyPair();
  }

  Future<Uint8List> deriveSharedSecret({
    required Uint8List localEphemeralPrivateKey,
    required Uint8List peerEphemeralPublicKey,
  }) {
    return KeyExchange.deriveSharedSecret(
      localPrivateKey:
          localEphemeralPrivateKey,
      peerPublicKey:
          peerEphemeralPublicKey,
    );
  }

  Future<Uint8List> signExchange({
    required String conversationId,
    required String localIdentityId,
    required String peerIdentityId,
    required Uint8List localIdentityPublicKey,
    required Uint8List peerIdentityPublicKey,
    required Uint8List localEphemeralPublicKey,
    required Uint8List peerEphemeralPublicKey,
    required bool initiator,
  }) {
    return KeyExchange.signExchange(
      identity: identity,
      conversationId: conversationId,
      localIdentityId: localIdentityId,
      peerIdentityId: peerIdentityId,
      localIdentityPublicKey:
          localIdentityPublicKey,
      peerIdentityPublicKey:
          peerIdentityPublicKey,
      localEphemeralPublicKey:
          localEphemeralPublicKey,
      peerEphemeralPublicKey:
          peerEphemeralPublicKey,
      initiator: initiator,
    );
  }

  Future<bool> verifyExchange({
    required String conversationId,
    required String localIdentityId,
    required String peerIdentityId,
    required Uint8List localIdentityPublicKey,
    required Uint8List peerIdentityPublicKey,
    required Uint8List localEphemeralPublicKey,
    required Uint8List peerEphemeralPublicKey,
    required Uint8List signature,
    required bool peerWasInitiator,
  }) {
    return KeyExchange.verifyExchange(
      conversationId: conversationId,
      localIdentityId: localIdentityId,
      peerIdentityId: peerIdentityId,
      localIdentityPublicKey:
          localIdentityPublicKey,
      peerIdentityPublicKey:
          peerIdentityPublicKey,
      localEphemeralPublicKey:
          localEphemeralPublicKey,
      peerEphemeralPublicKey:
          peerEphemeralPublicKey,
      signature: signature,
      peerWasInitiator:
          peerWasInitiator,
    );
  }

  // ------------------------------------------------------------
  // RATchet INITIALIZATION
  // ------------------------------------------------------------

  Future<void> establishConversation({
    required String conversationId,
    required Uint8List sharedSecret,
    required bool initiator,
  }) async {
    final state =
        await SymmetricRatchet.initialize(
      sharedSecret: sharedSecret,
      initiator: initiator,
    );

    await ratchetStore.saveState(
      conversationId,
      state,
    );

    await ratchetStore.saveSkipped(
      conversationId,
      {},
    );
  }

  // ------------------------------------------------------------
  // ENCRYPT
  // ------------------------------------------------------------

  Future<EncryptedMessage> encryptMessage({
    required String conversationId,
    required String plaintext,
    required List<int> aad,
  }) async {
    final state =
        await ratchetStore.loadState(
      conversationId,
    );

    if (state == null) {
      throw StateError(
        'Conversation has no ratchet state.',
      );
    }

    final result =
        await SymmetricRatchet.nextSendingKey(
      state,
    );

    final messageKey = result.$1;
    final nextState = result.$2;

    final encrypted =
        await MessageCrypto.encrypt(
      messageKey: messageKey,
      plaintext: plaintext,
      aad: aad,
      chainIndex:
          state.sendingIndex,
    );

    await ratchetStore.saveState(
      conversationId,
      nextState,
    );

    return encrypted;
  }

  // ------------------------------------------------------------
  // DECRYPT
  // ------------------------------------------------------------

  Future<String> decryptMessage({
    required String conversationId,
    required int chainIndex,
    required Uint8List ciphertext,
    required Uint8List nonce,
    required Uint8List mac,
    required List<int> aad,
  }) async {
    final state =
        await ratchetStore.loadState(
      conversationId,
    );

    if (state == null) {
      throw StateError(
        'Conversation has no ratchet state.',
      );
    }

    final skipped =
        await ratchetStore.loadSkipped(
      conversationId,
    );

    final result =
        await SymmetricRatchet.receiveKey(
      state: state,
      targetIndex: chainIndex,
      skipped: skipped,
    );

    final plaintext =
        await MessageCrypto.decrypt(
      messageKey: result.messageKey,
      ciphertext: ciphertext,
      nonce: nonce,
      mac: mac,
      aad: aad,
    );

    // Only persist the advanced state after
    // successful authentication/decryption.
    await ratchetStore.saveState(
      conversationId,
      result.state,
    );

    await ratchetStore.saveSkipped(
      conversationId,
      result.skipped,
    );

    return plaintext;
  }

  Future<void> deleteConversation(
    String conversationId,
  ) {
    return ratchetStore.deleteConversation(
      conversationId,
    );
  }
}