import 'package:drift/drift.dart';

import '../tables/messages.dart';

part 'messages_queries.g.dart';

/// Data Access Object for the `Messages` table.
@DriftAccessor(tables: [Messages])
class MessagesDao extends DatabaseAccessor<AppDatabase>
    with _$MessagesDaoMixin {
  MessagesDao(super.db);

  // Get a single message by its ID.
  Future<Messages?> getMessageById(String id) => (select(
    db.messages,
  )..where((t) => t.messageId.equals(id))).getSingleOrNull();

  // Get all messages in a conversation, ordered by message_order.
  Future<List<Messages>> getMessagesForConversation(String conversationId) =>
      (select(db.messages)
            ..where((t) => t.conversationId.equals(conversationId))
            ..orderBy([(t) => OrderingTerm(expression: t.messageOrder)]))
          .get();

  // Get messages for a conversation with pagination.
  Future<List<Messages>> getMessagesForConversationPaginated(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  }) =>
      (select(db.messages)
            ..where((t) => t.conversationId.equals(conversationId))
            ..orderBy([(t) => OrderingTerm(expression: t.messageOrder)])
            ..limit(limit, offset: offset))
          .get();

  // Insert a new message.
  Future<int> insertMessage(Insertable<Messages> message) =>
      into(db.messages).insert(message);

  // Insert multiple messages in a batch (atomic).
  Future<void> insertMessages(List<Insertable<Messages>> messages) =>
      batch((batch) {
        batch.insertAll(db.messages, messages);
      });

  // Update an existing message row.
  Future<bool> updateMessage(Messages message) =>
      update(db.messages).replace(message);

  // Update only the status of a message.
  Future<void> updateMessageStatus(String messageId, int newStatus) async {
    await (update(db.messages)..where((t) => t.messageId.equals(messageId)))
        .write(MessagesCompanion(status: Value(newStatus)));
  }

  // Delete a message by ID.
  Future<int> deleteMessage(String id) =>
      (delete(db.messages)..where((t) => t.messageId.equals(id))).go();

  // Get the latest message in a conversation (ordered by message_order desc).
  Future<Messages?> getLatestMessage(String conversationId) =>
      (select(db.messages)
            ..where((t) => t.conversationId.equals(conversationId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.messageOrder,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(1))
          .getSingleOrNull();

  // Find messages with a specific status (useful for sync).
  Future<List<Messages>> getMessagesByStatus(
    String conversationId,
    int status,
  ) =>
      (select(db.messages)
            ..where(
              (t) =>
                  t.conversationId.equals(conversationId) &
                  t.status.equals(status),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.messageOrder)]))
          .get();
}
