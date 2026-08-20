import 'dart:convert';

import 'package:cryptography/cryptography.dart';

class GroupEncryptedMessage {
  final String messageId;
  final String conversationId;
  final String senderId;

  final int messageOrder;
  final int keyVersion;
  final int timestamp;

  final String ciphertext;
  final String nonce;
  final String mac;

  const GroupEncryptedMessage({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.messageOrder,
    required this.keyVersion,
    required this.timestamp,
    required this.ciphertext,
    required this.nonce,
    required this.mac,
  });

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'messageOrder': messageOrder,
      'keyVersion': keyVersion,
      'timestamp': timestamp,
      'ciphertext': ciphertext,
      'nonce': nonce,
      'mac': mac,
    };
  }

  factory GroupEncryptedMessage.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroupEncryptedMessage(
      messageId: json['messageId'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      messageOrder: json['messageOrder'] as int,
      keyVersion: json['keyVersion'] as int,
      timestamp: json['timestamp'] as int,
      ciphertext: json['ciphertext'] as String,
      nonce: json['nonce'] as String,
      mac: json['mac'] as String,
    );
  }
}

class GroupMessageCrypto {
  GroupMessageCrypto._();

  static final AesGcm _cipher =
      AesGcm.with256bits();

  /// Encrypt a plaintext group message.
  ///
  /// The key version is metadata telling the receiver which
  /// group key to use.
  static Future<GroupEncryptedMessage> encrypt({
    required String messageId,
    required String conversationId,
    required String senderId,
    required int messageOrder,
    required int keyVersion,
    required int timestamp,
    required String plaintext,
    required String groupKey,
  }) async {
    final keyBytes = base64Url.decode(groupKey);

    if (keyBytes.length != 32) {
      throw ArgumentError(
        'Group key must contain exactly 32 bytes.',
      );
    }

    final key = SecretKey(keyBytes);

    final nonce = _cipher.newNonce();

    final box = await _cipher.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
      nonce: nonce,
    );

    return GroupEncryptedMessage(
      messageId: messageId,
      conversationId: conversationId,
      senderId: senderId,
      messageOrder: messageOrder,
      keyVersion: keyVersion,
      timestamp: timestamp,
      ciphertext: base64UrlEncode(box.cipherText),
      nonce: base64UrlEncode(box.nonce),
      mac: base64UrlEncode(box.mac.bytes),
    );
  }

  /// Decrypt a group message.
  static Future<String> decrypt({
    required GroupEncryptedMessage message,
    required String groupKey,
  }) async {
    final keyBytes = base64Url.decode(groupKey);

    if (keyBytes.length != 32) {
      throw ArgumentError(
        'Group key must contain exactly 32 bytes.',
      );
    }

    final box = SecretBox(
      base64Url.decode(message.ciphertext),
      nonce: base64Url.decode(message.nonce),
      mac: Mac(
        base64Url.decode(message.mac),
      ),
    );

    final plaintext = await _cipher.decrypt(
      box,
      secretKey: SecretKey(keyBytes),
    );

    return utf8.decode(plaintext);
  }
}