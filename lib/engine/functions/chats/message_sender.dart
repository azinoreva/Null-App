// module name: message_sender
//
// Generic send machinery for every chat message type. Mirrors the async
// ordering + ratchet + wire-payload flow of 01_send_message.dart but is
// parameterized by MessageType, so media, polls, edits, reactions,
// typing hints, call signaling etc. reuse the exact same path instead of
// duplicating it per type.
//
// Two carriers (see wire_protocol.dart):
//   * encrypted types  -> payload JSON is ratchet-encrypted, stored in
//                         `Messages`, then POSTed via SendMessageService.
//   * control types    -> wrapped in a plaintext ControlEnvelope, NOT
//                         stored, POSTed via SendMessageService.

import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../crypto/chat/identity_crypto.dart';
import '../../crypto/chat/null_crypto.dart';
import '../../crypto/chat/ratchet_store.dart';
import '../../database/app_database.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../network/api_client.dart';
import '../../network/chats/send_message.dart';
import 'message_types.dart';
import 'wire_protocol.dart';

const _uuid = Uuid();

/// Serializes one conversation's sends so out-of-order messages never race
/// the ratchet. Mirrors the private tail map in 01_send_message.dart.
final Map<String, Future<void>> _typedSendTails = {};

/// Durable-task-queue executor, registered in functions_list.dart as
/// `'sendTypedMessage'`. Arguments (all strings / ints, isolate-safe):
///   [conversationId, messageType, payloadJson, serverId, messageId,
///    logicalId, (replyTo?)]
Future<void> sendTypedMessageTask(
  List<dynamic> args,
  AppDatabase database,
) async {
  final conversationId = args[0] as String;
  final messageType = args[1] as int;
  final payloadJson = args[2] as String;
  final serverId = args[3] as String;
  final messageId = args[4] as String;
  final logicalId = args[5] as String;
  final replyTo = args.length > 6 ? args[6] as String? : null;

  final previous = _typedSendTails[conversationId] ?? Future<void>.value();
  final current = previous.catchError((_) {}).then(
    (_) => _sendTypedMessageTask(
      conversationId,
      messageType,
      payloadJson,
      serverId,
      messageId,
      logicalId,
      replyTo,
      database,
    ),
  );
  _typedSendTails[conversationId] = current;
  try {
    await current;
  } finally {
    if (identical(_typedSendTails[conversationId], current)) {
      _typedSendTails.remove(conversationId);
    }
  }
}

Future<void> _sendTypedMessageTask(
  String conversationId,
  int messageTypeValue,
  String payloadJson,
  String serverId,
  String messageId,
  String logicalId,
  String? replyTo,
  AppDatabase database,
) async {
  final server = await database.serversDao.getServerById(serverId);
  if (server == null || server.serverUrl.isEmpty) {
    throw StateError('No URL is stored for server $serverId.');
  }
  if (!ApiClient.isRegistered(serverId)) {
    ApiClient.registerServer(
      serverId: serverId,
      baseUrl: server.serverUrl,
      onAuthFailure: () {},
    );
  }

  final session =
      await database.sessionsDao.getSessionByConversationId(conversationId);
  if (session?.status != 2) {
    throw StateError('Handshake is not established for $conversationId.');
  }
  final sharedSecret = session?.symmetricKey;
  if (sharedSecret == null) {
    throw StateError('No symmetric key is available for $conversationId.');
  }

  final crypto = NullCrypto(
    identity: const IdentityCrypto(),
    ratchetStore: const RatchetStore(),
  );
  if (await crypto.ratchetStore.loadState(conversationId) == null) {
    await crypto.establishConversation(
      conversationId: conversationId,
      sharedSecret: sharedSecret,
      initiator: true,
    );
  }

  final type = MessageType.fromValue(messageTypeValue);
  if (type == null) {
    throw StateError('Unknown message type $messageTypeValue.');
  }
  final payload = jsonDecode(payloadJson) as Map<String, dynamic>;

  await sendTypedMessage(
    crypto,
    database.contactsDao,
    database.identityDao,
    database.messagesDao,
    conversationId: conversationId,
    messageType: type,
    payload: payload,
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
    replyTo: replyTo,
  );
}

