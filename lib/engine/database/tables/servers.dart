import 'package:drift/drift.dart';

/// Drift table definition for the `Servers` table.
/// Stores information about messaging servers that the user can connect to.
class Servers extends Table {
  TextColumn get serverId => text()();
  TextColumn get serverUrl => text()();
  TextColumn get mediaUrl => text()();
  IntColumn get mediaSizeLimit =>
      integer().withDefault(const Constant(100000))();
  DateTimeColumn get mediaLastReset => dateTime()();
  IntColumn get totalMediaSent => integer().withDefault(const Constant(0))();
  TextColumn get serverName => text()();
  IntColumn get mediaTimer => integer().withDefault(const Constant(86400))();
  IntColumn get maxPayload => integer().withDefault(const Constant(5))();
  IntColumn get capabilities => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {serverId};
}
