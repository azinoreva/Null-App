import 'package:drift/drift.dart';

import '../tables/identity.dart';

part 'identity_queries.g.dart';

// Minimal database setup – adjust executor and schema as needed.
@DriftDatabase(tables: [Identity], daos: [IdentityDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
  );
}

/// Data Access Object for the `Identity` table.
///
/// Designed for a single-row usage: all methods operate on the only row
/// or provide a way to insert/replace that row.
@DriftAccessor(tables: [Identity])
class IdentityDao extends DatabaseAccessor<AppDatabase>
    with _$IdentityDaoMixin {
  IdentityDao(super.db);

  /// Returns the current (single) identity row.
  ///
  /// Throws if no row exists or if more than one row is present.
  Future<Identity> getCurrentIdentity() => select(db.identity).getSingle();

  /// Returns the single identity row, or `null` if the table is empty.
  Future<Identity?> getCurrentIdentityOrNull() =>
      select(db.identity).getSingleOrNull();

  /// Inserts a new identity.
  ///
  /// Use this only if the table is empty. For updating the existing row,
  /// use [updateIdentity] or the convenience update methods.
  Future<int> insertIdentity(Insertable<Identity> identity) =>
      into(db.identity).insert(identity);

  /// Replaces the current identity with the given one (upsert semantics).
  ///
  /// If a row with the same `identityId` exists, it will be updated;
  /// otherwise a new row is inserted.
  Future<void> upsertIdentity(Identity identity) =>
      into(db.identity).insertOnConflictUpdate(identity);

  /// Updates an existing identity row based on its primary key.
  Future<bool> updateIdentity(Identity identity) =>
      update(db.identity).replace(identity);

  /// Deletes the identity row with the given [identityId].
  Future<int> deleteIdentity(String identityId) =>
      (delete(db.identity)..where((t) => t.identityId.equals(identityId))).go();

  /// Updates only the `auto_sync` flag for the current identity.
  Future<void> setAutoSync(int value) async {
    final current = await getCurrentIdentityOrNull();
    if (current != null) {
      await (update(db.identity)
            ..where((t) => t.identityId.equals(current.identityId)))
          .write(IdentityCompanion(autoSync: Value(value)));
    }
  }

  /// Updates only the `allow_connect_req` flag for the current identity.
  Future<void> setAllowConnectReq(int value) async {
    final current = await getCurrentIdentityOrNull();
    if (current != null) {
      await (update(db.identity)
            ..where((t) => t.identityId.equals(current.identityId)))
          .write(IdentityCompanion(allowConnectReq: Value(value)));
    }
  }

  /// Updates the `security_protocol` and `shamir_number` together.
  Future<void> setSecuritySettings({
    required int securityProtocol,
    required int shamirNumber,
  }) async {
    final current = await getCurrentIdentityOrNull();
    if (current != null) {
      await (update(
        db.identity,
      )..where((t) => t.identityId.equals(current.identityId))).write(
        IdentityCompanion(
          securityProtocol: Value(securityProtocol),
          shamirNumber: Value(shamirNumber),
        ),
      );
    }
  }

  /// Fetches an identity by its `phone_number` (if you plan to use it).
  Future<Identity?> getIdentityByPhoneNumber(String phone) => (select(
    db.identity,
  )..where((t) => t.phoneNumber.equals(phone))).getSingleOrNull();
}
