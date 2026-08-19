import 'package:drift/drift.dart';

import 'conversations.dart'; // for foreign key reference

/// Drift table definition for the `Contacts` table.
///
/// Stores the user's contacts and their relationship/notification settings.
/// Each contact can be linked to a one-on-one conversation.
class Contacts extends Table {
  TextColumn get contactId => text()();
  TextColumn get nickname => text().nullable()();
  TextColumn get avatar => text().nullable()();
  TextColumn get bio => text().nullable()();

  IntColumn get muted =>
      integer().withDefault(const Constant(0)).check(muted.isIn([0, 1]))();
  IntColumn get pinned =>
      integer().withDefault(const Constant(0)).check(pinned.isIn([0, 1]))();
  IntColumn get isOnline =>
      integer().withDefault(const Constant(0)).check(isOnline.isIn([0, 1]))();

  // Unix epoch milliseconds (nullable).
  IntColumn get lastSeen => integer().nullable()();

  IntColumn get connectionStatus => integer()();

  TextColumn get serverId => text()();

  // Unix epoch milliseconds.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  IntColumn get ignorePing =>
      integer().withDefault(const Constant(0)).check(ignorePing.isIn([0, 1]))();

  // Foreign key linking to a conversation (one-on-one chat).
  TextColumn get conversationId => text().nullable().references(
    Conversations,
    #conversationId,
    onDelete: KeyAction.setNull,
  )();

  @override
  Set<Column> get primaryKey => {contactId};
}
