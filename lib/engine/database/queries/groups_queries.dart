import 'package:drift/drift.dart';

import '../tables/groups.dart';

part 'groups_queries.g.dart';

/// Data Access Object for the `Groups` table.
///
/// Handles group metadata and group encryption-key state.
///
/// Key rotation state:
///
///   privateKey    -> currently active key
///   keyVersion    -> version of currently active key
///   newPrivateKey -> pending replacement key
///   swapTime      -> time at which pending key becomes active
@DriftAccessor(tables: [Groups])
class GroupsDao extends DatabaseAccessor<AppDatabase>
    with _$GroupsDaoMixin {
  GroupsDao(super.db);

  // ------------------------------------------------------------
  // READ
  // ------------------------------------------------------------

  /// Get a single group by ID.
  Future<Groups?> getGroupById(String id) =>
      (select(db.groups)
            ..where((t) => t.groupId.equals(id)))
          .getSingleOrNull();

  /// Get all groups.
  Future<List<Groups>> getAllGroups() =>
      select(db.groups).get();

  /// Get groups by type.
  ///
  /// 0 = private
  /// 1 = public
  Future<List<Groups>> getGroupsByType(int type) =>
      (select(db.groups)
            ..where((t) => t.groupType.equals(type)))
          .get();

  /// Get groups owned by the current user.
  Future<List<Groups>> getOwnedGroups() =>
      (select(db.groups)
            ..where((t) => t.isOwner.equals(1)))
          .get();

  /// Get groups that currently have a pending key rotation.
  Future<List<Groups>> getGroupsWithPendingKeyRotation() =>
      (select(db.groups)
            ..where((t) => t.newPrivateKey.isNotNull()))
          .get();

  /// Get groups whose pending key should now become active.
  ///
  /// The caller can use this during synchronization or startup.
  Future<List<Groups>> getGroupsReadyForKeySwap(
    int currentTime,
  ) =>
      (select(db.groups)
            ..where(
              (t) =>
                  t.newPrivateKey.isNotNull() &
                  t.swapTime.isNotNull() &
                  t.swapTime.isSmallerOrEqualValue(
                    currentTime,
                  ),
            ))
          .get();

  // ------------------------------------------------------------
  // INSERT / UPSERT
  // ------------------------------------------------------------

  /// Insert a new group.
  Future<int> insertGroup(
    Insertable<Groups> group,
  ) =>
      into(db.groups).insert(group);

  /// Insert or update a group.
  Future<void> upsertGroup(
    Groups group,
  ) =>
      into(db.groups).insertOnConflictUpdate(group);

  // ------------------------------------------------------------
  // GENERAL UPDATE / DELETE
  // ------------------------------------------------------------

  /// Replace an existing group row.
  Future<bool> updateGroup(
    Groups group,
  ) =>
      update(db.groups).replace(group);

  /// Delete a group by ID.
  Future<int> deleteGroup(
    String id,
  ) =>
      (delete(db.groups)
            ..where((t) => t.groupId.equals(id)))
          .go();

  // ------------------------------------------------------------
  // GROUP METADATA
  // ------------------------------------------------------------

  /// Update only the group name.
  Future<void> updateGroupName(
    String groupId,
    String newName,
  ) async {
    await (update(db.groups)
          ..where((t) => t.groupId.equals(groupId)))
        .write(
      GroupsCompanion(
        groupName: Value(newName),
        updatedAt: Value(
          DateTime.now().millisecondsSinceEpoch,
        ),
      ),
    );
  }

  /// Update the group avatar.
  Future<void> updateGroupAvatar(
    String groupId,
    String? avatarUrl,
  ) async {
    await (update(db.groups)
          ..where((t) => t.groupId.equals(groupId)))
        .write(
      GroupsCompanion(
        avatar: Value(avatarUrl),
        updatedAt: Value(
          DateTime.now().millisecondsSinceEpoch,
        ),
      ),
    );
  }

  /// Update the group description.
  Future<void> updateGroupDescription(
    String groupId,
    String? description,
  ) async {
    await (update(db.groups)
          ..where((t) => t.groupId.equals(groupId)))
        .write(
      GroupsCompanion(
        groupDesc: Value(description),
        updatedAt: Value(
          DateTime.now().millisecondsSinceEpoch,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CURRENT GROUP KEY
  // ------------------------------------------------------------

  /// Replace the currently active group encryption key.
  ///
  /// This does NOT schedule a rotation.
  Future<void> updatePrivateKey(
    String groupId,
    String? privateKey,
  ) async {
    await (update(db.groups)
          ..where((t) => t.groupId.equals(groupId)))
        .write(
      GroupsCompanion(
        privateKey: Value(privateKey),
        updatedAt: Value(
          DateTime.now().millisecondsSinceEpoch,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PENDING KEY ROTATION
  // ------------------------------------------------------------

  /// Schedule a new group encryption key.
  ///
  /// [newPrivateKey] is distributed to members immediately.
  ///
  /// [swapTime] is the Unix epoch time in milliseconds at which
  /// the new key becomes active.
  Future<void> scheduleKeyRotation({
    required String groupId,
    required String newPrivateKey,
    required int newKeyVersion,
    required int swapTime,
  }) async {
    await (update(db.groups)
          ..where((t) => t.groupId.equals(groupId)))
        .write(
      GroupsCompanion(
        newPrivateKey: Value(newPrivateKey),
        swapTime: Value(swapTime),
        keyVersion: Value(newKeyVersion),
        updatedAt: Value(
          DateTime.now().millisecondsSinceEpoch,
        ),
      ),
    );
  }

  /// Clear a pending key rotation without changing the current key.
  ///
  /// Useful if the scheduled rotation is cancelled before activation.
  Future<void> cancelKeyRotation(
    String groupId,
  ) async {
    await (update(db.groups)
          ..where((t) => t.groupId.equals(groupId)))
        .write(
      const GroupsCompanion(
        newPrivateKey: Value(null),
        swapTime: Value(null),
      ),
    );
  }

  // ------------------------------------------------------------
  // KEY SWAP
  // ------------------------------------------------------------

  /// Atomically promote the pending key to the active key.
  ///
  /// Before:
  ///
  ///   privateKey    = K17
  ///   newPrivateKey = K18
  ///   swapTime      = 18:00
  ///
  /// After:
  ///
  ///   privateKey    = K18
  ///   newPrivateKey = NULL
  ///   swapTime      = NULL
  ///
  /// The caller must ensure that the swap is actually due.
  Future<void> activatePendingKey(
    String groupId,
  ) async {
    final group = await getGroupById(groupId);

    if (group == null) {
      throw StateError(
        'Group $groupId does not exist.',
      );
    }

    final pendingKey = group.newPrivateKey;

    if (pendingKey == null) {
      throw StateError(
        'Group $groupId has no pending encryption key.',
      );
    }

    await db.transaction(() async {
      await (update(db.groups)
            ..where((t) => t.groupId.equals(groupId)))
          .write(
        GroupsCompanion(
          privateKey: Value(pendingKey),
          newPrivateKey: const Value(null),
          swapTime: const Value(null),
          updatedAt: Value(
            DateTime.now().millisecondsSinceEpoch,
          ),
        ),
      );
    });
  }

  // ------------------------------------------------------------
  // OWNER
  // ------------------------------------------------------------

  /// Set or clear the owner flag.
  Future<void> setOwnerFlag(
    String groupId,
    int isOwner,
  ) async {
    if (isOwner != 0 && isOwner != 1) {
      throw ArgumentError(
        'isOwner must be either 0 or 1.',
      );
    }

    await (update(db.groups)
          ..where((t) => t.groupId.equals(groupId)))
        .write(
      GroupsCompanion(
        isOwner: Value(isOwner),
        updatedAt: Value(
          DateTime.now().millisecondsSinceEpoch,
        ),
      ),
    );
  }
}