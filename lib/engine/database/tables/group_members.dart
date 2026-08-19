import 'package:drift/drift.dart';

import 'groups.dart';
import 'identity.dart';

/// Drift table definition for the `GroupMembers` table.
///
/// Lists the members of a group. Each row links a group and an identity,
/// with optional group‑specific profile fields.
class GroupMembers extends Table {
  TextColumn get groupId =>
      text().references(Groups, #groupId, onDelete: KeyAction.cascade)();
  TextColumn get identityId =>
      text().references(Identity, #identityId, onDelete: KeyAction.cascade)();

  TextColumn get publicKey => text().nullable()();
  TextColumn get bio => text().nullable()();
  TextColumn get avatar => text().nullable()();

  // Column name `_name` (reserved, so use `name` getter).
  TextColumn get name => text().named('_name').nullable()();

  IntColumn get joinedAt => integer().nullable()(); // Unix epoch milliseconds

  @override
  Set<Column> get primaryKey => {groupId, identityId};
}
