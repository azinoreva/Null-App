import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/database/app_database.dart';
import '../engine/database/queries/sync_state_queries.dart';

/// The app's single [AppDatabase] instance.
///
/// This provider has no default value; it is overridden in `main()` with the
/// database created by `DatabaseInitializer.initialize()`.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden in ProviderScope '
    'with the initialized AppDatabase instance.',
  );
});

/// Data access object for the `sync_state` table.
///
/// Reads, writes, and — most importantly — streamed watchers for the table.
final syncStateDaoProvider = Provider<SyncStateDao>((ref) {
  return ref.watch(appDatabaseProvider).syncStateDao;
});

/// Reactive mirror of the `sync_state` table.
///
/// Riverpod is the single source of sync state for the chat UI. The notifier
/// subscribes to [SyncStateDao.watchAllSyncStates], so any change made to the
/// `sync_state` table (here or anywhere else in the app) is picked up and the
/// UI rebuilds automatically.
final syncStatesProvider =
    AsyncNotifierProvider<SyncStatesNotifier, List<SyncStateData>>(
  SyncStatesNotifier.new,
);

class SyncStatesNotifier extends AsyncNotifier<List<SyncStateData>> {
  StreamSubscription<List<SyncStateData>>? _subscription;

  @override
  Future<List<SyncStateData>> build() async {
    final dao = ref.watch(syncStateDaoProvider);
    final ready = Completer<void>();

    _subscription = dao.watchAllSyncStates().listen(
      (rows) {
        state = AsyncData(List.unmodifiable(rows));
        if (!ready.isCompleted) ready.complete();
      },
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncError(error, stackTrace);
        if (!ready.isCompleted) ready.complete();
      },
    );

    ref.onDispose(() => _subscription?.cancel());

    await ready.future;
    return state.value ?? const [];
  }

  SyncStateDao get _dao => ref.read(syncStateDaoProvider);

  /// Creates or overwrites a conversation's sync state row.
  Future<void> upsert(SyncStateData row) => _dao.upsertSyncState(row);

  /// Marks every conversation as read.
  Future<void> markAllRead() => _dao.markAllRead();

  /// Marks a single conversation as read up to [messageId].
  Future<void> markRead(
    String conversationId, {
    required String messageId,
    required String message,
  }) =>
      _dao.updateLastRead(
        conversationId,
        messageId: messageId,
        message: message,
        unreadCount: 0,
      );

  /// Updates the last message preview shown in the chat list.
  Future<void> updateLastMessage(
    String conversationId, {
    required String messageId,
    required String message,
  }) =>
      _dao.updateLastMessage(
        conversationId,
        messageId: messageId,
        message: message,
      );

  /// Pins or unpins a conversation.
  Future<void> setPinned(
    String conversationId, {
    required bool pinned,
    int? position,
  }) =>
      _dao.setPinned(
        conversationId,
        pinned: pinned ? 1 : 0,
        pinnedPosition: position,
      );

  /// Mutes or unmutes a conversation.
  Future<void> setMuted(String conversationId, {required bool muted}) =>
      _dao.setMuted(conversationId, muted ? 1 : 0);

  /// Updates the ring colour shown around the avatar.
  Future<void> updateColour(String conversationId, String colour) =>
      _dao.updateColour(conversationId, colour);

  /// Saves or clears the draft for a conversation.
  Future<void> updateDraft(String conversationId, String? draft) =>
      _dao.updateDraft(conversationId, draft);

  /// Adds mention count for a conversation.
  Future<void> addMentions(String conversationId, int mentions) =>
      _dao.setMentions(conversationId, mentions);

  /// Removes a conversation from the sync state.
  Future<void> remove(String conversationId) =>
      _dao.deleteSyncState(conversationId);
}