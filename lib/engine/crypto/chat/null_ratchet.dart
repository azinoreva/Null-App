import 'dart:convert';
import 'dart:typed_data';

import 'null_models.dart';
import 'null_primitives.dart';

class NullRatchet {
  static const int maxSkip = 200;

  static Future<NullConversationState> initialize({
    required Uint8List peerIdentityPublicKey,
    required Uint8List myRatchetPrivateKey,
    required Uint8List myRatchetPublicKey,
    required Uint8List peerRatchetPublicKey,
    required Uint8List sharedSecret,
    required bool initiator,
  }) async {
    final rootKey = await NullPrimitives.hkdfDerive(
      key: sharedSecret,
      info: 'NULL/v1/root',
    );

    final first = await _kdfRoot(
      rootKey,
      await NullPrimitives.dh(
        privateKey: myRatchetPrivateKey,
        publicKey: peerRatchetPublicKey,
      ),
    );

    final second = await _kdfRoot(
      first.rootKey,
      await NullPrimitives.dh(
        privateKey: myRatchetPrivateKey,
        publicKey: peerRatchetPublicKey,
      ),
    );

    final sending = initiator ? second.chainKey : null;

    final receiving = initiator ? null : second.chainKey;

    return NullConversationState(
      version: 1,
      peerIdentityPublicKey: Uint8List.fromList(peerIdentityPublicKey),
      dhsPrivateKey: Uint8List.fromList(myRatchetPrivateKey),
      dhsPublicKey: Uint8List.fromList(myRatchetPublicKey),
      dhrPublicKey: Uint8List.fromList(peerRatchetPublicKey),
      rootKey: second.rootKey,
      sendingChainKey: sending,
      receivingChainKey: receiving,
      sendMessageNumber: 0,
      receiveMessageNumber: 0,
      previousSendingChainLength: 0,
      skippedMessageKeys: {},
      stateVersion: 1,
      previousStateHash: null,
    );
  }

  static Future<NullRatchetResult> encrypt({
    required NullConversationState state,
    required Uint8List plaintext,
    required Uint8List associatedData,
  }) async {
    if (state.sendingChainKey == null) {
      throw StateError('No sending chain exists.');
    }

    final step = await _kdfChain(state.sendingChainKey!);

    final header = NullMessageHeader(
      ratchetPublicKey: Uint8List.fromList(state.dhsPublicKey),
      previousChainLength: state.previousSendingChainLength,
      messageNumber: state.sendMessageNumber,
    );

    final encodedHeader = _encodeHeader(header);

    final aad = Uint8List.fromList([...associatedData, ...encodedHeader]);

    final box = await NullPrimitives.encrypt(
      key: step.messageKey,
      plaintext: plaintext,
      aad: aad,
    );

    final newState = state.copyWith(
      sendingChainKey: step.nextChainKey,
      sendMessageNumber: state.sendMessageNumber + 1,
    );

    return NullRatchetResult(
      state: newState,
      message: NullEncryptedMessage(
        header: header,
        nonce: Uint8List.fromList(box.nonce),
        ciphertext: Uint8List.fromList(box.cipherText),
      ),
    );
  }

  static Future<NullRatchetResult> decrypt({
    required NullConversationState state,
    required NullEncryptedMessage message,
    required Uint8List associatedData,
  }) async {
    // ------------------------------------------------------------
    // 1. Check skipped message keys first.
    // ------------------------------------------------------------

    final skippedId = _skippedId(
      message.header.ratchetPublicKey,
      message.header.messageNumber,
    );

    final skippedKey = state.skippedMessageKeys[skippedId];

    if (skippedKey != null) {
      final aad = Uint8List.fromList([
        ...associatedData,
        ..._encodeHeader(message.header),
      ]);

      final plaintext = await _decrypt(
        key: skippedKey,
        message: message,
        aad: aad,
      );

      final updatedSkipped = Map<String, Uint8List>.from(
        state.skippedMessageKeys,
      )..remove(skippedId);

      return NullRatchetResult(
        state: state.copyWith(skippedMessageKeys: updatedSkipped),
        plaintext: plaintext,
      );
    }

    var current = state;

    // ------------------------------------------------------------
    // 2. New DH ratchet key?
    // ------------------------------------------------------------

    final newRatchet = !_equal(
      message.header.ratchetPublicKey,
      current.dhrPublicKey,
    );

    if (newRatchet) {
      current = await _skipMessages(
        current,
        message.header.previousChainLength,
      );

      current = await _dhRatchet(current, message.header.ratchetPublicKey);
    }

    // ------------------------------------------------------------
    // 3. Skip messages within the current receiving chain.
    // ------------------------------------------------------------

    current = await _skipMessages(current, message.header.messageNumber);

    if (current.receivingChainKey == null) {
      throw StateError('Receiving chain does not exist.');
    }

    // ------------------------------------------------------------
    // 4. Derive message key.
    // ------------------------------------------------------------

    final step = await _kdfChain(current.receivingChainKey!);

    final aad = Uint8List.fromList([
      ...associatedData,
      ..._encodeHeader(message.header),
    ]);

    final plaintext = await _decrypt(
      key: step.messageKey,
      message: message,
      aad: aad,
    );

    current = current.copyWith(
      receivingChainKey: step.nextChainKey,
      receiveMessageNumber: current.receiveMessageNumber + 1,
    );

    return NullRatchetResult(state: current, plaintext: plaintext);
  }

