import 'package:drift/drift.dart';
import '../tables/sync_state.dart';

part 'sync_state_queries.g.dart';

/// Data Access Object for the `sync_state` table.
@DriftAccessor(tables: [SyncState])
class SyncStateDao extends DatabaseAccessor<AppDatabase>
    with _$SyncStateDaoMixin {
  SyncStateDao(super.db);

  // Get a single sync state by conversation ID.
  Future<SyncState?> getSyncStateById(String conversationId) =>
      (select(db.syncState)..where((t) => t.conversationId.equals(conversationId)))
          .getSingleOrNull();

  // Get all sync states, ordered by pinned first, then updated_at descending.
  Future<List<SyncState>> getAllSyncStates() => (select(db.syncState)
        ..orderBy([
          (t) => OrderingTerm(expression: t.pinned, mode: OrderingMode.desc),
          (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
        ]))
      .get();

  // Get sync states for a given conversation type.
  Future<List<SyncState>> getSyncStatesByType(int conversationType) =>
      (select(db.syncState)
            ..where((t) => t.conversationType.equals(conversationType)))
          .get();

  // Insert a new sync state.
  Future<int> insertSyncState(Insertable<SyncState> syncState) =>
      into(db.syncState).insert(syncState);

  // Upsert (insert or update) a sync state.
  Future<void> upsertSyncState(SyncState syncState) =>
      into(db.syncState).insertOnConflictUpdate(syncState);

  // Update an existing sync state row.
  Future<bool> updateSyncState(SyncState syncState) =>
      update(db.syncState).replace(syncState);

  // Delete a sync state by conversation ID.
  Future<int> deleteSyncState(String conversationId) =>
      (delete(db.syncState)..where((t) => t.conversationId.equals(conversationId)))
          .go();

  // Update the last read message details and unread count.
  Future<void> updateLastRead(
    String conversationId, {
    required String messageId,
    required String message,
    required int unreadCount,
  }) async {
    await (update(db.syncState)
          ..where((t) => t.conversationId.equals(conversationId)))
        .write(SyncStateCompanion(
      lastReadMessageId: Value(messageId),
      lastReadMessage: Value(message),
      unreadCount: Value(unreadCount),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  // Update the most recent message details.
  Future<void> updateLastMessage(
    String conversationId, {
    required String messageId,
    required String message,
  }) async {
    await (update(db.syncState)
          ..where((t) => t.conversationId.equals(conversationId)))
        .write(SyncStateCompanion(
      lastMessageId: Value(messageId),
      lastMessage: Value(message),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  // Toggle or set the pinned flag and optional position.
  Future<void> setPinned(
    String conversationId, {
    required int pinned,
    int? pinnedPosition,
  }) async {
    await (update(db.syncState)
          ..where((t) => t.conversationId.equals(conversationId)))
        .write(SyncStateCompanion(
      pinned: Value(pinned),
      pinnedPosition: Value(pinnedPosition),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  // Update the colour.
  Future<void> updateColour(String conversationId, String colour) async {
    await (update(db.syncState)
          ..where((t) => t.conversationId.equals(conversationId)))
        .write(SyncStateCompanion(
      colour: Value(colour),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  // Set the muted flag.
  Future<void> setMuted(String conversationId, int muted) async {
    await (update(db.syncState)
          ..where((t) => t.conversationId.equals(conversationId)))
        .write(SyncStateCompanion(
      muted: Value(muted),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  // Increment or set the mentions count.
  Future<void> setMentions(String conversationId, int mentions) async {
    await (update(db.syncState)
          ..where((t) => t.conversationId.equals(conversationId)))
        .write(SyncStateCompanion(
      mentions: Value(mentions),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }
}