
// module name: shamirs_secret_queries

// Fixed from the version provided: the table's primary key is
// `identityId` (one secret-share row per recipient), not `secretId` —
// that column doesn't exist on ShamirsSecret. Lookups/deletes are now
// keyed on identityId instead, and the missing `with
// _$ShamirsSecretDaoMixin` has been added (required for `db.` field
// access and the generated part file to line up).

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/shamirs_secret.dart';

part 'shamirs_secret_queries.g.dart';

@DriftAccessor(tables: [ShamirsSecret])
class ShamirsSecretDao extends DatabaseAccessor<AppDatabase>
    with _$ShamirsSecretDaoMixin {
  ShamirsSecretDao(super.db);

  /// Get the secret-share row stored for a given recipient identity.
  Future<ShamirsSecret?> getShamirsSecretByIdentityId(String identityId) {
    return (select(shamirsSecret)
          ..where((tbl) => tbl.identityId.equals(identityId)))
        .getSingleOrNull();
  }

  /// Get all secret-share rows.
  Future<List<ShamirsSecret>> getAllShamirsSecrets() {
    return select(shamirsSecret).get();
  }

  /// Insert a new secret-share row.
  Future<void> insertShamirsSecret(Insertable<ShamirsSecret> secret) {
    return into(shamirsSecret).insert(secret);
  }

  /// Update an existing secret-share row.
  Future<bool> updateShamirsSecret(ShamirsSecret secret) {
    return update(shamirsSecret).replace(secret);
  }

  /// Delete the secret-share row for a given recipient identity.
  Future<int> deleteShamirsSecretByIdentityId(String identityId) {
    return (delete(shamirsSecret)
          ..where((tbl) => tbl.identityId.equals(identityId)))
        .go();
  }
}