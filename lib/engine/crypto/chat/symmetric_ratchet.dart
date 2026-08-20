import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'crypto_types.dart';

class SymmetricRatchet {
  static final Hkdf _hkdf = Hkdf(
    hmac: Hmac.sha256(),
    outputLength: 32,
  );

  static const int maxSkippedKeys = 100;

  static Future<RatchetState> initialize({
    required Uint8List sharedSecret,
    required bool initiator,
  }) async {
    final root = await _derive(
      sharedSecret,
      'NULL/v1/root',
    );

    final initiatorChain = await _derive(
      root,
      'NULL/v1/initiator-chain',
    );

    final responderChain = await _derive(
      root,
      'NULL/v1/responder-chain',
    );

    return RatchetState(
      rootKey: root,
      sendingChainKey:
          initiator ? initiatorChain : responderChain,
      receivingChainKey:
          initiator ? responderChain : initiatorChain,
      sendingIndex: 0,
      receivingIndex: 0,
    );
  }

  static Future<(Uint8List, RatchetState)>
      nextSendingKey(
    RatchetState state,
  ) async {
    final messageKey = await _derive(
      state.sendingChainKey,
      'NULL/v1/message',
    );

    final nextChain = await _derive(
      state.sendingChainKey,
      'NULL/v1/chain',
    );

    return (
      messageKey,
      state.copyWith(
        sendingChainKey: nextChain,
        sendingIndex: state.sendingIndex + 1,
      ),
    );
  }

  /// Advances the receive chain until [targetIndex].
  ///
  /// Keys skipped along the way are returned for temporary storage.
  static Future<ReceiveResult> receiveKey({
    required RatchetState state,
    required int targetIndex,
    required Map<int, Uint8List> skipped,
  }) async {
    if (targetIndex < 0) {
      throw ArgumentError(
        'Chain index cannot be negative.',
      );
    }

    // The message is older than the current receive state.
    if (targetIndex < state.receivingIndex) {
      final key = skipped.remove(targetIndex);

      if (key == null) {
        throw StateError(
          'Message key is unavailable for chain index $targetIndex.',
        );
      }

      return ReceiveResult(
        messageKey: key,
        state: state,
        skipped: skipped,
      );
    }

    final distance =
        targetIndex - state.receivingIndex;

    if (distance >= maxSkippedKeys) {
      throw StateError(
        'Incoming message is too far ahead of the receive chain.',
      );
    }

    var chainKey = state.receivingChainKey;
    var currentIndex = state.receivingIndex;

    final updatedSkipped =
        Map<int, Uint8List>.from(skipped);

    while (currentIndex <= targetIndex) {
      final messageKey = await _derive(
        chainKey,
        'NULL/v1/message',
      );

      final nextChain = await _derive(
        chainKey,
        'NULL/v1/chain',
      );

      if (currentIndex == targetIndex) {
        return ReceiveResult(
          messageKey: messageKey,
          state: state.copyWith(
            receivingChainKey: nextChain,
            receivingIndex: currentIndex + 1,
          ),
          skipped: updatedSkipped,
        );
      }

      updatedSkipped[currentIndex] =
          messageKey;

      if (updatedSkipped.length >
          maxSkippedKeys) {
        throw StateError(
          'Skipped-message-key limit exceeded.',
        );
      }

      chainKey = nextChain;
      currentIndex++;
    }

    throw StateError(
      'Unable to derive receiving key.',
    );
  }

  static Future<Uint8List> _derive(
    List<int> secret,
    String info,
  ) async {
    final result = await _hkdf.deriveKey(
      secretKey: SecretKey(secret),
      info: utf8.encode(info),
    );

    return Uint8List.fromList(
      await result.extractBytes(),
    );
  }
}

class ReceiveResult {
  final Uint8List messageKey;
  final RatchetState state;
  final Map<int, Uint8List> skipped;

  const ReceiveResult({
    required this.messageKey,
    required this.state,
    required this.skipped,
  });
}