/// Sends a typed message over an established conversation.
///
/// * Encrypted types are ratchet-encrypted, persisted locally (with the
///   plaintext JSON kept in `decryptedMessage`), then posted.
/// * Control types are posted as a plaintext [ControlEnvelope] and are not
///   persisted (mirroring handshake type 0).
///
/// Pass an existing [messageId] to re-send a previously queued message row
/// instead of encrypting anew (used by the task engine's retry path).
Future<SendMessageResponse> sendTypedMessage(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required MessageType messageType,
  required Map<String, dynamic> payload,
  required String serverId,
  String? messageId,
  String? logicalId,
  String? replyTo,
  int status = 0,
}) async {
  final identity = await identityDao.getCurrentIdentityOrNull();
  if (identity == null) {
    throw StateError('No local identity found.');
  }

  final contact = await contactsDao.getContactById(conversationId);
  if (contact == null) {
    throw StateError('Contact $conversationId not found locally.');
  }

  final service = SendMessageService(serverId: serverId);
  final recipients = [
    MessageRecipient(
      userId: conversationId,
      userName: contact.nickname ?? conversationId,
    ),
  ];

  final existing = messageId == null
      ? null
      : await messagesDao.getMessageById(messageId);
  if (existing != null) {
    final wirePayload = jsonEncode({
      'v': kProtocolVersion,
      'chain_index': existing.chainIndex,
      'ciphertext': base64UrlEncode(existing.ciphertext),
      'nonce': base64UrlEncode(existing.nonce),
      'mac': base64UrlEncode(existing.mac),
      'sender_sequence': existing.senderSequence,
    });
    return _post(
      service,
      recipients,
      existing.messageId,
      existing.logicalMessageId,
      conversationId,
      existing.messageType,
      wirePayload,
      existing.messageOrder,
      existing.senderSequence,
      'none', // top-level API field, distinct from the crypto nonce in wirePayload
    );
  }

  final outgoingMessageId = messageId ?? _uuid.v4();
  final outgoingLogicalId = logicalId ?? _uuid.v4();
  final senderSequence =
      await messagesDao.getLastSenderSequence(
        conversationId: conversationId,
        senderId: identity.identityId,
      ) +
      1;
  final now = DateTime.now().millisecondsSinceEpoch;
  final plaintextJson = jsonEncode(payload);

  final String wireMessage;
  int messageOrder;
  var ciphertext = Uint8List(0);
  var nonce = Uint8List(0);
  var mac = Uint8List(0);
  String? decryptedText;

  if (messageType.isEncrypted) {
    final encryptedWire = await buildEncryptedWirePayload(
      crypto,
      conversationId: conversationId,
      plaintext: plaintextJson,
      senderSequence: senderSequence,
    );
    wireMessage = jsonEncode(encryptedWire);
    messageOrder = encryptedWire['chain_index'] as int;
    ciphertext = Uint8List.fromList(
      base64Url.decode(encryptedWire['ciphertext'] as String),
    );
    nonce = Uint8List.fromList(
      base64Url.decode(encryptedWire['nonce'] as String),
    );
    mac = Uint8List.fromList(
      base64Url.decode(encryptedWire['mac'] as String),
    );
    decryptedText = plaintextJson;
  } else {
    final envelope = ControlEnvelope(
      kind: payload['kind'] as String? ?? messageType.controlKind,
      payload: payload,
      sequence: senderSequence,
      timestamp: now,
    );
    wireMessage = envelope.encode();
    messageOrder = senderSequence;
  }

  if (messageType.isEncrypted) {
    await messagesDao.insertMessage(
      MessagesCompanion.insert(
        messageId: outgoingMessageId,
        logicalMessageId: outgoingLogicalId,
        conversationId: conversationId,
        senderId: identity.identityId,
        senderSequence: senderSequence,
        messageOrder: messageOrder,
        chainIndex: messageOrder,
        timestamp: now,
        ciphertext: ciphertext,
        nonce: nonce,
        mac: mac,
        decryptedMessage: Value(decryptedText),
        messageType: messageType.value,
        replyTo: Value(replyTo),
        edited: const Value(0),
        status: status,
        keyVersion: 1,
        protocolVersion: Value(kProtocolVersion),
      ),
    );
  }

  return _post(
    service,
    recipients,
    outgoingMessageId,
    outgoingLogicalId,
    conversationId,
    messageType.value,
    wireMessage,
    messageOrder,
    senderSequence,
    'none',
  );
}

Future<SendMessageResponse> _post(
  SendMessageService service,
  List<MessageRecipient> recipients,
  String messageId,
  String logicalId,
  String conversationId,
  int messageType,
  String wireMessage,
  int messageOrder,
  int senderSequence,
  String nonce,
) {
  return service.sendMessage(
    recipientIds: recipients,
    messageId: messageId,
    logicalId: logicalId,
    conversationId: conversationId,
    messageType: messageType,
    message: wireMessage,
    messageOrder: messageOrder,
    nonce: nonce,
    senderSequence: senderSequence,
  );
}