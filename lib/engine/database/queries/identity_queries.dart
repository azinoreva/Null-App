//module name: identity_queries

import 'package:drift/drift.dart';
import '../tables/identity.dart';

part 'identity_queries.g.dart';

@DriftDatabase(tables: [Identity], daos: [IdentityDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2; // Increment because we may have added new columns

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // If you added columns after the initial creation, alter the table.
        // Example: add missing columns (adjust to match your actual additions).
        // If the table was created with all columns from the start, you can omit this.
        // For safety, you can also use m.addColumn for each new column.
        // Below is a generic approach – replace with your actual column names.
        await m.addColumn(db.identity, db.identity.avatar);
        await m.addColumn(db.identity, db.identity.bio);
        await m.addColumn(db.identity, db.identity.publicKey);
        await m.addColumn(db.identity, db.identity.recoveryType);
        // ... add any other new columns
      }
    },
  );
}

@DriftAccessor(tables: [Identity])
class IdentityDao extends DatabaseAccessor<AppDatabase>
    with _$IdentityDaoMixin {
  IdentityDao(super.db);

  /// Returns the current (single) identity row.
  Future<Identity> getCurrentIdentity() => select(db.identity).getSingle();

  /// Returns the single identity row, or `null` if the table is empty.
  Future<Identity?> getCurrentIdentityOrNull() =>
      select(db.identity).getSingleOrNull();

  /// Inserts a new identity (only if table is empty).
  Future<int> insertIdentity(Insertable<Identity> identity) =>
      into(db.identity).insert(identity);

  /// Replaces the current identity (upsert).
  Future<void> upsertIdentity(Identity identity) =>
      into(db.identity).insertOnConflictUpdate(identity);

  /// Updates an existing identity row based on its primary key.
  Future<bool> updateIdentity(Identity identity) =>
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
  Future<Identity?> getIdentityByPhoneNumber(String phone) => (select(
    db.identity,
  )..where((t) => t.phoneNumber.equals(phone))).getSingleOrNull();
}