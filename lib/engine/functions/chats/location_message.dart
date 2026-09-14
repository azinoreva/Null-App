// module name: location_message
//
// MessageType.location (21) — geolocation share. Encrypted + persisted.

import '../../crypto/chat/null_crypto.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../network/chats/send_message.dart';
import 'message_sender.dart';
import 'message_types.dart';
import 'wire_protocol.dart';

/// Builds a location payload. `lat` / `lon` are in signed decimal degrees,
/// accuracy in meters.
Map<String, dynamic> buildLocationPayload({
  required double lat,
  required double lon,
  double? accuracy,
  String? label,
  int? at,
}) {
  return {
    'lat': lat,
    'lon': lon,
    'accuracy': accuracy,
    'label': label,
    'at': at ?? DateTime.now().millisecondsSinceEpoch,
  };
}

/// Sends a location message.
Future<SendMessageResponse> sendLocationMessage(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  required double lat,
  required double lon,
  double? accuracy,
  String? label,
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
    messageType: MessageType.location,
    payload: buildLocationPayload(
      lat: lat,
      lon: lon,
      accuracy: accuracy,
      label: label,
      at: at,
    ),
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Stores a received location message.
Future<IncomingMessageResult> handleLocationMessage({
  required Map<String, dynamic> payload,
  required IncomingContext ctx,
  required MessagesDao messagesDao,
}) async {
  await storeDecryptedContent(
    messagesDao,
    conversationId: ctx.conversationId,
    senderId: ctx.senderContactId,
    ctx: ctx,
    type: MessageType.location,
    payload: payload,
    rawMessage: ctx.rawMessage,
  );
  return IncomingMessageResult(
    type: MessageType.location,
    handled: true,
    messageId: ctx.messageId,
    detail: payload,
  );
}