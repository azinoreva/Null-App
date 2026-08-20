import 'package:drift/drift.dart';

/// Drift table definition for the `Groups` table.
///
/// Stores group chat metadata and the current/pending symmetric
/// encryption keys used by the group.
///
/// Key rotation:
///   privateKey    = currently active group encryption key
///   newPrivateKey = next group encryption key
///   swapTime      = Unix epoch milliseconds when newPrivateKey becomes active
///
/// The pending key is distributed before swapTime so members can
/// transition cleanly without a race at the key boundary.
class Groups extends Table {
  TextColumn get groupId => text()();

  TextColumn get ownerId => text().nullable()();

  TextColumn get groupName => text()();

  IntColumn get groupType =>
      integer().check(groupType.isIn([0, 1]))(); // 0 = private, 1 = public

  TextColumn get avatar => text().nullable()();

  /// Currently active symmetric group encryption key.
  TextColumn get privateKey => text().nullable()();

  /// Next symmetric group encryption key waiting to become active.
  TextColumn get newPrivateKey => text().nullable()();

  /// Unix epoch milliseconds at which newPrivateKey replaces privateKey.
  ///
  /// NULL means there is currently no scheduled key swap.
  IntColumn get swapTime => integer().nullable()();

  TextColumn get groupDesc => text().nullable()();

  // Timestamps stored as Unix epoch milliseconds.
  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  /// Indicates whether the current user is the owner of this group.
  IntColumn get isOwner =>
      integer()
          .withDefault(const Constant(0))
          .check(isOwner.isIn([0, 1]))();

  @override
  Set<Column> get primaryKey => {groupId};
}