import 'package:drift/drift.dart';

/// Drift table definition for the `sync_state` table.
///
/// Stores lightweight, denormalized conversation state for UI and sync.
class SyncState extends Table {
  TextColumn get conversationId => text()();

  IntColumn get conversationType =>
      integer().check(conversationType.isIn([0, 1, 2]))();

  TextColumn get displayName => text()();
  TextColumn get avatar => text().nullable()();

  IntColumn get unreadCount => integer().withDefault(const Constant(0))();

  TextColumn get lastReadMessageId => text().nullable()();
  TextColumn get lastReadMessage => text().nullable()();

  TextColumn get lastMessageId => text().nullable()();
  TextColumn get lastMessage => text().nullable()();

  IntColumn get pinned =>
      integer().withDefault(const Constant(0)).check(pinned.isIn([0, 1]))();
  IntColumn get pinnedPosition => integer().nullable()();

  IntColumn get updatedAt => integer()(); // Unix epoch milliseconds
  TextColumn get colour => text()(); // e.g., "0xRRGGBB" or "#RRGGBB"
  IntColumn get muted =>
      integer().withDefault(const Constant(0)).check(muted.isIn([0, 1]))();
  IntColumn get mentions => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {conversationId};
}