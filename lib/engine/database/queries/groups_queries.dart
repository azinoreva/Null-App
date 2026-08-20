import 'package:drift/drift.dart';

import '../tables/groups.dart';

part 'groups_queries.g.dart';

/// Data Access Object for the `Groups` table.
@DriftAccessor(tables: [Groups])
class GroupsDao extends DatabaseAccessor<AppDatabase> with _$GroupsDaoMixin {
  GroupsDao(super.db);

  // Get a single group by its ID.
  Future<Groups?> getGroupById(String id) =>
      (select(db.groups)..where((t) => t.groupId.equals(id))).getSingleOrNull();

  // Get all groups.
  Future<List<Groups>> getAllGroups() => select(db.groups).get();

  // Get groups by type (0 = private, 1 = public).
  Future<List<Groups>> getGroupsByType(int type) =>
      (select(db.groups)..where((t) => t.groupType.equals(type))).get();

  // Get groups where the current user is the owner.
  Future<List<Groups>> getOwnedGroups() =>
      (select(db.groups)..where((t) => t.isOwner.equals(1))).get();

  // Insert a new group.
  Future<int> insertGroup(Insertable<Groups> group) =>
      into(db.groups).insert(group);

  // Upsert (insert or update) a group.
  Future<void> upsertGroup(Groups group) =>
      into(db.groups).insertOnConflictUpdate(group);

  // Update an existing group row.
  Future<bool> updateGroup(Groups group) => update(db.groups).replace(group);

  // Delete a group by ID.
  Future<int> deleteGroup(String id) =>
      (delete(db.groups)..where((t) => t.groupId.equals(id))).go();

  // Update only the group name.
  Future<void> updateGroupName(String groupId, String newName) async {
    await (update(db.groups)..where((t) => t.groupId.equals(groupId))).write(
      GroupsCompanion(groupName: Value(newName)),
    );
  }

  // Update the group avatar.
  Future<void> updateGroupAvatar(String groupId, String? avatarUrl) async {
    await (update(db.groups)..where((t) => t.groupId.equals(groupId))).write(
      GroupsCompanion(avatar: Value(avatarUrl)),
    );
  }

  // Update the group description.
  Future<void> updateGroupDescription(
    String groupId,
    String? description,
  ) async {
    await (update(db.groups)..where((t) => t.groupId.equals(groupId))).write(
      GroupsCompanion(groupDesc: Value(description)),
    );
  }

  // Update the private key (owner only).
  Future<void> updatePrivateKey(String groupId, String? privateKey) async {
    await (update(db.groups)..where((t) => t.groupId.equals(groupId))).write(
      GroupsCompanion(privateKey: Value(privateKey)),
    );
  }

  // Set or clear the owner flag.
  Future<void> setOwnerFlag(String groupId, int isOwner) async {
    await (update(db.groups)..where((t) => t.groupId.equals(groupId))).write(
      GroupsCompanion(isOwner: Value(isOwner)),
    );
  }
}
