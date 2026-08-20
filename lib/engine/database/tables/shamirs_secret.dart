import 'package:drift/drift.dart';
import 'identity.dart';

/// Drift table definition for the `ShamirsSecret` table.
///
/// Stores Shamir secret shares and related encrypted payloads for a user.
/// This is typically used for password recovery or social key custody.
class ShamirsSecret extends Table {
  TextColumn get identityId =>
      text().references(Identity, #identityId, onDelete: KeyAction.cascade)();

  TextColumn get secretShare => text()();

  // Timestamp stored as Unix epoch milliseconds.
  IntColumn get updatedAt => integer()();

  // Encrypted settings payload (nullable).
  BlobColumn get settingsPayload => blob().nullable()();

  // Encrypted password blob (required).
  BlobColumn get passwordBlob => blob()();

  @override
  Set<Column> get primaryKey => {identityId};
}