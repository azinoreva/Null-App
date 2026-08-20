import 'package:drift/drift.dart';
import '../tables/shamirs_secret.dart';

part 'shamirs_secret_queries.g.dart';

/// Data Access Object for the `ShamirsSecret` table.
@DriftAccessor(tables: [ShamirsSecret])
class ShamirsSecretDao extends DatabaseAccessor<AppDatabase>
    with _$ShamirsSecretDaoMixin {
  ShamirsSecretDao(super.db);

  // Get the secret share for a specific identity.
  Future<ShamirsSecret?> getSecretForIdentity(String identityId) =>
      (select(db.shamirsSecret)..where((t) => t.identityId.equals(identityId)))
          .getSingleOrNull();

  // Get all secret shares (rarely needed, but useful for debugging).
  Future<List<ShamirsSecret>> getAllSecrets() => select(db.shamirsSecret).get();

  // Insert a new secret share.
  Future<int> insertSecret(Insertable<ShamirsSecret> secret) =>
      into(db.shamirsSecret).insert(secret);

  // Upsert (insert or update) a secret share.
  Future<void> upsertSecret(ShamirsSecret secret) =>
      into(db.shamirsSecret).insertOnConflictUpdate(secret);

  // Update an existing secret share row.
  Future<bool> updateSecret(ShamirsSecret secret) =>
      update(db.shamirsSecret).replace(secret);

  // Delete a secret share by identity ID.
  Future<int> deleteSecret(String identityId) =>
      (delete(db.shamirsSecret)..where((t) => t.identityId.equals(identityId)))
          .go();

  // Update only the secret share text.
  Future<void> updateSecretShare(String identityId, String newShare) async {
    await (update(db.shamirsSecret)
          ..where((t) => t.identityId.equals(identityId)))
        .write(ShamirsSecretCompanion(
      secretShare: Value(newShare),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  // Update only the encrypted password blob.
  Future<void> updatePasswordBlob(String identityId, Uint8List passwordBlob) async {
    await (update(db.shamirsSecret)
          ..where((t) => t.identityId.equals(identityId)))
        .write(ShamirsSecretCompanion(
      passwordBlob: Value(passwordBlob),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  // Update only the settings payload blob.
  Future<void> updateSettingsPayload(
    String identityId,
    Uint8List? settingsPayload,
  ) async {
    await (update(db.shamirsSecret)
          ..where((t) => t.identityId.equals(identityId)))
        .write(ShamirsSecretCompanion(
      settingsPayload: Value(settingsPayload),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }
}