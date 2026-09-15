// module name: send_chat_message

import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../crypto/chat/null_crypto.dart'; // NullCrypto, EncryptedMessage
import '../../crypto/chat/identity_crypto.dart';
import '../../crypto/chat/ratchet_store.dart';
import '../../network/api_client.dart';
import '../../network/auth_failure_handler.dart';
import '../../network/chats/send_message.dart'; // SendMessageService, MessageRecipient, SendMessageResponse

const _uuid = Uuid();
final Map<String, Future<void>> _sendTails = {};

/// Executor used by the durable task queue. The task arguments are:
/// [conversationId], [plaintext], and [serverId].
Future<void> sendQueuedChatMessage(
  List<dynamic> args,
  AppDatabase database,
) async {
  final conversationId = args[0] as String;
  final previous = _sendTails[conversationId] ?? Future<void>.value();
  final current = previous.catchError((_) {}).then(
    (_) => _sendQueuedChatMessage(args, database),
  );
  _sendTails[conversationId] = current;
  try {
    await current;
  } finally {
    if (identical(_sendTails[conversationId], current)) {
      _sendTails.remove(conversationId);
    }
  }
}

Future<void> _sendQueuedChatMessage(
  List<dynamic> args,
  AppDatabase database,
) async {
  final conversationId = args[0] as String;
  final plaintext = args[1] as String;
  final serverId = args[2] as String;
  final messageId = args[3] as String;
  final logicalId = args[4] as String;

  final server = await database.serversDao.getServerById(serverId);
  if (server == null || server.serverUrl.isEmpty) {
    throw StateError('No URL is stored for server $serverId.');
  }

  if (!ApiClient.isRegistered(serverId)) {
    ApiClient.registerServer(
      serverId: serverId,
      baseUrl: server.serverUrl,
      onAuthFailure: () async {
        await redirectToLogin();
      },
    );
  }

  final identityCrypto = const IdentityCrypto();
  final session = await database.sessionsDao.getSessionByConversationId(
    conversationId,
  );
  if (session?.status != 2) {
    throw StateError('Handshake is not established for $conversationId.');
  }

  final established = await database.sessionsDao.getSessionByConversationId(
    conversationId,
  );
  final sharedSecret = established?.symmetricKey;
  if (sharedSecret == null) {
    throw StateError('No symmetric key is available for $conversationId.');
  }

  final crypto = NullCrypto(
    identity: identityCrypto,
    ratchetStore: const RatchetStore(),
  );
  if (await crypto.ratchetStore.loadState(conversationId) == null) {
    await crypto.establishConversation(
      conversationId: conversationId,
      sharedSecret: sharedSecret,
      initiator: true,
    );
  }

  await sendChatMessage(
    crypto,
    database.contactsDao,
    database.identityDao,
    database.messagesDao,
    conversationId: conversationId,
    plaintext: plaintext,
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

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
  String? messageId,
  String? logicalId,
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

  final existing = messageId == null
      ? null
      : await messagesDao.getMessageById(messageId);
  final service = SendMessageService(serverId: serverId);
  if (existing != null) {
    final wirePayload = jsonEncode({
      'chain_index': existing.chainIndex,
      'ciphertext': base64UrlEncode(existing.ciphertext),
      'nonce': base64UrlEncode(existing.nonce),
      'mac': base64UrlEncode(existing.mac),
      'sender_sequence': existing.senderSequence,
    });
    return service.sendMessage(
      recipientIds: [
        MessageRecipient(
          userId: conversationId,
          userName: contact.nickname ?? conversationId,
        ),
      ],
      messageId: existing.messageId,
      logicalId: existing.logicalMessageId,
      conversationId: conversationId,
      messageType: existing.messageType,
      message: wirePayload,
      messageOrder: existing.messageOrder,
      nonce: 'none',
      senderSequence: existing.senderSequence,
    );
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

  final outgoingMessageId = messageId ?? _uuid.v4();
  final outgoingLogicalId = logicalId ?? _uuid.v4();
  final senderSequence =
      await messagesDao.getLastSenderSequence(
        conversationId: conversationId,
        senderId: identity.identityId,
      ) +
      1;
  final now = DateTime.now().millisecondsSinceEpoch;

  // Wire payload: everything the recipient needs to run
  // NullCrypto.decryptMessage on their side, packed as JSON.
  final wirePayload = jsonEncode({
    'chain_index': encrypted.chainIndex,
    'ciphertext': base64UrlEncode(encrypted.ciphertext),
    'nonce': base64UrlEncode(encrypted.nonce),
    'mac': base64UrlEncode(encrypted.mac),
    'sender_sequence': senderSequence,
  });

  // Persist locally — decryptedMessage is saved as plain text since we
  // already know it (we're the one who just encrypted it).
  final messageCompanion = MessagesCompanion.insert(
    messageId: outgoingMessageId,
    logicalMessageId: outgoingLogicalId,
    conversationId: conversationId,
    senderId: identity.identityId,
    senderSequence: senderSequence,
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

  return service.sendMessage(
    recipientIds: [
      MessageRecipient(
        userId: conversationId,
        userName: contact.nickname ?? conversationId,
      ),
    ],
    messageId: outgoingMessageId,
    logicalId: outgoingLogicalId,
    conversationId: conversationId,
    messageType: 1,
    message: wirePayload,
    messageOrder: encrypted.chainIndex,
    nonce: 'none', // top-level API field, distinct from the real crypto nonce packed inside wirePayload
    senderSequence: senderSequence,
  );
}