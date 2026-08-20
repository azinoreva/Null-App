import 'package:drift/drift.dart';
import '../tables/secret_share.dart';

part 'secret_share_queries.g.dart';

/// Data Access Object for the `SecretShare` table.
@DriftAccessor(tables: [SecretShare])
class SecretShareDao extends DatabaseAccessor<AppDatabase>
    with _$SecretShareDaoMixin {
  SecretShareDao(super.db);

  // Get the share record for a specific identity.
  Future<SecretShare?> getShareForIdentity(String identityId) =>
      (select(db.secretShare)..where((t) => t.identityId.equals(identityId)))
          .getSingleOrNull();

  // Get all share records.
  Future<List<SecretShare>> getAllShares() => select(db.secretShare).get();

  // Insert a new share record.
  Future<int> insertShare(Insertable<SecretShare> share) =>
      into(db.secretShare).insert(share);

  // Upsert (insert or update) a share record.
  Future<void> upsertShare(SecretShare share) =>
      into(db.secretShare).insertOnConflictUpdate(share);

  // Update an existing share record.
  Future<bool> updateShare(SecretShare share) =>
      update(db.secretShare).replace(share);

  // Delete a share record by identity ID.
  Future<int> deleteShare(String identityId) =>
      (delete(db.secretShare)..where((t) => t.identityId.equals(identityId)))
          .go();

  // Update the last shared timestamp and version numbers.
  Future<void> recordShare(
    String identityId, {
    required int passwordVersion,
    required int settingsVersion,
    int? timestamp,
  }) async {
    final now = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    await into(db.secretShare).insertOnConflictUpdate(
      SecretShareCompanion.insert(
        identityId: identityId,
        lastShared: now,
        passwordVersionShared: passwordVersion,
        settingsVersionShared: settingsVersion,
      ),
    );
  }
}