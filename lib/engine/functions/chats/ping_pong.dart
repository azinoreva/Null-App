// module name: ping_pong
//
// MessageType.ping (3) / MessageType.pong (4) — presence round-trip.
// Control (plaintext envelope), never persisted.

import '../../crypto/chat/null_crypto.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../network/chats/send_message.dart';
import 'message_sender.dart';
import 'message_types.dart';
import 'wire_protocol.dart';

/// Sends a presence ping with the current epoch-millis timestamp.
Future<SendMessageResponse> sendPing(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  int? sentAt,
  String? messageId,
  String? logicalId,
}) {
  return sendTypedMessage(
    crypto,
    contactsDao,
    identityDao,
    messagesDao,
    conversationId: conversationId,
    messageType: MessageType.ping,
    payload: {
      'sent_at': sentAt ?? DateTime.now().millisecondsSinceEpoch,
    },
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Replies to a ping with [forPingAt] echoing the original `sent_at`
/// so the initiator can compute round-trip time.
Future<SendMessageResponse> sendPong(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  required int forPingAt,
  int? sentAt,
  String? messageId,
  String? logicalId,
}) {
  return sendTypedMessage(
    crypto,
    contactsDao,
    identityDao,
    messagesDao,
    conversationId: conversationId,
    messageType: MessageType.pong,
    payload: {
      'for_ping_at': forPingAt,
      'sent_at': sentAt ?? DateTime.now().millisecondsSinceEpoch,
    },
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Receive side for a ping. Exposes `detail` so the wiring can decide to
/// auto-reply with [sendPong].
Future<IncomingMessageResult> handlePing({
  required ControlEnvelope env,
  required IncomingContext ctx,
}) async {
  return IncomingMessageResult(
    type: MessageType.ping,
    handled: true,
    messageId: ctx.messageId,
    detail: env.payload,
  );
}

/// Receive side for a pong. The wiring can use `env.payload['for_ping_at']`
/// to resolve an outstanding ping and surface latency.
Future<IncomingMessageResult> handlePong({
  required ControlEnvelope env,
  required IncomingContext ctx,
}) async {
  return IncomingMessageResult(
    type: MessageType.pong,
    handled: true,
    messageId: ctx.messageId,
    detail: env.payload,
  );
}