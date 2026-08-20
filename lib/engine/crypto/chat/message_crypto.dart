import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'crypto_types.dart';

class MessageCrypto {
  static final Xchacha20 _cipher =
      Xchacha20.poly1305Aead();

  static Future<EncryptedMessage> encrypt({
    required Uint8List messageKey,
    required String plaintext,
    required List<int> aad,
    required int chainIndex,
  }) async {
    final box = await _cipher.encrypt(
      utf8.encode(plaintext),
      secretKey: SecretKey(messageKey),
      aad: aad,
    );

    return EncryptedMessage(
      ciphertext:
          Uint8List.fromList(box.cipherText),
      nonce:
          Uint8List.fromList(box.nonce),
      mac:
          Uint8List.fromList(box.mac.bytes),
      chainIndex: chainIndex,
    );
  }

  static Future<String> decrypt({
    required Uint8List messageKey,
    required Uint8List ciphertext,
    required Uint8List nonce,
    required Uint8List mac,
    required List<int> aad,
  }) async {
    final box = SecretBox(
      ciphertext,
      nonce: nonce,
      mac: Mac(mac),
    );

    final plaintext = await _cipher.decrypt(
      box,
      secretKey: SecretKey(messageKey),
      aad: aad,
    );

    return utf8.decode(plaintext);
  }
}