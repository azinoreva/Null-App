import 'package:drift/drift.dart';
import 'servers.dart'; // for foreign key reference

/// Drift table definition for the `Tasks` table.
///
/// Stores background tasks and their synchronization state.
class Tasks extends Table {
  TextColumn get taskId => text()();
  IntColumn get taskType => integer()();
  IntColumn get taskStatus => integer()();
  TextColumn get taskName => text()();

  // Timestamps stored as Unix epoch milliseconds.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  // Note: the original SQL used `retrys`; we keep the same column name
  // but expose it as `retryCount` in Dart for clarity.
  IntColumn get retryCount =>
      integer().named('retrys').withDefault(const Constant(0))();

  TextColumn get serverId =>
      text().nullable().references(Servers, #serverId, onDelete: KeyAction.setNull)();

  // JSON data stored as text.
  TextColumn get taskData => text().nullable()();

  TextColumn get failure => text().nullable()();

  IntColumn get completedAt => integer().nullable()();

  // Sync flags (0 or 1).
  IntColumn get syncedToState =>
      integer().withDefault(const Constant(0)).check(syncedToState.isIn([0, 1]))();
  IntColumn get syncedToServer =>
      integer().withDefault(const Constant(0)).check(syncedToServer.isIn([0, 1]))();
  IntColumn get syncedToClient =>
      integer().withDefault(const Constant(0)).check(syncedToClient.isIn([0, 1]))();
  IntColumn get syncedToDb =>
      integer().withDefault(const Constant(0)).check(syncedToDb.isIn([0, 1]))();

  IntColumn get completed =>
      integer().withDefault(const Constant(0)).check(completed.isIn([0, 1]))();

  @override
  Set<Column> get primaryKey => {taskId};
}