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

  // Resolve a message by either its `message_id` or its `logical_message_id`.
  // Edit / delete / pin events address a target that may be referenced by the
  // id the peer sees, which can be either.
  Future<Message?> findMessageByIdOrLogicalId(String id) =>
      (select(db.messages)
            ..where(
              (t) => t.messageId.equals(id) | t.logicalMessageId.equals(id),
            ))
          .getSingleOrNull();

  // Get all messages in a conversation, ordered by message_order.
  Future<List<Message>> getMessagesForConversation(String conversationId) =>
      (select(db.messages)
            ..where((t) => t.conversationId.equals(conversationId))
            ..orderBy([(t) => OrderingTerm(expression: t.messageOrder)]))
          .get();

  // Watch every message in a conversation, ordered by message_order. Re-emits
  // on any insert/update/delete, so the chat view can reflect changes that
  // don't move `sync_state.lastMessageId` — e.g. a sent message advancing from
  // "sending" (0) to "sent" (1), or a later read receipt arriving.
  Stream<List<Message>> watchMessagesForConversation(String conversationId) =>
      (select(db.messages)
            ..where((t) => t.conversationId.equals(conversationId))
            ..orderBy([(t) => OrderingTerm(expression: t.messageOrder)]))
          .watch();

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

  // Insert a new message. The per-conversation display order is assigned here
  // as a monotonic counter, so ordering stays chronological across both
  // senders (each side's crypto chain index is per-sender and would otherwise
  // collide at 0, 1, 2, ...). The crypto chain index is preserved separately
  // in [Messages.chainIndex].
  Future<int> insertMessage(MessagesCompanion message) =>
      db.transaction(() async {
        final order = await _nextMessageOrder(message.conversationId.value);
        final inserted = await into(db.messages).insertReturning(
          message.copyWith(messageOrder: Value(order)),
        );
        await db.syncStateDao.recordLatestMessage(
          conversationId: inserted.conversationId,
          messageId: inserted.messageId,
          message: inserted.decryptedMessage,
          updatedAt: inserted.timestamp,
        );
        return 1;
      });

  // Fill in an optimistically-inserted placeholder row once it has been
  // encrypted and is ready to send. Only the crypto/transport fields are
  // written, so the row keeps its `message_order` (and therefore its place in
  // the conversation) and `decryptedMessage` (the plaintext the user typed).
  Future<void> updateSentMessage({
    required String messageId,
    required int chainIndex,
    required int senderSequence,
    required Uint8List ciphertext,
    required Uint8List nonce,
    required Uint8List mac,
    required int timestamp,
    int status = 0,
  }) async {
    await (update(db.messages)..where((t) => t.messageId.equals(messageId)))
        .write(
          MessagesCompanion(
            chainIndex: Value(chainIndex),
            senderSequence: Value(senderSequence),
            ciphertext: Value(ciphertext),
            nonce: Value(nonce),
            mac: Value(mac),
            timestamp: Value(timestamp),
            status: Value(status),
          ),
        );
  }

  Future<int> _nextMessageOrder(String conversationId) async {
    final maxOrder = db.messages.messageOrder.max();
    final query = selectOnly(db.messages)
      ..addColumns([maxOrder])
      ..where(db.messages.conversationId.equals(conversationId));
    final row = await query.getSingle();
    return (row.read(maxOrder) ?? -1) + 1;
  }

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

  // Marks a just-sent message as accepted by the server (status 1). Only
  // advances a row that is still in the "sending" state (status 0), so a
  // delivery/read receipt that already moved it to 2/3 is never downgraded.
  Future<void> markMessageSent(String messageId) async {
    await (update(db.messages)
          ..where((t) => t.messageId.equals(messageId) & t.status.equals(0)))
        .write(const MessagesCompanion(status: Value(1)));
  }

  // Marks messages as delivered (status 2). Only advances from sending/sent
  // (status 0/1) to delivered; never downgrades read (3).
  Future<void> markMessagesAsDelivered(List<String> messageIds) async {
    if (messageIds.isEmpty) return;
    await (update(db.messages)
          ..where((t) =>
              t.messageId.isIn(messageIds) &
              t.status.isSmallerThanValue(2)))
        .write(const MessagesCompanion(status: Value(2)));
  }

  // Marks a message as delivered if it was still unsent/sent.
  Future<void> markMessageAsDelivered(String messageId) async {
    await markMessagesAsDelivered([messageId]);
  }

  // Marks messages as read (status 3) and stamps `readAt`. Only advances
  // status (0/1/2 -> 3), never downgrades.
  Future<void> markMessagesAsRead(List<String> messageIds, {int? readAt}) async {
    if (messageIds.isEmpty) return;
    final ts = readAt ?? DateTime.now().millisecondsSinceEpoch;
    await (update(db.messages)
          ..where((t) =>
              t.messageId.isIn(messageIds) &
              t.status.isSmallerThanValue(3)))
        .write(MessagesCompanion(
          status: const Value(3),
          readAt: Value(ts),
        ));
  }

  // Marks a single message as read.
  Future<void> markMessageAsRead(String messageId, {int? readAt}) async {
    await markMessagesAsRead([messageId], readAt: readAt);
  }

  // Update only the decrypted content of a message.
  Future<void> updateDecryptedMessage(
    String messageId,
    String? decryptedMessage,
  ) async {
    await (update(db.messages)..where((t) => t.messageId.equals(messageId)))
        .write(MessagesCompanion(decryptedMessage: Value(decryptedMessage)));
  }

  // Delete a message by ID.
  Future<int> deleteMessage(String id) =>
      (delete(db.messages)..where((t) => t.messageId.equals(id))).go();

  // Delete every message in a conversation.
  Future<int> deleteMessagesForConversation(String conversationId) =>
      (delete(db.messages)
            ..where((t) => t.conversationId.equals(conversationId)))
          .go();

  // Insert or overwrite a message by its primary key (`message_id`). Used by
  // an edit (17): the edited message keeps the original `message_id` (so both
  // peers replace the same row) but carries fresh ciphertext and text. Unlike
  // [insertMessage] it does not reassign `message_order` or bump the
  // conversation preview, so an edit stays in place in history.
  Future<void> upsertMessage(MessagesCompanion message) =>
      into(db.messages).insertOnConflictUpdate(message);

  // Pin (1) or unpin (0) a single message in the conversation.
  Future<void> setMessagePinned(String messageId, int pinned) async {
    await (update(db.messages)..where((t) => t.messageId.equals(messageId)))
        .write(MessagesCompanion(pinned: Value(pinned)));
  }

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
