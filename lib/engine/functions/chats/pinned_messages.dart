// module name: pinned_messages
//
// MessageType.pin (15) / MessageType.unpin (16) — pin / unpin message
// events. Encrypted + persisted (the event itself is part of history) while
// the conversation's pinned flag is applied via `sync_state.pinned`.

import '../../crypto/chat/null_crypto.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../database/queries/sync_state_queries.dart';
import '../../network/chats/send_message.dart';
import 'message_sender.dart';
import 'message_types.dart';
import 'wire_protocol.dart';

/// Builds a pin / unpin payload. [messageIds] are the sender-side logical
/// message ids being pinned.
Map<String, dynamic> buildPinnedPayload({
  required List<String> messageIds,
  required bool unpin,
  String? pinnedBy,
  int? at,
}) {
  return {
    'message_ids': messageIds,
    'action': unpin ? 'unpin' : 'pin',
    'pinned_by': pinnedBy,
    'at': at ?? DateTime.now().millisecondsSinceEpoch,
  };
}

/// Sends a pin (or unpin when [unpin] is true) for a list of message ids.
Future<SendMessageResponse> sendPinnedMessages(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  required List<String> messageIds,
  bool unpin = false,
  String? pinnedBy,
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
    messageType: unpin ? MessageType.unpin : MessageType.pin,
    payload: buildPinnedPayload(
      messageIds: messageIds,
      unpin: unpin,
      pinnedBy: pinnedBy,
      at: at,
    ),
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Stores a received pin event and flips the conversation pinned flag on.
Future<IncomingMessageResult> handlePin({
  required Map<String, dynamic> payload,
  required IncomingContext ctx,
  required MessagesDao messagesDao,
  required SyncStateDao syncStateDao,
}) async {
  await storeDecryptedContent(
    messagesDao,
    conversationId: ctx.conversationId,
    senderId: ctx.senderContactId,
    ctx: ctx,
    type: MessageType.pin,
    payload: payload,
    rawMessage: ctx.rawMessage,
  );
  if (await syncStateDao.getSyncStateById(ctx.conversationId) != null) {
    await syncStateDao.setPinned(ctx.conversationId, 1);
  }
  return IncomingMessageResult(
    type: MessageType.pin,
    handled: true,
    messageId: ctx.messageId,
    detail: payload,
  );
}

/// Stores a received unpin event and flips the conversation pinned flag off.
Future<IncomingMessageResult> handleUnpin({
  required Map<String, dynamic> payload,
  required IncomingContext ctx,
  required MessagesDao messagesDao,
  required SyncStateDao syncStateDao,
}) async {
  await storeDecryptedContent(
    messagesDao,
    conversationId: ctx.conversationId,
    senderId: ctx.senderContactId,
    ctx: ctx,
    type: MessageType.unpin,
    payload: payload,
    rawMessage: ctx.rawMessage,
  );
  if (await syncStateDao.getSyncStateById(ctx.conversationId) != null) {
    await syncStateDao.setPinned(ctx.conversationId, 0);
  }
  return IncomingMessageResult(
    type: MessageType.unpin,
    handled: true,
    messageId: ctx.messageId,
    detail: payload,
  );
}