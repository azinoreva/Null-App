import 'package:drift/drift.dart';

import '../tables/group_members.dart';

part 'group_members_queries.g.dart';

/// Data Access Object for the `GroupMembers` table.
@DriftAccessor(tables: [GroupMembers])
class GroupMembersDao extends DatabaseAccessor<AppDatabase>
    with _$GroupMembersDaoMixin {
  GroupMembersDao(AppDatabase db) : super(db);

  // Add a new member to a group.
  Future<int> addMember(Insertable<GroupMembers> member) =>
      into(db.groupMembers).insert(member);

  // Remove a member from a group.
  Future<int> removeMember(String groupId, String identityId) =>
      (delete(db.groupMembers)..where(
            (t) => t.groupId.equals(groupId) & t.identityId.equals(identityId),
          ))
          .go();

  // Check if a user is a member of a group.
  Future<bool> isMember(String groupId, String identityId) async {
    final query = selectOnly(db.groupMembers)
      ..addColumns([db.groupMembers.identityId])
      ..where(
        db.groupMembers.groupId.equals(groupId) &
            db.groupMembers.identityId.equals(identityId),
      );
    final result = await query.get();
    return result.isNotEmpty;
  }

  // Get all members of a group.
  Future<List<GroupMembers>> getMembersOfGroup(String groupId) =>
      (select(db.groupMembers)..where((t) => t.groupId.equals(groupId))).get();

  // Get all groups a user belongs to.
  Future<List<GroupMembers>> getGroupsOfIdentity(String identityId) => (select(
    db.groupMembers,
  )..where((t) => t.identityId.equals(identityId))).get();

  // Get the public key of a member in a group (if available).
  Future<String?> getMemberPublicKey(String groupId, String identityId) async {
    final query = selectOnly(db.groupMembers)
      ..addColumns([db.groupMembers.publicKey])
      ..where(
        db.groupMembers.groupId.equals(groupId) &
            db.groupMembers.identityId.equals(identityId),
      );
    final result = await query.getSingleOrNull();
    return result?.read(db.groupMembers.publicKey);
  }

  // Update a member's bio in a group.
  Future<void> updateMemberBio(
    String groupId,
    String identityId,
    String? bio,
  ) async {
    await (update(db.groupMembers)..where(
          (t) => t.groupId.equals(groupId) & t.identityId.equals(identityId),
        ))
        .write(GroupMembersCompanion(bio: Value(bio)));
  }

  // Update a member's avatar in a group.
  Future<void> updateMemberAvatar(
    String groupId,
    String identityId,
    String? avatar,
  ) async {
    await (update(db.groupMembers)..where(
          (t) => t.groupId.equals(groupId) & t.identityId.equals(identityId),
        ))
        .write(GroupMembersCompanion(avatar: Value(avatar)));
  }

  // Update a member's display name in a group.
  Future<void> updateMemberName(
    String groupId,
    String identityId,
    String? name,
  ) async {
    await (update(db.groupMembers)..where(
          (t) => t.groupId.equals(groupId) & t.identityId.equals(identityId),
        ))
        .write(GroupMembersCompanion(name: Value(name)));
  }

  // Update a member's public key (used for key sharing).
  Future<void> updateMemberPublicKey(
    String groupId,
    String identityId,
    String? publicKey,
  ) async {
    await (update(db.groupMembers)..where(
          (t) => t.groupId.equals(groupId) & t.identityId.equals(identityId),
        ))
        .write(GroupMembersCompanion(publicKey: Value(publicKey)));
  }
}
