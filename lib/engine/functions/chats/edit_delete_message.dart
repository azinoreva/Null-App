// module name: edit_delete_message
//
// MessageType.edit (17) / MessageType.delete (18) — text-edit and deletion
// events. Both are encrypted + persisted. The *original* message row is
// updated in place; the edit/delete event is additionally stored so it
// stays part of history and survives resync.
//
// `message_id` in the payload references the message the peer sees, which
// on the local side may equal either `messageId` or `logicalMessageId` —
// the lookup tries both.

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../crypto/chat/null_crypto.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../network/chats/send_message.dart';
import 'message_sender.dart';
import 'message_types.dart';
import 'wire_protocol.dart';

/// Resolves a local message row by either its `messageId` or its
/// `logicalMessageId` (used for edit/delete references).
Future<Message?> findMessageByIdOrLogicalId(
  MessagesDao messagesDao,
  String id,
) {
  return (messagesDao.select(messagesDao.db.messages)
        ..where((t) => t.messageId.equals(id) | t.logicalMessageId.equals(id)))
      .getSingleOrNull();
}

/// Sends a text-edit event for [targetMessageId].
Future<SendMessageResponse> sendEditMessage(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  required String targetMessageId,
  required String text,
  String? editedBy,
  int? at,
  String? messageId,
  String? logicalId,
}) {
  return sendTypedMessage(
    crypto,
    contactsDao,
    identityDao,
    messagesDao,
    conversationId: conversationId,
    messageType: MessageType.edit,
    payload: {
      'message_id': targetMessageId,
      'text': text,
      'edited_by': editedBy,
      'at': at ?? DateTime.now().millisecondsSinceEpoch,
    },
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Sends a deletion event for [targetMessageId].
Future<SendMessageResponse> sendDeleteMessage(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  required String targetMessageId,
  String? deletedBy,
  int? at,
  String? messageId,
  String? logicalId,
}) {
  return sendTypedMessage(
    crypto,
    contactsDao,
    identityDao,
    messagesDao,
    conversationId: conversationId,
    messageType: MessageType.delete,
    payload: {
      'message_id': targetMessageId,
      'deleted_by': deletedBy,
      'at': at ?? DateTime.now().millisecondsSinceEpoch,
    },
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Applies an edit: updates the target row (edited=1, new text) and stores
/// the edit event itself.
Future<IncomingMessageResult> handleEditMessage({
  required Map<String, dynamic> payload,
  required IncomingContext ctx,
  required MessagesDao messagesDao,
}) async {
  final targetId = payload['message_id'] as String?;
  if (targetId == null) {
    return IncomingMessageResult(
      type: MessageType.edit,
      handled: false,
      messageId: ctx.messageId,
      reason: 'Missing message_id.',
    );
  }

  final target = await findMessageByIdOrLogicalId(messagesDao, targetId);
  final text = payload['text'] as String? ?? '';

  if (target != null) {
    await (messagesDao.update(messagesDao.db.messages)
          ..where((t) => t.messageId.equals(target.messageId)))
        .write(
      MessagesCompanion(
        edited: const Value(1),
        decryptedMessage: Value(
          jsonEncode({
            'text': text,
            'edited_by': payload['edited_by'],
            'edited_at': payload['at'],
          }),
        ),
      ),
    );
  }

  await storeDecryptedContent(
    messagesDao,
    conversationId: ctx.conversationId,
    senderId: ctx.senderContactId,
    ctx: ctx,
    type: MessageType.edit,
    payload: payload,
    rawMessage: ctx.rawMessage,
    replyTo: targetId,
  );

  return IncomingMessageResult(
    type: MessageType.edit,
    handled: true,
    messageId: ctx.messageId,
    detail: payload,
  );
}

/// Applies a deletion: flags the target row locally (v1 writes a tombstone
/// marker into `decryptedMessage`) and stores the delete event itself.
///
/// Note: `Messages` has no `deleted` column yet; a tombstone is emulated
/// with `edited=1` + a `{deleted: true}` body until the schema is extended
/// (see README).
Future<IncomingMessageResult> handleDeleteMessage({
  required Map<String, dynamic> payload,
  required IncomingContext ctx,
  required MessagesDao messagesDao,
}) async {
  final targetId = payload['message_id'] as String?;
  if (targetId == null) {
    return IncomingMessageResult(
      type: MessageType.delete,
      handled: false,
      messageId: ctx.messageId,
      reason: 'Missing message_id.',
    );
  }

  final target = await findMessageByIdOrLogicalId(messagesDao, targetId);
  if (target != null) {
    await (messagesDao.update(messagesDao.db.messages)
          ..where((t) => t.messageId.equals(target.messageId)))
        .write(
      MessagesCompanion(
        edited: const Value(1),
        decryptedMessage: Value(
          jsonEncode({
            'deleted': true,
            'deleted_by': payload['deleted_by'],
            'deleted_at': payload['at'],
          }),
        ),
      ),
    );
  }

  await storeDecryptedContent(
    messagesDao,
    conversationId: ctx.conversationId,
    senderId: ctx.senderContactId,
    ctx: ctx,
    type: MessageType.delete,
    payload: payload,
    rawMessage: ctx.rawMessage,
    replyTo: targetId,
  );

  return IncomingMessageResult(
    type: MessageType.delete,
    handled: true,
    messageId: ctx.messageId,
    detail: payload,
  );
}