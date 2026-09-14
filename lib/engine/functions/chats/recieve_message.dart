// module name: receive_chat_message

import 'dart:convert';
import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../crypto/chat/null_crypto.dart'; // NullCrypto

/// Receives an incoming chat message (messageType 1), decrypts it via
/// NullCrypto's ratchet, and stores it in the Messages table with the
/// plaintext saved alongside the ciphertext.
///
/// [senderContactId] is who sent it (== conversationId, one-on-one chat).
/// [rawMessage] is the raw "message" field off the wire — the JSON
/// payload produced by sendChatMessage's wirePayload.
Future<void> receiveChatMessage(
  NullCrypto crypto,
  ContactsDao contactsDao,
  MessagesDao messagesDao, {
  required String senderContactId,
  required String messageId,
  required String logicalId,
  required String rawMessage,
}) async {
  final contact = await contactsDao.getContactById(senderContactId);
  if (contact == null) {
    throw StateError('Contact $senderContactId not found locally.');
  }

  final decoded = jsonDecode(rawMessage) as Map<String, dynamic>;

  final chainIndex = decoded['chain_index'] as int;
  final ciphertext = base64Url.decode(decoded['ciphertext'] as String);
  final nonce = base64Url.decode(decoded['nonce'] as String);
  final mac = base64Url.decode(decoded['mac'] as String);
  final senderSequence = decoded['sender_sequence'] as int? ?? 1;

  // AAD must match exactly what the sender used, or decryption/auth
  // fails — sendChatMessage bound it to the conversationId.
  final aad = utf8.encode(senderContactId);

  // Decrypt — this reads/advances the ratchet state internally.
  final plaintext = await crypto.decryptMessage(
    conversationId: senderContactId,
    chainIndex: chainIndex,
    ciphertext: ciphertext,
    nonce: nonce,
    mac: mac,
    aad: aad,
  );

  final now = DateTime.now().millisecondsSinceEpoch;

  final messageCompanion = MessagesCompanion.insert(
    messageId: messageId,
    logicalMessageId: logicalId,
    conversationId: senderContactId,
    senderId: senderContactId,
    senderSequence: senderSequence,
    messageOrder: chainIndex,
    chainIndex: chainIndex,
    timestamp: now,
    ciphertext: Uint8List.fromList(ciphertext),
    nonce: Uint8List.fromList(nonce),
    mac: Uint8List.fromList(mac),
    decryptedMessage: Value(plaintext),
    messageType: 1,
    status: 0, // same placeholder as sendChatMessage — confirm real value
    keyVersion: 1,
    receivedAt: Value(now),
  );

  await messagesDao.insertMessage(messageCompanion);
}