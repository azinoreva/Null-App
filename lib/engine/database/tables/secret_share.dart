import 'package:drift/drift.dart';
import 'identity.dart';

/// Drift table definition for the `SecretShare` table.
///
/// Tracks the last time and version numbers of password/settings
/// that have been shared to a given identity (for Shamir recovery).
class SecretShare extends Table {
  TextColumn get identityId =>
      text().references(Identity, #identityId, onDelete: KeyAction.cascade)();

  IntColumn get lastShared => integer()(); // Unix epoch milliseconds
  IntColumn get passwordVersionShared => integer()();
  IntColumn get settingsVersionShared => integer()();

  @override
  Set<Column> get primaryKey => {identityId};
}