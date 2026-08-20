import 'package:drift/drift.dart';
import '../tables/conversations.dart';

part 'conversations_queries.g.dart';

/// Data Access Object for the `Conversations` table.
@DriftAccessor(tables: [Conversations])
class ConversationsDao extends DatabaseAccessor<AppDatabase>
    with _$ConversationsDaoMixin {
  ConversationsDao(super.db);

  // Get a single conversation by ID.
  Future<Conversations?> getConversationById(String id) =>
      (select(db.conversations)..where((t) => t.conversationId.equals(id)))
          .getSingleOrNull();

  // Get all conversations (optionally filter by archived/pinned later).
  Future<List<Conversations>> getAllConversations() =>
      select(db.conversations).get();

  // Get conversations ordered by last message time (descending).
  Future<List<Conversations>> getConversationsByLastMessage() =>
      (select(db.conversations)..orderBy([
        (t) => OrderingTerm(expression: t.lastMessageTime, mode: OrderingMode.desc),
      ])).get();

  // Insert a new conversation.
  Future<int> insertConversation(Insertable<Conversations> conversation) =>
      into(db.conversations).insert(conversation);

  // Upsert (insert or update) a conversation.
  Future<void> upsertConversation(Conversations conversation) =>
      into(db.conversations).insertOnConflictUpdate(conversation);

  // Update an existing conversation.
  Future<bool> updateConversation(Conversations conversation) =>
      update(db.conversations).replace(conversation);

  // Delete a conversation.
  Future<int> deleteConversation(String id) =>
      (delete(db.conversations)..where((t) => t.conversationId.equals(id))).go();

  // Update the draft text for a conversation.
  Future<void> updateDraft(String conversationId, String? draft) async {
    await (update(db.conversations)
          ..where((t) => t.conversationId.equals(conversationId)))
        .write(ConversationsCompanion(draft: Value(draft)));
  }

  // Increment the unread count by a given delta (can be negative).
  Future<void> incrementUnread(String conversationId, int delta) async {
    final conversation = await getConversationById(conversationId);
    if (conversation != null) {
      final newCount = conversation.unreadCount + delta;
      await (update(db.conversations)
            ..where((t) => t.conversationId.equals(conversationId)))
          .write(ConversationsCompanion(unreadCount: Value(newCount)));
    }
  }

  // Set the badge state (0 = not processed, 1 = processed, 2 = hide).
  Future<void> setBadge(String conversationId, int badge) async {
    await (update(db.conversations)
          ..where((t) => t.conversationId.equals(conversationId)))
        .write(ConversationsCompanion(badge: Value(badge)));
  }
}