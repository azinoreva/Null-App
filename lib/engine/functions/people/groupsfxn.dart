// module name: group_management.dart

import 'dart:typed_data';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../database/queries/groups_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../crypto/groups/group_key.dart';
import '../../image_handling/shrink_image.dart';
import '../../image_handling/string_to_blob.dart';
import '../../image_handling/dicebear.dart'; // wherever DicebearService lives

const _uuid = Uuid();

/// 1. Creates a new group.
///
/// - Generates groupId (uuid).
/// - Looks up the current identity to use as ownerId.
/// - groupType: 0 = private, 1 = public (matches the table's check constraint).
/// - Private groups get a freshly generated symmetric key.
/// - Public groups are rejected, since only the server owner can create them.
/// - Avatar: pass [avatarFileUrl] to compress a real image, or omit it to
///   generate a Dicebear avatar seeded with the new groupId.
Future<Group> createGroup(
  GroupsDao groupsDao,
  IdentityDao identityDao, {
  required String groupName,
  required int groupType, // 0 = private, 1 = public
  String? groupDesc,
  String? avatarFileUrl,
}) async {
  if (groupType == 1) {
    // Public groups can only be created by the server owner — rejected here.
    throw StateError(
      "you can't create a public group as you are not the server owner",
    );

    // --- If/when server-owner support is added, this is the path that
    // allows public group creation WITHOUT generating a privateKey.
    // Uncomment and remove the throw above to enable it:
    //
    // final groupId = _uuid.v4();
    // final identity = await identityDao.getCurrentIdentity();
    // final now = DateTime.now().millisecondsSinceEpoch;
    // final avatarBytes = await _resolveAvatar(groupId, avatarFileUrl);
    // final companion = GroupsCompanion.insert(
    //   groupId: groupId,
    //   ownerId: Value(identity.identityId),
    //   groupName: groupName,
    //   groupType: groupType,
    //   avatar: Value(avatarBytes),
    //   privateKey: const Value(null), // no key for public groups
    //   groupDesc: Value(groupDesc),
    //   createdAt: now,
    //   updatedAt: now,
    //   isOwner: const Value(1),
    // );
    // await groupsDao.insertGroup(companion);
    // return (await groupsDao.getGroupById(groupId))!;
  }

  final groupId = _uuid.v4();

  final identity = await identityDao.getCurrentIdentity();
  final ownerId = identity.identityId;

  final privateKey = await GroupKey.generate();

  final avatarBytes = await _resolveAvatar(groupId, avatarFileUrl);

  final now = DateTime.now().millisecondsSinceEpoch;

  final companion = GroupsCompanion.insert(
    groupId: groupId,
    ownerId: Value(ownerId),
    groupName: groupName,
    groupType: groupType,
    avatar: Value(avatarBytes),
    privateKey: Value(privateKey),
    groupDesc: Value(groupDesc),
    createdAt: now,
    updatedAt: now,
    isOwner: const Value(1),
  );

  await groupsDao.insertGroup(companion);
  return (await groupsDao.getGroupById(groupId))!;
}

/// Resolves the avatar blob: shrinks a real image if [avatarFileUrl] is
/// given, otherwise generates a Dicebear avatar seeded with [groupId].
Future<Uint8List> _resolveAvatar(String groupId, String? avatarFileUrl) async {
  if (avatarFileUrl != null) {
    final compressed = await ContactImageCompressor.processImage(
      imageInput: avatarFileUrl,
    );
    if (compressed == null) {
      throw StateError('Failed to compress group avatar image.');
    }
    return compressed.blobBytes;
  } else {
    final dicebear = await DicebearService().getAvatarData(groupId);
    return dicebear.bytes;
  }
}

/// 2. Saves (persists) a group that was received from elsewhere — e.g. a
/// group another user created and invited you to. groupId and ownerId are
/// supplied by the caller, not generated. isOwner is always 0 here.
/// Avatar arrives as Base64 and is converted straight to a blob.
Future<void> saveGroup(
  GroupsDao groupsDao, {
  required String groupId,
  required String ownerId,
  required String groupName,
  required int groupType, // 0 = private, 1 = public
  String? privateKey,
  String? groupDesc,
  String? avatarBase64,
}) async {
  Uint8List? avatarBlob;
  if (avatarBase64 != null) {
    avatarBlob = base64ToBlob(avatarBase64);
    if (avatarBlob == null) {
      throw StateError('Invalid avatar Base64 data.');
    }
  }

  final now = DateTime.now().millisecondsSinceEpoch;

  final companion = GroupsCompanion.insert(
    groupId: groupId,
    ownerId: Value(ownerId),
    groupName: groupName,
    groupType: groupType,
    avatar: Value(avatarBlob),
    privateKey: Value(privateKey),
    groupDesc: Value(groupDesc),
    createdAt: now,
    updatedAt: now,
    isOwner: const Value(0),
  );

  await groupsDao.insertGroup(companion);
}

/// 3. Updates group fields. groupName / privateKey / newPrivateKey /
/// swapTime can always be changed; ownerId and groupDesc can only be
/// changed if the local row's isOwner flag is 1.
Future<void> updateGroupFields(
  GroupsDao groupsDao, {
  required String groupId,
  String? groupName,
  String? ownerId,
  String? privateKey,
  String? newPrivateKey,
  int? swapTime,
  String? groupDesc,
}) async {
  final group = await groupsDao.getGroupById(groupId);
  if (group == null) {
    throw StateError('Group $groupId does not exist.');
  }

  final isOwner = group.isOwner == 1;

  if (ownerId != null && !isOwner) {
    throw StateError('Only the group owner can change the owner ID.');
  }
  if (groupDesc != null && !isOwner) {
    throw StateError('Only the group owner can change the group description.');
  }

  final companion = GroupsCompanion(
    groupName: groupName != null ? Value(groupName) : const Value.absent(),
    ownerId: ownerId != null ? Value(ownerId) : const Value.absent(),
    privateKey:
        privateKey != null ? Value(privateKey) : const Value.absent(),
    newPrivateKey:
        newPrivateKey != null ? Value(newPrivateKey) : const Value.absent(),
    swapTime: swapTime != null ? Value(swapTime) : const Value.absent(),
    groupDesc: groupDesc != null ? Value(groupDesc) : const Value.absent(),
    updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
  );

  await (groupsDao.update(groupsDao.db.groups)
        ..where((t) => t.groupId.equals(groupId)))
      .write(companion);
}