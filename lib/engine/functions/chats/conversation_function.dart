import 'package:drift/drift.dart';
import '../../database/queries/conversations_queries.dart';

/// Creates a new conversation with sensible defaults.
Future<void> createConversation(
  ConversationsDao dao, {
  required String conversationId,
  required int conversationType,
  required String serverId,
  String? lastMessageId,
  int? lastMessageTime,
}) async {
  final now = DateTime.now().millisecondsSinceEpoch;

  final companion = ConversationsCompanion.insert(
    conversationId: conversationId,
    conversationType: conversationType,
    serverId: serverId,
    lastMessageId: Value(lastMessageId),
    lastMessageTime: Value(lastMessageTime),
    unreadCount: const Value(0),
    muted: const Value(0),
    pinned: const Value(0),
    archived: const Value(0),
    createdAt: now,
    updatedAt: now,
  );

  await dao.insertConversation(companion);
}

/// Updates any field of a conversation except conversationId.
/// Pass only the fields you want to change; everything else is left as-is.
/// `updatedAt` is refreshed automatically on every call.
Future<void> updateConversationFields(
  ConversationsDao dao,
  String conversationId, {
  int? conversationType,
  String? lastMessageId,
  int? lastMessageTime,
  int? unreadCount,
  int? muted,
  int? pinned,
  int? archived,
  String? draft,
  String? serverId,
  String? sound,
  int? badge,
  int? vibration,
}) async {
  final companion = ConversationsCompanion(
    conversationType: conversationType != null
        ? Value(conversationType)
        : const Value.absent(),
    lastMessageId: lastMessageId != null
        ? Value(lastMessageId)
        : const Value.absent(),
    lastMessageTime: lastMessageTime != null
        ? Value(lastMessageTime)
        : const Value.absent(),
    unreadCount:
        unreadCount != null ? Value(unreadCount) : const Value.absent(),
    muted: muted != null ? Value(muted) : const Value.absent(),
    pinned: pinned != null ? Value(pinned) : const Value.absent(),
    archived: archived != null ? Value(archived) : const Value.absent(),
    draft: draft != null ? Value(draft) : const Value.absent(),
    serverId: serverId != null ? Value(serverId) : const Value.absent(),
    sound: sound != null ? Value(sound) : const Value.absent(),
    badge: badge != null ? Value(badge) : const Value.absent(),
    vibration: vibration != null ? Value(vibration) : const Value.absent(),
    updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
  );

  await (dao.update(dao.db.conversations)
        ..where((t) => t.conversationId.equals(conversationId)))
      .write(companion);
}

/// Deletes a conversation by ID.
Future<int> deleteConversationById(
  ConversationsDao dao,
  String conversationId,
) {
  return dao.deleteConversation(conversationId);
}