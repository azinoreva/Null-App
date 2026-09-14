// module name: read_receipts
//
// MessageType.received (11) / MessageType.read (10) — delivery and read
// receipts. Control (plaintext envelope); the receiver flips the matching
// locally-persisted sent-message rows to status 2 (delivered) / 3 (read)
// and stamps `receivedAt` / `readAt`.

import 'package:drift/drift.dart';

import '../../database/queries/messages_queries.dart';
import '../../network/chats/send_message.dart';
import 'message_sender.dart';
import 'message_types.dart';
import 'wire_protocol.dart';

/// Sends a delivery (or read) receipt for [messageIds] to the peer.
/// Return value is the raw wire POST result; the peer does the status flip
/// on its own copy.
Future<SendMessageResponse> sendReceipt(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  required List<String> messageIds,
  required bool read,
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
    messageType: read ? MessageType.read : MessageType.received,
    payload: {
      'message_ids': messageIds,
      'at': at ?? DateTime.now().millisecondsSinceEpoch,
    },
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Marks the local copies of [messageIds] as delivered (status 2).
Future<IncomingMessageResult> handleReceivedReceipt({
  required ControlEnvelope env,
  required IncomingContext ctx,
  required MessagesDao messagesDao,
}) async {
  await _applyStatus(
    messagesDao,
    env.payload,
    status: 2,
    stampReadAt: false,
  );
  return IncomingMessageResult(
    type: MessageType.received,
    handled: true,
    messageId: ctx.messageId,
    detail: env.payload,
  );
}

/// Marks the local copies of [messageIds] as read (status 3) and stamps
/// `readAt`. Only applies to messages the local user *sent*; the peer's
/// own rows are never touched.
Future<IncomingMessageResult> handleReadReceipt({
  required ControlEnvelope env,
  required IncomingContext ctx,
  required MessagesDao messagesDao,
}) async {
  await _applyStatus(
    messagesDao,
    env.payload,
    status: 3,
    stampReadAt: true,
  );
  return IncomingMessageResult(
    type: MessageType.read,
    handled: true,
    messageId: ctx.messageId,
    detail: env.payload,
  );
}

Future<void> _applyStatus(
  MessagesDao messagesDao,
  Map<String, dynamic> payload, {
  required int status,
  required bool stampReadAt,
}) async {
  final ids = (payload['message_ids'] as List<dynamic>? ?? const [])
      .map((e) => e.toString())
      .toList();
  final at = payload['at'] as int? ?? DateTime.now().millisecondsSinceEpoch;

  for (final id in ids) {
    final row = await messagesDao.getMessageById(id);
    if (row == null) continue;

    await messagesDao.updateMessageStatus(id, status);
    if (stampReadAt) {
      await (messagesDao.update(messagesDao.db.messages)
            ..where((t) => t.messageId.equals(id)))
          .write(MessagesCompanion(readAt: Value(at)));
    }
  }
}