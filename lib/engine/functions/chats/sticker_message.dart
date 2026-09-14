// module name: sticker_message
//
// MessageType.sticker (23) — a sticker referenced by pack + id. Encrypted +
// persisted. Clients resolve the artwork from a pack registry; no image
// bytes travel in the payload.

import '../../crypto/chat/null_crypto.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../network/chats/send_message.dart';
import 'message_sender.dart';
import 'message_types.dart';
import 'wire_protocol.dart';

/// Builds a sticker payload. `emoji` is the placeholder glyph shown while
/// the pack artwork is fetched.
Map<String, dynamic> buildStickerPayload({
  required String packId,
  required String stickerId,
  String? emoji,
}) {
  return {
    'pack_id': packId,
    'sticker_id': stickerId,
    'emoji': emoji,
  };
}

/// Sends a sticker.
Future<SendMessageResponse> sendSticker(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  required String packId,
  required String stickerId,
  String? emoji,
  String? messageId,
  String? logicalId,
}) {
  return sendTypedMessage(
    crypto,
    contactsDao,
    identityDao,
    messagesDao,
    conversationId: conversationId,
    messageType: MessageType.sticker,
    payload: buildStickerPayload(
      packId: packId,
      stickerId: stickerId,
      emoji: emoji,
    ),
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Stores a received sticker.
Future<IncomingMessageResult> handleSticker({
  required Map<String, dynamic> payload,
  required IncomingContext ctx,
  required MessagesDao messagesDao,
}) async {
  await storeDecryptedContent(
    messagesDao,
    conversationId: ctx.conversationId,
    senderId: ctx.senderContactId,
    ctx: ctx,
    type: MessageType.sticker,
    payload: payload,
    rawMessage: ctx.rawMessage,
  );
  return IncomingMessageResult(
    type: MessageType.sticker,
    handled: true,
    messageId: ctx.messageId,
    detail: payload,
  );
}