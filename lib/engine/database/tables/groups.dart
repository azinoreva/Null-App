import 'package:drift/drift.dart';

/// Drift table definition for the `Groups` table.
///
/// Stores group chat metadata, including group ID (which equals the
/// conversation ID), owner, type, avatar, description, and encryption
/// key information.
class Groups extends Table {
  TextColumn get groupId => text()();
  TextColumn get ownerId => text().nullable()();
  TextColumn get groupName => text()();
  IntColumn get groupType =>
      integer().check(groupType.isIn([0, 1]))(); // 0 = private, 1 = public
  TextColumn get avatar => text().nullable()();
  TextColumn get privateKey => text().nullable()();
  TextColumn get groupDesc => text().nullable()();

  // Timestamps stored as Unix epoch milliseconds (consistent with other tables).
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  // Indicates whether the current user is the owner of this group.
  IntColumn get isOwner =>
      integer().withDefault(const Constant(0)).check(isOwner.isIn([0, 1]))();

  @override
  Set<Column> get primaryKey => {groupId};
}
