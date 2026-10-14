// module name: edit_delete_message
//
// MessageType.edit (17) — a message's text was edited.
// MessageType.delete (18) — a message was deleted.
//
// Both events target an *existing* message and are addressed by that
// message's id: the wire `messageId` (and, for pin, `logicalId`) is the
// target row's id, not a fresh id for the event.
//
//   * edit   — encrypted like a normal message. The body is the new raw
//              text (not JSON). The receiver decrypts it and replaces the
//              target row in place (same `message_id`, `edited = 1`). The
//              wire `logicalId` is *new*, so the edit is distinguishable
//              from the original while still colliding onto the same row.
//   * delete — control (plaintext, not persisted, no ratchet). The receiver
//              hard-deletes the row addressed by `messageId`.

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../crypto/base64_tolerant.dart';
import '../../crypto/chat/null_crypto.dart';
import '../../database/app_database.dart';
import '../../database/queries/messages_queries.dart';
import '../../database/queries/sessions_queries.dart';
import 'message_types.dart';
import 'wire_protocol.dart';

/// Applies a received edit (17): decrypts the new body and replaces the
/// target row in place, keeping its position in history and flagging it
/// edited. [ctx.messageId] is the target's `messageId`.
Future<IncomingMessageResult> handleEditMessage({
  required NullCrypto crypto,
  required SessionsDao sessionsDao,
  required MessagesDao messagesDao,
  required IncomingContext ctx,
}) async {
  final text = await decryptContentPlaintext(
    crypto,
    sessionsDao,
    conversationId: ctx.conversationId,
    rawMessage: ctx.rawMessage,
  );

  final decoded = jsonDecode(ctx.rawMessage) as Map<String, dynamic>;
  final chainIndex = decoded['chain_index'] as int? ?? ctx.messageOrder;
  final senderSequence = decoded['sender_sequence'] as int? ?? ctx.senderSequence;

  final target = await messagesDao.getMessageById(ctx.messageId);
  if (target == null) {
    return IncomingMessageResult(
      type: MessageType.edit,
      handled: false,
      messageId: ctx.messageId,
      reason: 'No local message ${ctx.messageId} to edit.',
    );
  }

  await messagesDao.upsertMessage(
    MessagesCompanion.insert(
      messageId: target.messageId,
      logicalMessageId: ctx.logicalId,
      conversationId: target.conversationId,
      senderId: target.senderId,
      senderSequence: senderSequence,
      messageOrder: target.messageOrder,
      chainIndex: chainIndex,
      timestamp: target.timestamp,
      ciphertext: base64DecodeTolerant(decoded['ciphertext'] as String),
      nonce: base64DecodeTolerant(decoded['nonce'] as String),
      mac: base64DecodeTolerant(decoded['mac'] as String),
      decryptedMessage: Value(text),
      messageType: target.messageType,
      replyTo: Value(target.replyTo),
      edited: const Value(1),
      status: target.status,
      keyVersion: target.keyVersion,
      receivedAt: Value(target.receivedAt ?? target.timestamp),
    ),
  );

  return IncomingMessageResult(
    type: MessageType.edit,
    handled: true,
    messageId: ctx.messageId,
    detail: {'text': text},
  );
}

/// Applies a received delete (18): hard-deletes the row addressed by
/// [ctx.messageId] (falling back to a `logicalMessageId` match).
Future<IncomingMessageResult> handleDeleteMessage({
  required MessagesDao messagesDao,
  required IncomingContext ctx,
}) async {
  final target = await messagesDao.findMessageByIdOrLogicalId(ctx.messageId);
  if (target != null) {
    await messagesDao.deleteMessage(target.messageId);
  }
  return IncomingMessageResult(
    type: MessageType.delete,
    handled: true,
    messageId: ctx.messageId,
    detail: {'deleted': target?.messageId ?? ctx.messageId},
  );
}
