import 'package:drift/drift.dart';

/// Drift table definition for the `Conversations` table.
///
/// Stores chat list entries, notification preferences, and UI state.
class Conversations extends Table {
  TextColumn get conversationId => text()();
  IntColumn get conversationType =>
      integer().check(conversationType.isIn([0, 1]))();
  TextColumn get lastMessageId => text().nullable()();
  IntColumn get lastMessageTime => integer().nullable()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  IntColumn get muted =>
      integer().withDefault(const Constant(0)).check(muted.isIn([0, 1]))();
  IntColumn get pinned =>
      integer().withDefault(const Constant(0)).check(pinned.isIn([0, 1]))();
  IntColumn get archived =>
      integer().withDefault(const Constant(0)).check(archived.isIn([0, 1]))();
  TextColumn get draft => text().nullable()();

  TextColumn get serverId => text()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();
  
  TextColumn get sound => text().nullable()();
  IntColumn get badge =>
      integer().withDefault(const Constant(0)).check(badge.isIn([0, 1, 2]))();
  IntColumn get vibration =>
      integer().withDefault(const Constant(0)).check(vibration.isIn([0, 1]))();

  @override
  Set<Column> get primaryKey => {conversationId};
}
