// module name: metadata_message
//
// MessageType.metadata (7) — conversation / room metadata (title, avatar,
// colour). Control (plaintext envelope); the receiver updates the
// denormalized `sync_state` row that drives the chat-list UI.

import 'package:drift/drift.dart';

import '../../crypto/chat/null_crypto.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../database/queries/sync_state_queries.dart';
import '../../network/chats/send_message.dart';
import 'message_sender.dart';
import 'message_types.dart';
import 'wire_protocol.dart';

/// Builds a conversation-metadata payload. Every field is optional — only
/// the ones the sender intends to change are included.
Map<String, dynamic> buildMetadataPayload({
  String? title,
  String? subtitle,
  String? avatar,
  String? colour,
  String? updatedBy,
}) {
  return {
    'title': title,
    'subtitle': subtitle,
    'avatar': avatar,
    'colour': colour,
    'updated_by': updatedBy,
  };
}

/// Sends a metadata update for a conversation.
Future<SendMessageResponse> sendMetadata(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  String? title,
  String? subtitle,
  String? avatar,
  String? colour,
  String? updatedBy,
  String? messageId,
  String? logicalId,
}) {
  return sendTypedMessage(
    crypto,
    contactsDao,
    identityDao,
    messagesDao,
    conversationId: conversationId,
    messageType: MessageType.metadata,
    payload: buildMetadataPayload(
      title: title,
      subtitle: subtitle,
      avatar: avatar,
      colour: colour,
      updatedBy: updatedBy,
    ),
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Applies a metadata update to the conversation's `sync_state` row.
/// Unknown fields are carried in `detail` for the wiring to handle.
Future<IncomingMessageResult> handleMetadata({
  required ControlEnvelope env,
  required IncomingContext ctx,
  required SyncStateDao syncStateDao,
}) async {
  final payload = env.payload;
  final title = payload['title'] as String?;
  final avatar = payload['avatar'] as String?;
  final colour = payload['colour'] as String?;

  if (title != null || avatar != null || colour != null) {
    final existing = await syncStateDao.getSyncStateById(ctx.conversationId);
    final resolvedColour = colour ?? existing?.colour;
    if (existing != null && resolvedColour != null) {
      await (syncStateDao
              .update(syncStateDao.db.syncState)
            ..where((t) => t.conversationId.equals(ctx.conversationId)))
          .write(
        SyncStateCompanion(
          displayName: Value(title ?? existing.displayName),
          avatar: Value(avatar ?? existing.avatar),
          colour: Value(resolvedColour),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
    }
  }

  return IncomingMessageResult(
    type: MessageType.metadata,
    handled: true,
    messageId: ctx.messageId,
    detail: payload,
  );
}