  static Future<NullConversationState> _skipMessages(
    NullConversationState state,
    int until,
  ) async {
    if (state.receivingChainKey == null) {
      return state;
    }

    if (state.receiveMessageNumber + maxSkip < until) {
      throw StateError('MAX_SKIP exceeded.');
    }

    var chain = state.receivingChainKey!;

    var number = state.receiveMessageNumber;

    final skipped = Map<String, Uint8List>.from(state.skippedMessageKeys);

    while (number < until) {
      final step = await _kdfChain(chain);

      skipped[_skippedId(state.dhrPublicKey, number)] = step.messageKey;

      chain = step.nextChainKey;
      number++;
    }

    if (skipped.length > maxSkip) {
      throw StateError('Skipped-message key store exceeded limit.');
    }

    return state.copyWith(
      receivingChainKey: chain,
      receiveMessageNumber: number,
      skippedMessageKeys: skipped,
    );
  }

  static Future<NullConversationState> _dhRatchet(
    NullConversationState state,
    Uint8List remotePublicKey,
  ) async {
    final dh1 = await NullPrimitives.dh(
      privateKey: state.dhsPrivateKey,
      publicKey: remotePublicKey,
    );

    final first = await _kdfRoot(state.rootKey, dh1);

    final newPair = await NullPrimitives.generateDhKeyPair();

    final newPrivate = await NullPrimitives.privateKeyBytes(newPair);

    final newPublic = await NullPrimitives.publicKeyBytes(newPair);

    final dh2 = await NullPrimitives.dh(
      privateKey: newPrivate,
      publicKey: remotePublicKey,
    );

    final second = await _kdfRoot(first.rootKey, dh2);

    return state.copyWith(
      dhsPrivateKey: newPrivate,
      dhsPublicKey: newPublic,
      dhrPublicKey: Uint8List.fromList(remotePublicKey),
      rootKey: second.rootKey,
      receivingChainKey: first.chainKey,
      sendingChainKey: second.chainKey,
      previousSendingChainLength: state.sendMessageNumber,
      sendMessageNumber: 0,
      receiveMessageNumber: 0,
    );
  }

  static Future<_RootStep> _kdfRoot(Uint8List root, Uint8List dhOutput) async {
    final combined = Uint8List.fromList([...root, ...dhOutput]);

    final newRoot = await NullPrimitives.hkdfDerive(
      key: combined,
      info: 'NULL/v1/root-ratchet',
    );

    final chain = await NullPrimitives.hkdfDerive(
      key: newRoot,
      info: 'NULL/v1/chain',
    );

    return _RootStep(rootKey: newRoot, chainKey: chain);
  }

  static Future<_ChainStep> _kdfChain(Uint8List chainKey) async {
    final messageKey = await NullPrimitives.hkdfDerive(
      key: chainKey,
      info: 'NULL/v1/message',
    );

    final next = await NullPrimitives.hkdfDerive(
      key: chainKey,
      info: 'NULL/v1/chain',
    );

    return _ChainStep(messageKey: messageKey, nextChainKey: next);
  }

  static Future<Uint8List> _decrypt({
    required Uint8List key,
    required NullEncryptedMessage message,
    required Uint8List aad,
  }) {
    final box = SecretBox(
      message.ciphertext,
      nonce: message.nonce,
      mac: Mac.empty,
    );

    return NullPrimitives.decrypt(key: key, box: box, aad: aad);
  }

  static String _skippedId(Uint8List ratchetKey, int messageNumber) {
    return '${base64UrlEncode(ratchetKey)}:$messageNumber';
  }

  static Uint8List _encodeHeader(NullMessageHeader header) {
    final json = jsonEncode({
      'dh': base64UrlEncode(header.ratchetPublicKey),
      'pn': header.previousChainLength,
      'n': header.messageNumber,
    });

    return Uint8List.fromList(utf8.encode(json));
  }

  static bool _equal(List<int> a, List<int> b) {
    if (a.length != b.length) {
      return false;
    }

    var result = 0;

    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }

    return result == 0;
  }
}

class _ChainStep {
  final Uint8List messageKey;
  final Uint8List nextChainKey;

  const _ChainStep({required this.messageKey, required this.nextChainKey});
}

class _RootStep {
  final Uint8List rootKey;
  final Uint8List chainKey;

  const _RootStep({required this.rootKey, required this.chainKey});
}
