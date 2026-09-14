// module name: media_message
//
// MessageType.media (2) — media attachment. Encrypted (ratchet) + persisted.

import '../../crypto/chat/null_crypto.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../network/chats/send_message.dart';
import 'message_sender.dart';
import 'message_types.dart';
import 'wire_protocol.dart';

/// Builds the media payload. `media_type` is one of
/// image | video | audio | file.
Map<String, dynamic> buildMediaPayload({
  required String mediaType,
  required String mediaUrl,
  String? caption,
  int width = 0,
  int height = 0,
  int sizeBytes = 0,
  int durationMs = 0,
  String? thumbnailBase64,
}) {
  return {
    'media_type': mediaType,
    'media_url': mediaUrl,
    'caption': caption,
    'width': width,
    'height': height,
    'size_bytes': sizeBytes,
    'duration_ms': durationMs,
    'thumbnail_base64': thumbnailBase64,
  };
}

/// Sends a media message (ratchet-encrypted, persisted, POSTed).
Future<SendMessageResponse> sendMediaMessage(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  required String mediaType,
  required String mediaUrl,
  String? caption,
  int width = 0,
  int height = 0,
  int sizeBytes = 0,
  int durationMs = 0,
  String? thumbnailBase64,
  String? messageId,
  String? logicalId,
}) {
  return sendTypedMessage(
    crypto,
    contactsDao,
    identityDao,
    messagesDao,
    conversationId: conversationId,
    messageType: MessageType.media,
    payload: buildMediaPayload(
      mediaType: mediaType,
      mediaUrl: mediaUrl,
      caption: caption,
      width: width,
      height: height,
      sizeBytes: sizeBytes,
      durationMs: durationMs,
      thumbnailBase64: thumbnailBase64,
    ),
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Stores a received encrypted media message in `Messages`.
Future<IncomingMessageResult> handleMediaMessage({
  required Map<String, dynamic> payload,
  required IncomingContext ctx,
  required MessagesDao messagesDao,
}) async {
  await storeDecryptedContent(
    messagesDao,
    conversationId: ctx.conversationId,
    senderId: ctx.senderContactId,
    ctx: ctx,
    type: MessageType.media,
    payload: payload,
    rawMessage: ctx.rawMessage,
  );
  return IncomingMessageResult(
    type: MessageType.media,
    handled: true,
    messageId: ctx.messageId,
    detail: payload,
  );
}