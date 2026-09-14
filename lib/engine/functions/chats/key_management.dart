// module name: key_management
//
// MessageType.keys (9) — symmetric key lifecycle signals (query / rotate /
// report). Control (plaintext envelope), never stored in `Messages`. The
// actual symmetric material is always negotiated via the type 0 handshake —
// this type only coordinates *when* to re-key.

import '../../crypto/chat/null_crypto.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../network/chats/send_message.dart';
import 'message_sender.dart';
import 'message_types.dart';
import 'wire_protocol.dart';

const String actionsQuery = 'query';
const String actionsRotate = 'rotate';
const String actionsReport = 'report';

/// Builds a key-management payload.
Map<String, dynamic> buildKeysPayload({
  required String action,
  String? groupId,
  int? keyVersion,
  String? publicKey,
}) {
  return {
    'action': action,
    'group_id': groupId,
    'key_version': keyVersion,
    'public_key': publicKey,
  };
}

/// Sends a key-management signal.
Future<SendMessageResponse> sendKeyManagement(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  required String action,
  String? groupId,
  int? keyVersion,
  String? publicKey,
  String? messageId,
  String? logicalId,
}) {
  return sendTypedMessage(
    crypto,
    contactsDao,
    identityDao,
    messagesDao,
    conversationId: conversationId,
    messageType: MessageType.keys,
    payload: buildKeysPayload(
      action: action,
      groupId: groupId,
      keyVersion: keyVersion,
      publicKey: publicKey,
    ),
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Receive side for a key-management signal.
///
/// Current v1 behaviour: v1 `rotate` / `report` for a group are validated
/// and forwarded in `detail`; actually re-keying requires a fresh type 0
/// handshake which the wiring may trigger when it observes the returned
/// `detail['action'] == 'rotate'`.
Future<IncomingMessageResult> handleKeyManagement({
  required ControlEnvelope env,
  required IncomingContext ctx,
}) async {
  final action = env.payload['action'] as String?;
  final known =
      action == actionsQuery || action == actionsRotate || action == actionsReport;
  return IncomingMessageResult(
    type: MessageType.keys,
    handled: known,
    messageId: ctx.messageId,
    detail: env.payload,
    reason: known ? null : 'Unsupported key action "$action".',
  );
}