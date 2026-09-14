// module name: error_report
//
// MessageType.error (8) — out-of-band protocol error reporting. Control
// (plaintext envelope), never persisted. The local app surfaces the detail
// (e.g. a failed handshake pushed to a companion device).

import '../../crypto/chat/null_crypto.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../network/chats/send_message.dart';
import 'message_sender.dart';
import 'message_types.dart';
import 'wire_protocol.dart';

/// Builds an error-report payload.
Map<String, dynamic> buildErrorPayload({
  required int code,
  required String message,
  String? details,
  String? origin,
  String? conversationId,
}) {
  return {
    'code': code,
    'message': message,
    'details': details,
    'origin': origin,
    'conversation_id': conversationId,
  };
}

/// Sends an error report to the peer.
Future<SendMessageResponse> sendErrorReport(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  required int code,
  required String message,
  String? details,
  String? origin,
  String? messageId,
  String? logicalId,
}) {
  return sendTypedMessage(
    crypto,
    contactsDao,
    identityDao,
    messagesDao,
    conversationId: conversationId,
    messageType: MessageType.error,
    payload: buildErrorPayload(
      code: code,
      message: message,
      details: details,
      origin: origin,
      conversationId: conversationId,
    ),
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Receive side for an error report. The payload is forwarded (unnormalized)
/// in `detail` — the wiring decides how to surface it to the user.
Future<IncomingMessageResult> handleErrorReport({
  required ControlEnvelope env,
  required IncomingContext ctx,
}) async {
  return IncomingMessageResult(
    type: MessageType.error,
    handled: true,
    messageId: ctx.messageId,
    detail: env.payload,
  );
}