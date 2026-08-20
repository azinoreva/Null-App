import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// An encrypted copy of a group key intended for one member.
///
/// The envelope contains the ephemeral X25519 public key needed by
/// the recipient to derive the same wrapping key.
///
/// The group key itself is never transmitted in plaintext.
class GroupKeyEnvelope {
  final String recipientId;
  final String ephemeralPublicKey;
  final String nonce;
  final String ciphertext;
  final String mac;

  const GroupKeyEnvelope({
    required this.recipientId,
    required this.ephemeralPublicKey,
    required this.nonce,
    required this.ciphertext,
    required this.mac,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipientId': recipientId,
      'ephemeralPublicKey': ephemeralPublicKey,
      'nonce': nonce,
      'ciphertext': ciphertext,
      'mac': mac,
    };
  }

  factory GroupKeyEnvelope.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroupKeyEnvelope(
      recipientId: json['recipientId'] as String,
      ephemeralPublicKey: json['ephemeralPublicKey'] as String,
      nonce: json['nonce'] as String,
      ciphertext: json['ciphertext'] as String,
      mac: json['mac'] as String,
    );
  }
}

class GroupKeyEnvelopeCrypto {
  GroupKeyEnvelopeCrypto._();

  static final X25519 _x25519 = X25519();

  static final Hkdf _hkdf = Hkdf(
    hmac: Hmac.sha256(),
    outputLength: 32,
  );

  static final AesGcm _aes = AesGcm.with256bits();

  static const List<int> _info = [
    ...utf8.encode('NULL-GROUP-KEY-WRAP-v1'),
  ];

  /// Encrypt a group key specifically for one recipient.
  ///
  /// [recipientPublicKey] is the recipient's X25519 public key.
  static Future<GroupKeyEnvelope> encryptForMember({
    required String recipientId,
    required List<int> recipientPublicKey,
    required String groupKey,
  }) async {
    if (recipientPublicKey.length != 32) {
      throw ArgumentError(
        'X25519 public key must contain 32 bytes.',
      );
    }

    final groupKeyBytes = base64Url.decode(groupKey);

    if (groupKeyBytes.length != 32) {
      throw ArgumentError(
        'Group key must contain 32 bytes.',
      );
    }

    final recipientKey = SimplePublicKey(
      recipientPublicKey,
      type: KeyPairType.x25519,
    );

    final ephemeralPair = await _x25519.newKeyPair();

    final sharedSecret = await _x25519.sharedSecretKey(
      keyPair: ephemeralPair,
      remotePublicKey: recipientKey,
    );

    final wrappingKey = await _hkdf.deriveKey(
      secretKey: sharedSecret,
      info: _info,
    );

    final nonce = _aes.newNonce();

    final box = await _aes.encrypt(
      groupKeyBytes,
      secretKey: wrappingKey,
      nonce: nonce,
    );

    final ephemeralPublic =
        await ephemeralPair.extractPublicKey();

    return GroupKeyEnvelope(
      recipientId: recipientId,
      ephemeralPublicKey:
          base64UrlEncode(ephemeralPublic.bytes),
      nonce: base64UrlEncode(box.nonce),
      ciphertext: base64UrlEncode(box.cipherText),
      mac: base64UrlEncode(box.mac.bytes),
    );
  }

  /// Decrypt a group-key envelope using the recipient's X25519 private key.
  static Future<String> decryptEnvelope({
    required GroupKeyEnvelope envelope,
    required SimpleKeyPair recipientPrivateKey,
  }) async {
    final ephemeralBytes =
        base64Url.decode(envelope.ephemeralPublicKey);

    final ephemeralPublic = SimplePublicKey(
      ephemeralBytes,
      type: KeyPairType.x25519,
    );

    final sharedSecret = await _x25519.sharedSecretKey(
      keyPair: recipientPrivateKey,
      remotePublicKey: ephemeralPublic,
    );

    final wrappingKey = await _hkdf.deriveKey(
      secretKey: sharedSecret,
      info: _info,
    );

    final box = SecretBox(
      base64Url.decode(envelope.ciphertext),
      nonce: base64Url.decode(envelope.nonce),
      mac: Mac(
        base64Url.decode(envelope.mac),
      ),
    );

    final plaintext = await _aes.decrypt(
      box,
      secretKey: wrappingKey,
    );

    if (plaintext.length != 32) {
      throw StateError(
        'Recovered group key has invalid length.',
      );
    }

    return base64UrlEncode(
      Uint8List.fromList(plaintext),
    );
  }
}