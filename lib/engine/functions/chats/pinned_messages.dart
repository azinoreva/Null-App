// module name: pinned_messages
//
// MessageType.pin (15) / MessageType.unpin (16) — per-message pinning in a
// conversation. Control carrier: plaintext, ephemeral, never persisted, and
// never advances the ratchet.
//
// The event addresses a single target message by the id it was sent with
// (the wire `messageId`); the receiver flips that row's `pinned` flag. This
// is the in-chat pinned banner, distinct from the conversation-list pin
// which lives on `sync_state.pinned` and is purely local.

import '../../database/queries/messages_queries.dart';
import 'message_types.dart';
import 'wire_protocol.dart';

/// Applies a received pin / unpin to the target message row.
Future<IncomingMessageResult> handlePinUnpin({
  required bool unpin,
  required MessagesDao messagesDao,
  required IncomingContext ctx,
}) async {
  final target = await messagesDao.findMessageByIdOrLogicalId(ctx.messageId);
  if (target != null) {
    await messagesDao.setMessagePinned(target.messageId, unpin ? 0 : 1);
  }
  return IncomingMessageResult(
    type: unpin ? MessageType.unpin : MessageType.pin,
    handled: true,
    messageId: ctx.messageId,
    detail: {'message_id': target?.messageId ?? ctx.messageId, 'unpin': unpin},
  );
}
