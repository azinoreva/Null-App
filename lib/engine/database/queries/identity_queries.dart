//module name: identity_queries

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/identity.dart';
import '../app_database.dart';

part 'identity_queries.g.dart';

@DriftAccessor(tables: [Identity])
class IdentityDao extends DatabaseAccessor<AppDatabase>
    with _$IdentityDaoMixin {
  IdentityDao(super.db);

  /// Returns the current (single) identity row.
  Future<IdentityData> getCurrentIdentity() => select(db.identity).getSingle();

  /// Returns the single identity row, or `null` if the table is empty.
  Future<IdentityData?> getCurrentIdentityOrNull() =>
      select(db.identity).getSingleOrNull();

  /// Inserts a new identity (only if table is empty).
  Future<int> insertIdentity(Insertable<IdentityData> identity) =>
      into(db.identity).insert(identity);

  /// Replaces the current identity (upsert).
  Future<void> upsertIdentity(IdentityData identity) =>
      into(db.identity).insertOnConflictUpdate(identity);

  /// Updates an existing identity row based on its primary key.
  Future<bool> updateIdentity(IdentityData identity) =>
      update(db.identity).replace(identity);

  /// Deletes the identity row with the given [identityId].
  Future<int> deleteIdentity(String identityId) =>
      (delete(db.identity)..where((t) => t.identityId.equals(identityId))).go();

  // -------------------------------------------------------------------------
  // Convenience partial updates for each column
  // -------------------------------------------------------------------------

  /// Updates only the `auto_sync` flag.
  Future<void> setAutoSync(int value) async {
    final current = await getCurrentIdentityOrNull();
    if (current != null) {
      await (update(db.identity)
            ..where((t) => t.identityId.equals(current.identityId)))
          .write(IdentityCompanion(autoSync: Value(value)));
    }
  }

  /// Updates only the `allow_connect_req` flag.
  Future<void> setAllowConnectReq(int value) async {
    final current = await getCurrentIdentityOrNull();
    if (current != null) {
      await (update(db.identity)
            ..where((t) => t.identityId.equals(current.identityId)))
          .write(IdentityCompanion(allowConnectReq: Value(value)));
    }
  }

  /// Updates the `salt_version` and `shamir_number` together.
  Future<void> setSecuritySettings({
    required int saltVersion,
    required int shamirNumber,
  }) async {
    final current = await getCurrentIdentityOrNull();
    if (current != null) {
      await (update(db.identity)
            ..where((t) => t.identityId.equals(current.identityId)))
          .write(IdentityCompanion(
            saltVersion: Value(saltVersion),
            shamirNumber: Value(shamirNumber),
          ));
    }
  }

  /// Updates the display name.
  Future<void> setDisplayName(String displayName) async {
    final current = await getCurrentIdentityOrNull();
    if (current != null) {
      await (update(db.identity)
            ..where((t) => t.identityId.equals(current.identityId)))
          .write(IdentityCompanion(displayName: Value(displayName)));
    }
  }

  /// Updates the avatar (URL or path).
  Future<void> setAvatar(String? avatar) async {
    final current = await getCurrentIdentityOrNull();
    if (current != null) {
      await (update(db.identity)
            ..where((t) => t.identityId.equals(current.identityId)))
          .write(IdentityCompanion(avatar: Value(avatar)));
    }
  }

  /// Updates the bio.
  Future<void> setBio(String? bio) async {
    final current = await getCurrentIdentityOrNull();
    if (current != null) {
      await (update(db.identity)
            ..where((t) => t.identityId.equals(current.identityId)))
          .write(IdentityCompanion(bio: Value(bio)));
    }
  }

  /// Updates the phone number.
  Future<void> setPhoneNumber(String? phoneNumber) async {
    final current = await getCurrentIdentityOrNull();
    if (current != null) {
      await (update(db.identity)
            ..where((t) => t.identityId.equals(current.identityId)))
          .write(IdentityCompanion(phoneNumber: Value(phoneNumber)));
    }
  }

  /// Updates the public key.
  Future<void> setPublicKey(String? publicKey) async {
    final current = await getCurrentIdentityOrNull();
    if (current != null) {
      await (update(db.identity)
            ..where((t) => t.identityId.equals(current.identityId)))
          .write(IdentityCompanion(publicKey: Value(publicKey)));
    }
  }

  /// Updates the passport version.
  Future<void> setPassportVersion(int passportVersion) async {
    final current = await getCurrentIdentityOrNull();
    if (current != null) {
      await (update(db.identity)
            ..where((t) => t.identityId.equals(current.identityId)))
          .write(IdentityCompanion(passportVersion: Value(passportVersion)));
    }
  }

  /// Updates the recovery type.
  Future<void> setRecoveryType(String? recoveryType) async {
    final current = await getCurrentIdentityOrNull();
    if (current != null) {
      await (update(db.identity)
            ..where((t) => t.identityId.equals(current.identityId)))
          .write(IdentityCompanion(recoveryType: Value(recoveryType)));
    }
  }

  /// Updates the invitation count.
  Future<void> setInvitationCount(int invitationCount) async {
    final current = await getCurrentIdentityOrNull();
    if (current != null) {
      await (update(db.identity)
            ..where((t) => t.identityId.equals(current.identityId)))
          .write(IdentityCompanion(invitationCount: Value(invitationCount)));
    }
  }

  /// Generic method to update arbitrary fields using a companion.
  /// Use this when you need to update multiple fields at once.
  Future<void> updateIdentityFields(IdentityCompanion companion) async {
    final current = await getCurrentIdentityOrNull();
    if (current != null) {
      await (update(db.identity)
            ..where((t) => t.identityId.equals(current.identityId)))
          .write(companion);
    }
  }

  /// Fetches an identity by phone number.
  Future<IdentityData?> getIdentityByPhoneNumber(String phone) => (select(
    db.identity,
  )..where((t) => t.phoneNumber.equals(phone))).getSingleOrNull();
}