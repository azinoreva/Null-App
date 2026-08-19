import 'dart:typed_data';

class NullIdentity {
  final Uint8List signingPublicKey;
  final Uint8List signingPrivateKey;

  const NullIdentity({
    required this.signingPublicKey,
    required this.signingPrivateKey,
  });
}

class NullPreKeyBundle {
  final Uint8List identityPublicKey;

  final Uint8List signedPreKeyPublicKey;
  final Uint8List signedPreKeySignature;

  final List<NullOneTimePreKey> oneTimePreKeys;

  const NullPreKeyBundle({
    required this.identityPublicKey,
    required this.signedPreKeyPublicKey,
    required this.signedPreKeySignature,
    required this.oneTimePreKeys,
  });
}

class NullOneTimePreKey {
  final String id;
  final Uint8List publicKey;

  const NullOneTimePreKey({required this.id, required this.publicKey});
}

class NullConversationState {
  final int version;

  // Identity
  final Uint8List peerIdentityPublicKey;

  // Double Ratchet
  final Uint8List dhsPrivateKey;
  final Uint8List dhsPublicKey;
  final Uint8List dhrPublicKey;

  final Uint8List rootKey;

  final Uint8List? sendingChainKey;
  final Uint8List? receivingChainKey;

  final int sendMessageNumber;
  final int receiveMessageNumber;

  /// PN in the Double Ratchet specification.
  final int previousSendingChainLength;

  /// Skipped message keys.
  ///
  /// Key format:
  ///     base64(ratchetPublicKey):messageNumber
  ///
  /// Value:
  ///     message key
  final Map<String, Uint8List> skippedMessageKeys;

  /// Monotonic local state version.
  ///
  /// This is for persistence/rollback detection.
  final int stateVersion;

  /// Hash of the previous committed state.
  final Uint8List? previousStateHash;

  const NullConversationState({
    required this.version,
    required this.peerIdentityPublicKey,
    required this.dhsPrivateKey,
    required this.dhsPublicKey,
    required this.dhrPublicKey,
    required this.rootKey,
    required this.sendingChainKey,
    required this.receivingChainKey,
    required this.sendMessageNumber,
    required this.receiveMessageNumber,
    required this.previousSendingChainLength,
    required this.skippedMessageKeys,
    required this.stateVersion,
    required this.previousStateHash,
  });

  NullConversationState copyWith({
    Uint8List? dhsPrivateKey,
    Uint8List? dhsPublicKey,
    Uint8List? dhrPublicKey,
    Uint8List? rootKey,
    Uint8List? sendingChainKey,
    Uint8List? receivingChainKey,
    int? sendMessageNumber,
    int? receiveMessageNumber,
    int? previousSendingChainLength,
    Map<String, Uint8List>? skippedMessageKeys,
    int? stateVersion,
    Uint8List? previousStateHash,
  }) {
    return NullConversationState(
      version: version,
      peerIdentityPublicKey: peerIdentityPublicKey,
      dhsPrivateKey: dhsPrivateKey ?? this.dhsPrivateKey,
      dhsPublicKey: dhsPublicKey ?? this.dhsPublicKey,
      dhrPublicKey: dhrPublicKey ?? this.dhrPublicKey,
      rootKey: rootKey ?? this.rootKey,
      sendingChainKey: sendingChainKey ?? this.sendingChainKey,
      receivingChainKey: receivingChainKey ?? this.receivingChainKey,
      sendMessageNumber: sendMessageNumber ?? this.sendMessageNumber,
      receiveMessageNumber: receiveMessageNumber ?? this.receiveMessageNumber,
      previousSendingChainLength:
          previousSendingChainLength ?? this.previousSendingChainLength,
      skippedMessageKeys: skippedMessageKeys ?? this.skippedMessageKeys,
      stateVersion: stateVersion ?? this.stateVersion,
      previousStateHash: previousStateHash ?? this.previousStateHash,
    );
  }
}

class NullMessageHeader {
  final Uint8List ratchetPublicKey;
  final int previousChainLength;
  final int messageNumber;

  const NullMessageHeader({
    required this.ratchetPublicKey,
    required this.previousChainLength,
    required this.messageNumber,
  });
}

class NullEncryptedMessage {
  final NullMessageHeader header;
  final Uint8List nonce;
  final Uint8List ciphertext;

  const NullEncryptedMessage({
    required this.header,
    required this.nonce,
    required this.ciphertext,
  });
}

class NullRatchetResult {
  final NullConversationState state;
  final NullEncryptedMessage? message;
  final Uint8List? plaintext;

  const NullRatchetResult({required this.state, this.message, this.plaintext});
}
