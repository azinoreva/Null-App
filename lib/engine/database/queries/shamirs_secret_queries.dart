import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/shamirs_secret.dart';

part 'shamirs_secret_queries.g.dart';

@DriftAccessor(tables: [ShamirsSecret])
class ShamirsSecretDao extends DatabaseAccessor<AppDatabase> {
  ShamirsSecretDao(AppDatabase db) : super(db);

  /// Get a secret share by ID
  Future<ShamirsSecret?> getShamirsSecretById(String secretId) {
    return (select(shamirsSecret)..where((tbl) => tbl.secretId.equals(secretId))).getSingleOrNull();
  }

  /// Get all secrets
  Future<List<ShamirsSecret>> getAllShamirsSecrets() {
    return select(shamirsSecret).get();
  }

  /// Insert a new secret
  Future<void> insertShamirsSecret(ShamirsSecretCompanion secret) {
    return into(shamirsSecret).insert(secret);
  }

  /// Update an existing secret
  Future<bool> updateShamirsSecret(ShamirsSecret secret) {
    return update(shamirsSecret).replace(secret);
  }

  /// Delete a secret by ID
  Future<int> deleteShamirsSecretById(String secretId) {
    return (delete(shamirsSecret)..where((tbl) => tbl.secretId.equals(secretId))).go();
  }
}
