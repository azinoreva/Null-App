// module name: contact_card
//
// MessageType.contact_card (22) — shared vCard / contact card. Encrypted +
// persisted. `contact_id` references the sharer's address-book id; the card
// fields carry the shared snapshot.

import '../../crypto/chat/null_crypto.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../network/chats/send_message.dart';
import 'message_sender.dart';
import 'message_types.dart';
import 'wire_protocol.dart';

/// Builds a contact-card payload. [cardId] distinguishes multiple cards in
/// one message when the sender shares several.
Map<String, dynamic> buildContactCardPayload({
  required String contactId,
  required String name,
  String? phone,
  String? email,
  String? about,
  String? avatarBase64,
  String? vcard,
  String? cardId,
}) {
  return {
    'contact_id': contactId,
    'name': name,
    'phone': phone,
    'email': email,
    'about': about,
    'avatar_base64': avatarBase64,
    'vcard': vcard,
    'card_id': cardId,
  };
}

/// Sends a contact card.
Future<SendMessageResponse> sendContactCard(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  required String contactId,
  required String name,
  String? phone,
  String? email,
  String? about,
  String? avatarBase64,
  String? vcard,
  String? cardId,
  String? messageId,
  String? logicalId,
}) {
  return sendTypedMessage(
    crypto,
    contactsDao,
    identityDao,
    messagesDao,
    conversationId: conversationId,
    messageType: MessageType.contact_card,
    payload: buildContactCardPayload(
      contactId: contactId,
      name: name,
      phone: phone,
      email: email,
      about: about,
      avatarBase64: avatarBase64,
      vcard: vcard,
      cardId: cardId,
    ),
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Stores a received contact card.
Future<IncomingMessageResult> handleContactCard({
  required Map<String, dynamic> payload,
  required IncomingContext ctx,
  required MessagesDao messagesDao,
}) async {
  await storeDecryptedContent(
    messagesDao,
    conversationId: ctx.conversationId,
    senderId: ctx.senderContactId,
    ctx: ctx,
    type: MessageType.contact_card,
    payload: payload,
    rawMessage: ctx.rawMessage,
  );
  return IncomingMessageResult(
    type: MessageType.contact_card,
    handled: true,
    messageId: ctx.messageId,
    detail: payload,
  );
}