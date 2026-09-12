//module name: group_membersfxn

import 'package:drift/drift.dart';
import 'dart:typed_data';
import '../../database/app_database.dart';
import '../../database/queries/group_members_queries.dart';

/// Adds a new member to a group.
Future<void> createGroupMember(
  GroupMembersDao dao, {
  required String groupId,
  required String identityId,
  String? publicKey,
  String? bio,
  Uint8List? avatar,
  String? name,
  int? joinedAt,
}) async {
  final companion = GroupMembersCompanion.insert(
    groupId: groupId,
    identityId: identityId,
    publicKey: Value(publicKey),
    bio: Value(bio),
    avatar: Value(avatar),
    name: Value(name),
    joinedAt: Value(joinedAt ?? DateTime.now().millisecondsSinceEpoch),
  );

  await dao.addMember(companion);
}

/// Edits any field of a group member except groupId/identityId (the
/// composite primary key). Only fields you pass are changed.
Future<void> editGroupMember(
  GroupMembersDao dao, {
  required String groupId,
  required String identityId,
  String? publicKey,
  String? bio,
  Uint8List? avatar,
  String? name,
  int? joinedAt,
}) async {
  final companion = GroupMembersCompanion(
    publicKey: publicKey != null ? Value(publicKey) : const Value.absent(),
    bio: bio != null ? Value(bio) : const Value.absent(),
    avatar: avatar != null ? Value(avatar) : const Value.absent(),
    name: name != null ? Value(name) : const Value.absent(),
    joinedAt: joinedAt != null ? Value(joinedAt) : const Value.absent(),
  );

  await (dao.update(dao.db.groupMembers)
        ..where(
          (t) => t.groupId.equals(groupId) & t.identityId.equals(identityId),
        ))
      .write(companion);
}

/// Removes a member from a group.
Future<int> deleteGroupMember(
  GroupMembersDao dao, {
  required String groupId,
  required String identityId,
}) {
  return dao.removeMember(groupId, identityId);
}