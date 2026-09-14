// module name: polls
//
// MessageType.polls (12) — poll definition (encrypted + persisted).
// MessageType.poll_vote (13) — a cast vote (encrypted + persisted).
// MessageType.poll_close (14) — admin closes a poll (plaintext control).
//
// v1 stores the poll / vote payloads in `Messages` like any content row.
// Poll state (open/closed, tallied votes) is derived from those rows; no
// dedicated Polls table exists yet (documented in README).

import '../../crypto/chat/null_crypto.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../network/chats/send_message.dart';
import 'message_sender.dart';
import 'message_types.dart';
import 'wire_protocol.dart';

/// Builds a poll-definition payload. `options` is a list of
/// `{ 'index': int, 'text': String }`.
Map<String, dynamic> buildPollPayload({
  required String pollId,
  required String question,
  required List<Map<String, dynamic>> options,
  bool multipleChoice = false,
  int? endsAt,
  String? createdBy,
}) {
  return {
    'poll_id': pollId,
    'question': question,
    'options': options,
    'multiple_choice': multipleChoice,
    'ends_at': endsAt,
    'created_by': createdBy,
  };
}

/// Sends a new poll (ratchet-encrypted, persisted).
Future<SendMessageResponse> sendPoll(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  required String pollId,
  required String question,
  required List<Map<String, dynamic>> options,
  bool multipleChoice = false,
  int? endsAt,
  String? createdBy,
  String? messageId,
  String? logicalId,
}) {
  return sendTypedMessage(
    crypto,
    contactsDao,
    identityDao,
    messagesDao,
    conversationId: conversationId,
    messageType: MessageType.polls,
    payload: buildPollPayload(
      pollId: pollId,
      question: question,
      options: options,
      multipleChoice: multipleChoice,
      endsAt: endsAt,
      createdBy: createdBy,
    ),
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Sends a vote for [optionIndices] on [pollId].
Future<SendMessageResponse> sendPollVote(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  required String pollId,
  required List<int> optionIndices,
  String? voterId,
  String? messageId,
  String? logicalId,
}) {
  return sendTypedMessage(
    crypto,
    contactsDao,
    identityDao,
    messagesDao,
    conversationId: conversationId,
    messageType: MessageType.poll_vote,
    payload: {
      'poll_id': pollId,
      'option_indices': optionIndices,
      'voter_id': voterId,
    },
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Sends a plaintext poll-close signal (not persisted).
Future<SendMessageResponse> sendPollClose(
  NullCrypto crypto,
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao, {
  required String conversationId,
  required String serverId,
  required String pollId,
  String? closedBy,
  String? messageId,
  String? logicalId,
}) {
  return sendTypedMessage(
    crypto,
    contactsDao,
    identityDao,
    messagesDao,
    conversationId: conversationId,
    messageType: MessageType.poll_close,
    payload: {
      'poll_id': pollId,
      'closed_by': closedBy,
    },
    serverId: serverId,
    messageId: messageId,
    logicalId: logicalId,
  );
}

/// Stores a received poll definition.
Future<IncomingMessageResult> handlePoll({
  required Map<String, dynamic> payload,
  required IncomingContext ctx,
  required MessagesDao messagesDao,
}) async {
  await storeDecryptedContent(
    messagesDao,
    conversationId: ctx.conversationId,
    senderId: ctx.senderContactId,
    ctx: ctx,
    type: MessageType.polls,
    payload: payload,
    rawMessage: ctx.rawMessage,
  );
  return IncomingMessageResult(
    type: MessageType.polls,
    handled: true,
    messageId: ctx.messageId,
    detail: payload,
  );
}

/// Stores a received vote.
Future<IncomingMessageResult> handlePollVote({
  required Map<String, dynamic> payload,
  required IncomingContext ctx,
  required MessagesDao messagesDao,
}) async {
  await storeDecryptedContent(
    messagesDao,
    conversationId: ctx.conversationId,
    senderId: ctx.senderContactId,
    ctx: ctx,
    type: MessageType.poll_vote,
    payload: payload,
    rawMessage: ctx.rawMessage,
  );
  return IncomingMessageResult(
    type: MessageType.poll_vote,
    handled: true,
    messageId: ctx.messageId,
    detail: payload,
  );
}

/// Receive side for a poll-close signal. The wiring should use
/// `detail['poll_id']` to flip any locally-rendered poll to closed; no
/// local row is written (control envelope).
Future<IncomingMessageResult> handlePollClose({
  required ControlEnvelope env,
  required IncomingContext ctx,
}) async {
  return IncomingMessageResult(
    type: MessageType.poll_close,
    handled: true,
    messageId: ctx.messageId,
    detail: env.payload,
  );
}