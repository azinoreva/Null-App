import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'crypto_types.dart';
import 'identity_crypto.dart';

class KeyExchange {
  static final X25519 _x25519 = X25519();

  /// Generates an ephemeral X25519 keypair.
  static Future<DhKeyPair> generateEphemeralKeyPair() async {
    final pair = await _x25519.newKeyPair();

    final privateKey =
        await pair.extractPrivateKeyBytes();

    final publicKey =
        await pair.extractPublicKey();

    return DhKeyPair(
      privateKey: Uint8List.fromList(privateKey),
      publicKey: Uint8List.fromList(publicKey.bytes),
    );
  }

  /// Creates the exact bytes that are signed.
  ///
  /// Both sides MUST construct this identically.
  static List<int> buildTranscript({
    required String conversationId,
    required String localIdentityId,
    required String peerIdentityId,
    required Uint8List localIdentityPublicKey,
    required Uint8List peerIdentityPublicKey,
    required Uint8List localEphemeralPublicKey,
    required Uint8List peerEphemeralPublicKey,
    required bool initiator,
  }) {
    return utf8.encode(
      [
        'NULL',
        '1',
        conversationId,
        localIdentityId,
        peerIdentityId,
        base64UrlEncode(localIdentityPublicKey),
        base64UrlEncode(peerIdentityPublicKey),
        base64UrlEncode(localEphemeralPublicKey),
        base64UrlEncode(peerEphemeralPublicKey),
        initiator ? 'initiator' : 'responder',
      ].join('|'),
    );
  }

  /// Signs the local side of the exchange.
  static Future<Uint8List> signExchange({
    required IdentityCrypto identity,
    required String conversationId,
    required String localIdentityId,
    required String peerIdentityId,
    required Uint8List localIdentityPublicKey,
    required Uint8List peerIdentityPublicKey,
    required Uint8List localEphemeralPublicKey,
    required Uint8List peerEphemeralPublicKey,
    required bool initiator,
  }) async {
    final transcript = buildTranscript(
      conversationId: conversationId,
      localIdentityId: localIdentityId,
      peerIdentityId: peerIdentityId,
      localIdentityPublicKey: localIdentityPublicKey,
      peerIdentityPublicKey: peerIdentityPublicKey,
      localEphemeralPublicKey: localEphemeralPublicKey,
      peerEphemeralPublicKey: peerEphemeralPublicKey,
      initiator: initiator,
    );

    return identity.sign(transcript);
  }

  /// Verifies the peer's identity signature.
  static Future<bool> verifyExchange({
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
    final transcript = buildTranscript(
      conversationId: conversationId,
      localIdentityId: peerIdentityId,
      peerIdentityId: localIdentityId,
      localIdentityPublicKey: peerIdentityPublicKey,
      peerIdentityPublicKey: localIdentityPublicKey,
      localEphemeralPublicKey: peerEphemeralPublicKey,
      peerEphemeralPublicKey: localEphemeralPublicKey,
      initiator: peerWasInitiator,
    );

    return IdentityCrypto.verify(
      data: transcript,
      signatureBytes: signature,
      publicKeyBytes: peerIdentityPublicKey,
    );
  }

  static Future<Uint8List> deriveSharedSecret({
    required Uint8List localPrivateKey,
    required Uint8List peerPublicKey,
  }) async {
    final localPublic =
        await _derivePublicKey(localPrivateKey);

    final localPair = SimpleKeyPairData(
      localPrivateKey,
      publicKey: localPublic,
      type: KeyPairType.x25519,
    );

    final remotePublic = SimplePublicKey(
      peerPublicKey,
      type: KeyPairType.x25519,
    );

    final secret = await _x25519.sharedSecretKey(
      keyPair: localPair,
      remotePublicKey: remotePublic,
    );

    return Uint8List.fromList(
      await secret.extractBytes(),
    );
  }

  static Future<SimplePublicKey> _derivePublicKey(
    Uint8List privateKey,
  ) async {
    final pair = await _x25519.newKeyPairFromSeed(
      privateKey,
    );

    return await pair.extractPublicKey();
  }
}