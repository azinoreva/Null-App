// module name: send_chat_message

import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../crypto/chat/null_crypto.dart'; // NullCrypto, EncryptedMessage
import '../../network/chats/send_message.dart'; // SendMessageService, MessageRecipient, SendMessageResponse

const _uuid = Uuid();

/// Sends a chat message once the ratchet is established (i.e. after
/// establishConversation has already run for this conversation).
///
/// Reads the current identity and contact from the database, encrypts
/// [plaintext] via NullCrypto's ratchet (which internally reads/advances
/// its own persisted ratchet state), records the resulting message
/// locally with the plaintext saved alongside the ciphertext, then sends
/// it to the server.
Future<SendMessageResponse> sendChatMessage(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId, // == contactId
  required String plaintext,
  required String serverId,
}) async {
  // Read current identity.
  final identity = await identityDao.getCurrentIdentityOrNull();
  if (identity == null) {
    throw StateError('No local identity found.');
  }

  // Read the contact we're messaging.
  final contact = await contactsDao.getContactById(conversationId);
  if (contact == null) {
    throw StateError('Contact $conversationId not found locally.');
  }

  // AAD binds the ciphertext to this conversation, preventing it from
  // being replayed into a different conversation.
  final aad = utf8.encode(conversationId);

  // Encrypt — this reads/advances the ratchet state internally, and
  // generates the nonce as part of that process.
  final encrypted = await crypto.encryptMessage(
    conversationId: conversationId,
    plaintext: plaintext,
    aad: aad,
  );

  final messageId = _uuid.v4();
  final logicalId = _uuid.v4();
  final now = DateTime.now().millisecondsSinceEpoch;

  // Wire payload: everything the recipient needs to run
  // NullCrypto.decryptMessage on their side, packed as JSON.
  final wirePayload = jsonEncode({
    'chain_index': encrypted.chainIndex,
    'ciphertext': base64UrlEncode(encrypted.ciphertext),
    'nonce': base64UrlEncode(encrypted.nonce),
    'mac': base64UrlEncode(encrypted.mac),
  });

  // Persist locally — decryptedMessage is saved as plain text since we
  // already know it (we're the one who just encrypted it).
  final messageCompanion = MessagesCompanion.insert(
    messageId: messageId,
    logicalMessageId: logicalId,
    conversationId: conversationId,
    senderId: identity.identityId,
    senderSequence: 1,
    messageOrder: encrypted.chainIndex,
    chainIndex: encrypted.chainIndex, // expected to be 1 for the first message — confirm against NullCrypto's actual ratchet output
    timestamp: now,
    ciphertext: encrypted.ciphertext,
    nonce: encrypted.nonce,
    mac: encrypted.mac,
    decryptedMessage: Value(plaintext),
    messageType: 1,
    status: 0, // assumed: 0 = sent/pending — confirm your status numbering
    keyVersion: 1,
  );

  await messagesDao.insertMessage(messageCompanion);

  final service = SendMessageService(serverId: serverId);

  return service.sendMessage(
    recipientIds: [
      MessageRecipient(
        userId: conversationId,
        userName: contact.nickname ?? conversationId,
      ),
    ],
    messageId: messageId,
    logicalId: logicalId,
    conversationId: conversationId,
    messageType: 1,
    message: wirePayload,
    messageOrder: encrypted.chainIndex,
    nonce: 'none', // top-level API field, distinct from the real crypto nonce packed inside wirePayload
    senderSequence: 1,
  );
}