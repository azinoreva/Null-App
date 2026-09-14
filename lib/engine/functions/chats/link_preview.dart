// module name: link_preview
//
// MessageType.link_preview (20) — server/peer-fetched preview of a shared
// URL. Encrypted + persisted.

import '../../crypto/chat/null_crypto.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../network/chats/send_message.dart';
import 'message_sender.dart';
import 'message_types.dart';
import 'wire_protocol.dart';

/// Builds a link-preview payload.
Map<String, dynamic> buildLinkPreviewPayload({
  required String url,
  String? title,
  String? description,
  String? imageUrl,
  String? siteName,
  String? favicon,
}) {
  return {
    'url': url,
    'title': title,
    'description': description,
    'image_url': imageUrl,
    'site_name': siteName,
    'favicon': favicon,
  };
}

/// Sends a link preview for [url]; optionally linked to an existing message
/// via [messageId].
Future<SendMessageResponse> sendLinkPreview(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  required String url,
  String? title,
  String? description,
  String? imageUrl,
  String? siteName,
  String? favicon,
  String? messageId,
  String? logicalId,
}) {
  return sendTypedMessage(
    crypto,
    contactsDao,
    identityDao,
    messagesDao,
    conversationId: conversationId,
    messageType: MessageType.link_preview,
    payload: buildLinkPreviewPayload(
      url: url,
      title: title,
      description: description,
      imageUrl: imageUrl,
      siteName: siteName,
      favicon: favicon,
    ),
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Stores a received link preview.
Future<IncomingMessageResult> handleLinkPreview({
  required Map<String, dynamic> payload,
  required IncomingContext ctx,
  required MessagesDao messagesDao,
}) async {
  await storeDecryptedContent(
    messagesDao,
    conversationId: ctx.conversationId,
    senderId: ctx.senderContactId,
    ctx: ctx,
    type: MessageType.link_preview,
    payload: payload,
    rawMessage: ctx.rawMessage,
  );
  return IncomingMessageResult(
    type: MessageType.link_preview,
    handled: true,
    messageId: ctx.messageId,
    detail: payload,
  );
}