// module name: room_membership
//
// MessageType.join (5) / MessageType.leave (6) — room / group membership
// events. Control (plaintext envelope); the receiver applies the
// membership change to the local Groups / GroupMembers tables.

import 'package:drift/drift.dart';

import '../../crypto/chat/null_crypto.dart';
import '../../database/app_database.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/group_members_queries.dart';
import '../../database/queries/groups_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../network/chats/send_message.dart';
import 'message_sender.dart';
import 'message_types.dart';
import 'wire_protocol.dart';

/// Builds a join/leave payload.
Map<String, dynamic> buildMembershipPayload({
  required String roomId,
  required String userId,
  String? actorId,
  String? reason,
  String? name,
  String? publicKey,
}) {
  return {
    'room_id': roomId,
    'user_id': userId,
    'actor_id': actorId,
    'reason': reason,
    'name': name,
    'public_key': publicKey,
  };
}

/// Sends a join event for [userId] in [roomId].
Future<SendMessageResponse> sendJoin(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  required String roomId,
  required String userId,
  String? actorId,
  String? reason,
  String? name,
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
    messageType: MessageType.join,
    payload: buildMembershipPayload(
      roomId: roomId,
      userId: userId,
      actorId: actorId,
      reason: reason,
      name: name,
      publicKey: publicKey,
    ),
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Sends a leave event for [userId] in [roomId].
Future<SendMessageResponse> sendLeave(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  required String roomId,
  required String userId,
  String? actorId,
  String? reason,
  String? messageId,
  String? logicalId,
}) {
  return sendTypedMessage(
    crypto,
    contactsDao,
    identityDao,
    messagesDao,
    conversationId: conversationId,
    messageType: MessageType.leave,
    payload: buildMembershipPayload(
      roomId: roomId,
      userId: userId,
      actorId: actorId,
      reason: reason,
    ),
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Applies a join event. If the group exists locally the member row is
/// upserted (idempotent). Requires a [GroupsDao] / [GroupMembersDao].
Future<IncomingMessageResult> handleJoin({
  required ControlEnvelope env,
  required IncomingContext ctx,
  required GroupsDao groupsDao,
  required GroupMembersDao groupMembersDao,
  required AppDatabase database,
}) async {
  final roomId = env.payload['room_id'] as String? ?? ctx.conversationId;
  final userId = env.payload['user_id'] as String? ?? ctx.senderContactId;

  if (await groupsDao.getGroupById(roomId) != null &&
      !await groupMembersDao.isMember(roomId, userId)) {
    await groupMembersDao.addMember(
      GroupMembersCompanion.insert(
        groupId: roomId,
        identityId: userId,
        publicKey: Value(env.payload['public_key'] as String?),
        name: Value(env.payload['name'] as String?),
        joinedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    final identity =
        await database.identityDao.getCurrentIdentityOrNull();
    if (identity != null && userId == identity.identityId) {
      await database.sessionsDao.markEstablished(roomId);
    }
  }

  return IncomingMessageResult(
    type: MessageType.join,
    handled: true,
    messageId: ctx.messageId,
    detail: env.payload,
  );
}

/// Applies a leave event by removing the member row.
Future<IncomingMessageResult> handleLeave({
  required ControlEnvelope env,
  required IncomingContext ctx,
  required GroupMembersDao groupMembersDao,
}) async {
  final roomId = env.payload['room_id'] as String? ?? ctx.conversationId;
  final userId = env.payload['user_id'] as String? ?? ctx.senderContactId;

  await groupMembersDao.removeMember(roomId, userId);

  return IncomingMessageResult(
    type: MessageType.leave,
    handled: true,
    messageId: ctx.messageId,
    detail: env.payload,
  );
}