import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sync_state.dart';

part 'sync_state_queries.g.dart';

/// Data Access Object for the `sync_state` table.
@DriftAccessor(tables: [SyncState])
class SyncStateDao extends DatabaseAccessor<AppDatabase>
    with _$SyncStateDaoMixin {
  SyncStateDao(super.db);

  // Get a single sync state by conversation ID.
  Future<SyncStateData?> getSyncStateById(String conversationId) => (select(
    db.syncState,
  )..where((t) => t.conversationId.equals(conversationId))).getSingleOrNull();

  // Watch a single sync state row. The stream re-emits whenever the row is
  // inserted, updated, or deleted, so callers can react to `lastMessageId`
  // and `draft` changes live.
  Stream<SyncStateData?> watchSyncStateById(String conversationId) => (select(
    db.syncState,
  )..where((t) => t.conversationId.equals(conversationId))).watchSingleOrNull();

  // Get all sync states, ordered by pinned first, then updated_at descending.
  Future<List<SyncStateData>> getAllSyncStates() =>
      (select(db.syncState)..orderBy([
            (t) => OrderingTerm(expression: t.pinned, mode: OrderingMode.desc),
            (t) =>
                OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
          ]))
          .get();

  // Watch every sync state row, ordered by pinned first, then updated_at
  // descending. The stream re-emits whenever any row in `sync_state` is
  // created, updated, or deleted, so UI state stays in sync with the table.
  Stream<List<SyncStateData>> watchAllSyncStates() =>
      (select(db.syncState)..orderBy([
            (t) => OrderingTerm(expression: t.pinned, mode: OrderingMode.desc),
            (t) =>
                OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
          ]))
          .watch();

  // Zero out the unread count for every conversation.
  Future<void> markAllRead() async {
    await (update(db.syncState)).write(
      SyncStateCompanion(
        unreadCount: Value(0),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  // Get sync states for a given conversation type.
  Future<List<SyncStateData>> getSyncStatesByType(int conversationType) =>
      (select(
        db.syncState,
      )..where((t) => t.conversationType.equals(conversationType))).get();

  // Set the online-status projection for a conversation without touching
  // `updatedAt`, so presence changes never reorder the chat list.
  //
  // Writes only when the value actually changes. Drift fires a table-update
  // notification for every executed write, so an unconditional no-op write
  // would re-run every `sync_state` stream query (rebuilding the chat list)
  // even when nothing changed — which is exactly what a presence poll does
  // most of the time.
  Future<void> setStatus(String conversationId, int status) async {
    final current = await (select(
      db.syncState,
    )..where((t) => t.conversationId.equals(conversationId))).getSingleOrNull();

    if (current == null || current.status == status) return;

    await (update(
      db.syncState,
    )..where((t) => t.conversationId.equals(conversationId))).write(
      SyncStateCompanion(status: Value(status)),
    );
  }

  // Insert a new sync state.
  Future<int> insertSyncState(Insertable<SyncStateData> syncState) =>
      into(db.syncState).insert(syncState);

  // Upsert (insert or update) a sync state.
  Future<void> upsertSyncState(SyncStateData syncState) =>
      into(db.syncState).insertOnConflictUpdate(syncState);

  /// Materializes durable conversation data into the screen projection.
  /// Existing screen-owned fields are intentionally preserved.
  Future<void> upsertConversationProjection({
    required String conversationId,
    required int conversationType,
    required String displayName,
    String? avatar,
    int status = 0,
    String? lastMessageId,
    String? lastMessage,
    required int updatedAt,
    String colour = '0xFF2EB82E',
    int archived = 0,
  }) async {
    final existing = await getSyncStateById(conversationId);
    final values = SyncStateCompanion(
      displayName: Value(displayName),
      avatar: Value(avatar),
      status: Value(status),
      lastMessageId: Value(lastMessageId),
      lastMessage: Value(lastMessage),
      updatedAt: Value(updatedAt),
      archived: Value(archived),
    );

    if (existing == null) {
      await into(db.syncState).insert(
        SyncStateCompanion.insert(
          conversationId: conversationId,
          conversationType: conversationType,
          displayName: displayName,
          avatar: Value(avatar),
          status: Value(status),
          lastMessageId: Value(lastMessageId),
          lastMessage: Value(lastMessage),
          updatedAt: updatedAt,
          colour: colour,
          archived: Value(archived),
        ),
      );
      return;
    }

    await (update(
      db.syncState,
    )..where((t) => t.conversationId.equals(conversationId))).write(values);
  }

  /// Points a conversation's projection at [messageId], creating the row if it
  /// doesn't exist yet.
  ///
  /// The chat message list is driven by this row's `lastMessageId`, so a
  /// conversation that was created at runtime (e.g. straight from the contacts
  /// screen) never materialized a projection at startup and would otherwise
  /// never surface a newly sent or received message. Rendering fields are read
  /// from the contact/group so the chat list entry stays populated.
  Future<void> recordLatestMessage({
    required String conversationId,
    required String messageId,
    String? message,
    required int updatedAt,
  }) async {
    final existing = await getSyncStateById(conversationId);
    if (existing != null) {
      await (update(
        db.syncState,
      )..where((t) => t.conversationId.equals(conversationId))).write(
        SyncStateCompanion(
          lastMessageId: Value(messageId),
          lastMessage: Value(message),
          updatedAt: Value(updatedAt),
        ),
      );
      return;
    }

    final conversation = await db.conversationsDao.getConversationById(
      conversationId,
    );
    final conversationType = conversation?.conversationType ?? 0;

    var displayName = conversationId;
    String? avatar;
    var status = 0;

    if (conversationType == 0) {
      final contact = await db.contactsDao.getContactByConversationId(
        conversationId,
      );
      if (contact != null) {
        displayName = (contact.nickname?.trim().isNotEmpty ?? false)
            ? contact.nickname!.trim()
            : contact.contactId;
        avatar = contact.avatar == null
            ? null
            : 'data:image/png;base64,${base64Encode(contact.avatar!)}';
        status = contact.isOnline;
      }
    } else {
      final group = await db.groupsDao.getGroupById(conversationId);
      if (group != null) {
        displayName = group.groupName;
        avatar = group.avatar == null
            ? null
            : 'data:image/png;base64,${base64Encode(group.avatar!)}';
      }
    }

    await into(db.syncState).insert(
      SyncStateCompanion.insert(
        conversationId: conversationId,
        conversationType: conversationType,
        displayName: displayName,
        avatar: Value(avatar),
        status: Value(status),
        lastMessageId: Value(messageId),
        lastMessage: Value(message),
        updatedAt: updatedAt,
        colour: '0xFF2EB82E',
      ),
    );
  }

  // Update an existing sync state row.
  Future<bool> updateSyncState(SyncStateData syncState) =>
      update(db.syncState).replace(syncState);

  // Delete a sync state by conversation ID.
  Future<int> deleteSyncState(String conversationId) => (delete(
    db.syncState,
  )..where((t) => t.conversationId.equals(conversationId))).go();

  // Update the last read message details and unread count.
  Future<void> updateLastRead(
    String conversationId, {
    required String messageId,
    required String message,
    required int unreadCount,
  }) async {
    await (update(
      db.syncState,
    )..where((t) => t.conversationId.equals(conversationId))).write(
      SyncStateCompanion(
        lastReadMessageId: Value(messageId),
        lastReadMessage: Value(message),
        unreadCount: Value(unreadCount),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Draft
  // ─────────────────────────────────────────────────────────────

  // Get the draft for a single conversation.
  Future<String?> getDraft(String conversationId) async {
    final row = await (select(
      db.syncState,
    )..where((t) => t.conversationId.equals(conversationId))).getSingleOrNull();
    return row?.draft;
  }

  // Get every conversation that currently has a non-empty draft.
  Future<List<SyncStateData>> getConversationsWithDrafts() => (select(
    db.syncState,
  )..where((t) => t.draft.isNotNull() & t.draft.equals('').not())).get();

  // Save (or overwrite) the draft text for a conversation.
  // Passing null or an empty string clears the draft.
  Future<void> updateDraft(String conversationId, String? draft) async {
    await (update(
      db.syncState,
    )..where((t) => t.conversationId.equals(conversationId))).write(
      SyncStateCompanion(
        draft: Value((draft == null || draft.isEmpty) ? null : draft),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  // Clear the draft on a conversation.
  Future<void> clearDraft(String conversationId) =>
      updateDraft(conversationId, null);
  // Update the most recent message details.
  Future<void> updateLastMessage(
    String conversationId, {
    required String messageId,
    required String message,
  }) async {
    await (update(
      db.syncState,
    )..where((t) => t.conversationId.equals(conversationId))).write(
      SyncStateCompanion(
        lastMessageId: Value(messageId),
        lastMessage: Value(message),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  // Toggle or set the pinned flag and optional position.
  Future<void> setPinned(
    String conversationId, {
    required int pinned,
    int? pinnedPosition,
  }) async {
    await (update(
      db.syncState,
    )..where((t) => t.conversationId.equals(conversationId))).write(
      SyncStateCompanion(
        pinned: Value(pinned),
        pinnedPosition: Value(pinnedPosition),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  // Update the colour.
  Future<void> updateColour(String conversationId, String colour) async {
    await (update(
      db.syncState,
    )..where((t) => t.conversationId.equals(conversationId))).write(
      SyncStateCompanion(
        colour: Value(colour),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  // Set the muted flag.
  Future<void> setMuted(String conversationId, int muted) async {
    await (update(
      db.syncState,
    )..where((t) => t.conversationId.equals(conversationId))).write(
      SyncStateCompanion(
        muted: Value(muted),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  // Set the archived flag. Does not touch `updatedAt`, so archiving never
  // reorders the chat list.
  Future<void> setArchived(String conversationId, int archived) async {
    await (update(
      db.syncState,
    )..where((t) => t.conversationId.equals(conversationId))).write(
      SyncStateCompanion(archived: Value(archived)),
    );
  }

  // Increment or set the mentions count.
  Future<void> setMentions(String conversationId, int mentions) async {
    await (update(
      db.syncState,
    )..where((t) => t.conversationId.equals(conversationId))).write(
      SyncStateCompanion(
        mentions: Value(mentions),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
