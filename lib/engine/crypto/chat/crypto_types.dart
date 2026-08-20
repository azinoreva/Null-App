import 'dart:typed_data';

class DhKeyPair {
  final Uint8List privateKey;
  final Uint8List publicKey;

  const DhKeyPair({
    required this.privateKey,
    required this.publicKey,
  });
}

class RatchetState {
  final Uint8List rootKey;
  final Uint8List sendingChainKey;
  final Uint8List receivingChainKey;

  /// Number of messages already consumed from our sending chain.
  final int sendingIndex;

  /// Number of messages already consumed from our receiving chain.
  final int receivingIndex;

  const RatchetState({
    required this.rootKey,
    required this.sendingChainKey,
    required this.receivingChainKey,
    required this.sendingIndex,
    required this.receivingIndex,
  });

  RatchetState copyWith({
    Uint8List? rootKey,
    Uint8List? sendingChainKey,
    Uint8List? receivingChainKey,
    int? sendingIndex,
    int? receivingIndex,
  }) {
    return RatchetState(
      rootKey: rootKey ?? this.rootKey,
      sendingChainKey:
          sendingChainKey ?? this.sendingChainKey,
      receivingChainKey:
          receivingChainKey ?? this.receivingChainKey,
      sendingIndex:
          sendingIndex ?? this.sendingIndex,
      receivingIndex:
          receivingIndex ?? this.receivingIndex,
    );
  }
}

class KeyExchangeResult {
  final Uint8List ephemeralPrivateKey;
  final Uint8List ephemeralPublicKey;
  final Uint8List sharedSecret;

  const KeyExchangeResult({
    required this.ephemeralPrivateKey,
    required this.ephemeralPublicKey,
    required this.sharedSecret,
  });
}

class SignedKeyExchange {
  final Uint8List ephemeralPublicKey;
  final Uint8List signature;

  const SignedKeyExchange({
    required this.ephemeralPublicKey,
    required this.signature,
  });
}

class EncryptedMessage {
  final Uint8List ciphertext;
  final Uint8List nonce;
  final Uint8List mac;
  final int chainIndex;

  const EncryptedMessage({
    required this.ciphertext,
    required this.nonce,
    required this.mac,
    required this.chainIndex,
  });
}