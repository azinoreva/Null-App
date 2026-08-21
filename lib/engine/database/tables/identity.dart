import 'package:drift/drift.dart';

/// Drift table definition for the `Identity` table.
///
/// This table should contain exactly one row describing the current user.
/// It stores profile data, security settings, and sync preferences.
class Identity extends Table {
  TextColumn get identityId => text()();
  
  TextColumn get displayName => text()();
  TextColumn get avatar => text().nullable()();
  TextColumn get bio => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  IntColumn get securityProtocol => integer().withDefault(const Constant(0))();
  IntColumn get shamirNumber => integer().withDefault(const Constant(0))();
  TextColumn get publicKey => text().nullable()();
  IntColumn get passportVersion => integer().withDefault(const Constant(1))();
  IntColumn get autoSync => integer().withDefault(const Constant(0))();
  IntColumn get allowConnectReq => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {identityId};
}
