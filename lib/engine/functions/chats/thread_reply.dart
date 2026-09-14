// module name: thread_reply
//
// MessageType.thread_reply (19) — nested / side-channel reply. Encrypted +
// persisted; the row's `replyTo` column references the parent message id so
// threading can be rendered without extra state.

import '../../crypto/chat/null_crypto.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../network/chats/send_message.dart';
import 'message_sender.dart';
import 'message_types.dart';
import 'wire_protocol.dart';

/// Builds a thread-reply payload. [parentMessageId] is the logical id of
/// the message being replied to.
Map<String, dynamic> buildThreadReplyPayload({
  required String parentMessageId,
  required String text,
  Map<String, dynamic>? context,
}) {
  return {
    'parent_message_id': parentMessageId,
    'text': text,
    'context': context ?? const {},
  };
}

/// Sends a thread reply. The parent id is also stamped onto the row's
/// `replyTo` column.
Future<SendMessageResponse> sendThreadReply(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  required String parentMessageId,
  required String text,
  Map<String, dynamic>? context,
  String? messageId,
  String? logicalId,
}) {
  return sendTypedMessage(
    crypto,
    contactsDao,
    identityDao,
    messagesDao,
    conversationId: conversationId,
    messageType: MessageType.thread_reply,
    payload: buildThreadReplyPayload(
      parentMessageId: parentMessageId,
      text: text,
      context: context,
    ),
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
    replyTo: parentMessageId,
  );
}

/// Stores a received thread reply with `replyTo` pointing at the parent.
Future<IncomingMessageResult> handleThreadReply({
  required Map<String, dynamic> payload,
  required IncomingContext ctx,
  required MessagesDao messagesDao,
}) async {
  final parentId = payload['parent_message_id'] as String?;
  await storeDecryptedContent(
    messagesDao,
    conversationId: ctx.conversationId,
    senderId: ctx.senderContactId,
    ctx: ctx,
    type: MessageType.thread_reply,
    payload: payload,
    rawMessage: ctx.rawMessage,
    replyTo: parentId,
  );
  return IncomingMessageResult(
    type: MessageType.thread_reply,
    handled: true,
    messageId: ctx.messageId,
    detail: payload,
  );
}