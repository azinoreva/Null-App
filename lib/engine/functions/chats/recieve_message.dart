// module name: receive_chat_message

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../crypto/base64_tolerant.dart';
import '../../database/app_database.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../crypto/chat/null_crypto.dart'; // NullCrypto

/// Receives an incoming chat message (messageType 1).
///
/// The modern body is the encrypted JSON envelope produced by
/// sendChatMessage's wirePayload; it is decrypted via NullCrypto's ratchet and
/// stored with the plaintext alongside the ciphertext.
///
/// Older/legacy peers (and any peer we have not completed a DH handshake with)
/// still send the message text verbatim. Those bodies are not JSON, so they
/// cannot be decrypted — they are stored as plaintext rather than failing the
/// task and retrying forever.
///
/// [senderContactId] is who sent it (== conversationId, one-on-one chat).
/// [rawMessage] is the raw "message" field off the wire.
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

  final decoded = _tryDecodeWirePayload(rawMessage);
  if (decoded == null) {
    await _storePlaintext(
      messagesDao,
      senderContactId: senderContactId,
      messageId: messageId,
      logicalId: logicalId,
      plaintext: rawMessage,
    );
    return;
  }

  final chainIndex = decoded['chain_index'] as int? ?? 0;
  final ciphertext = base64DecodeTolerant(decoded['ciphertext'] as String);
  final nonce = base64DecodeTolerant(decoded['nonce'] as String);
  final mac = base64DecodeTolerant(decoded['mac'] as String);
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
    ciphertext: ciphertext,
    nonce: nonce,
    mac: mac,
    decryptedMessage: Value(plaintext),
    messageType: 1,
    status: 0, // same placeholder as sendChatMessage — confirm real value
    keyVersion: 1,
    receivedAt: Value(now),
  );

  await messagesDao.insertMessage(messageCompanion);
}

/// Parses [rawMessage] as an encrypted wire envelope, or returns null when it
/// is not one (a plaintext legacy body, or malformed JSON).
Map<String, dynamic>? _tryDecodeWirePayload(String rawMessage) {
  try {
    final parsed = jsonDecode(rawMessage);
    if (parsed is Map<String, dynamic> &&
        parsed['ciphertext'] is String &&
        parsed['nonce'] is String &&
        parsed['mac'] is String) {
      return parsed;
    }
  } on FormatException {
    // Not JSON — a plaintext message body.
  }
  return null;
}

Future<void> _storePlaintext(
  MessagesDao messagesDao, {
  required String senderContactId,
  required String messageId,
  required String logicalId,
  required String plaintext,
}) async {
  final now = DateTime.now().millisecondsSinceEpoch;
  final companion = MessagesCompanion.insert(
    messageId: messageId,
    logicalMessageId: logicalId,
    conversationId: senderContactId,
    senderId: senderContactId,
    senderSequence: 1,
    messageOrder: 0,
    chainIndex: 0,
    timestamp: now,
    ciphertext: Uint8List(0),
    nonce: Uint8List(0),
    mac: Uint8List(0),
    decryptedMessage: Value(plaintext),
    messageType: 1,
    status: 0,
    keyVersion: 1,
    receivedAt: Value(now),
  );
  await messagesDao.insertMessage(companion);
}
