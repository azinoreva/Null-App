import 'package:drift/drift.dart';
import '../app_database.dart';

import '../tables/messages.dart';

part 'messages_queries.g.dart';

/// Data Access Object for the `Messages` table.
@DriftAccessor(tables: [Messages])
class MessagesDao extends DatabaseAccessor<AppDatabase>
    with _$MessagesDaoMixin {
  MessagesDao(super.db);

  // Get a single message by its ID.
  Future<Message?> getMessageById(String id) => (select(
    db.messages,
  )..where((t) => t.messageId.equals(id))).getSingleOrNull();

  // Get all messages in a conversation, ordered by message_order.
  Future<List<Message>> getMessagesForConversation(String conversationId) =>
      (select(db.messages)
            ..where((t) => t.conversationId.equals(conversationId))
            ..orderBy([(t) => OrderingTerm(expression: t.messageOrder)]))
          .get();

  // Get messages for a conversation with pagination.
  Future<List<Message>> getMessagesForConversationPaginated(
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
  Future<int> insertMessage(Insertable<Message> message) =>
      into(db.messages).insert(message);

  // Insert multiple messages in a batch (atomic).
  Future<void> insertMessages(List<Insertable<Message>> messages) =>
      batch((batch) {
        batch.insertAll(db.messages, messages);
      });

  // Update an existing message row.
  Future<bool> updateMessage(Message message) =>
      update(db.messages).replace(message);

  // Update only the status of a message.
  Future<void> updateMessageStatus(String messageId, int newStatus) async {
    await (update(db.messages)..where((t) => t.messageId.equals(messageId)))
        .write(MessagesCompanion(status: Value(newStatus)));
  }

  // Update only the decrypted content of a message.
  Future<void> updateDecryptedMessage(
    String messageId,
    String? decryptedMessage,
  ) async {
    await (update(db.messages)..where((t) => t.messageId.equals(messageId)))
        .write(
          MessagesCompanion(decryptedMessage: Value(decryptedMessage)),
        );
  }

  // Delete a message by ID.
  Future<int> deleteMessage(String id) =>
      (delete(db.messages)..where((t) => t.messageId.equals(id))).go();

  // Get the latest message in a conversation (ordered by message_order desc).
  Future<Message?> getLatestMessage(String conversationId) =>
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

  Future<int> getLastSenderSequence({
    required String conversationId,
    required String senderId,
  }) async {
    final sequence = db.messages.senderSequence;
    final query = selectOnly(db.messages)
      ..addColumns([sequence.max()])
      ..where(
        db.messages.conversationId.equals(conversationId) &
            db.messages.senderId.equals(senderId),
      );
    final row = await query.getSingle();
    return row.read(sequence.max()) ?? 0;
  }

  // Get the last [limit] messages of a conversation, highest message_order
  // first. Used as a fallback when there is no last message id to anchor on.
  Future<List<Message>> getLastMessages(
    String conversationId, {
    int limit = 20,
  }) =>
      (select(db.messages)
            ..where((t) => t.conversationId.equals(conversationId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.messageOrder,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(limit))
          .get();

  // Get up to [limit] messages with message_order <= [maxOrder], highest
  // message_order first. Returns descending; callers reverse for display.
  Future<List<Message>> getMessagesBeforeOrder(
    String conversationId,
    int maxOrder, {
    int limit = 20,
  }) =>
      (select(db.messages)
            ..where(
              (t) =>
                  t.conversationId.equals(conversationId) &
                  t.messageOrder.isSmallerOrEqualValue(maxOrder),
            )
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.messageOrder,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(limit))
          .get();

  // Get every message with message_order > [minOrder], ascending. Used to
  // append only the new messages after the last one already loaded.
  Future<List<Message>> getMessagesAfterOrder(
    String conversationId,
    int minOrder,
  ) =>
      (select(db.messages)
            ..where(
              (t) =>
                  t.conversationId.equals(conversationId) &
                  t.messageOrder.isBiggerThanValue(minOrder),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.messageOrder)]))
          .get();

  // Find messages with a specific status (useful for sync).
  Future<List<Message>> getMessagesByStatus(
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
