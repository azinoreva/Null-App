// module name: tasks.dart

import 'package:drift/drift.dart';
import 'servers.dart';

/// Task queue used by the background task engine.
///
/// The database is the source of truth for task state.
///
/// Suggested taskStatus values:
///
/// 0 = pending
/// 1 = running
/// 2 = retry
/// 3 = completed
/// 4 = failed
///
class Tasks extends Table {
  /// Unique identifier for this task.
  TextColumn get taskId => text()();

  /// Numeric task category.
  IntColumn get taskType => integer()();

  /// Current lifecycle state of the task.
  ///
  /// 0 = pending
  /// 1 = running
  /// 2 = retry
  /// 3 = completed
  /// 4 = failed
  IntColumn get taskStatus =>
    integer()
        .withDefault(const Constant(0))
        .check(taskStatus.isIn([0, 1, 2, 3, 4]))();

  /// Name of the function to execute.
  ///
  /// The function must exist in functions_list.dart.
  TextColumn get functionName => text()();

  /// Serialized function arguments.
  ///
  /// Recommended format: JSON instead of comma-separated parameters.
  ///
  /// Example:
  /// {
  ///   "userId": "123",
  ///   "messageId": "456",
  ///   "optionalValue": null
  /// }
  ///
  /// This avoids problems with commas, null values, escaping,
  /// parameter ordering, and future argument changes.
  TextColumn get functionArgs =>
      text().withDefault(const Constant('{}'))();

  /// Optional binary parameters.
  ///
  /// These can be referenced by the serialized functionArgs.
  BlobColumn get blobparam1 => blob().nullable()();
  BlobColumn get blobparam2 => blob().nullable()();
  BlobColumn get blobparam3 => blob().nullable()();
  BlobColumn get blobparam4 => blob().nullable()();
  BlobColumn get blobparam5 => blob().nullable()();

  /// Timestamp when the task was created.
  ///
  /// Unix epoch milliseconds.
  IntColumn get createdAt => integer()();

  /// Timestamp of the most recent modification.
  ///
  /// Unix epoch milliseconds.
  IntColumn get updatedAt => integer()();

  /// Number of failed or timed-out execution attempts.
  IntColumn get retryCount =>
      integer()
          .named('retrys')
          .withDefault(const Constant(0))();

  /// Earliest time at which this retry task may execute again.
  ///
  /// Null means the task may execute immediately.
  ///
  /// Unix epoch milliseconds.
  IntColumn get nextRetryAt => integer().nullable()();

  /// Timestamp when the current execution attempt started.
  ///
  /// Used for:
  /// - execution timing
  /// - timeout detection
  /// - recovery of interrupted tasks
  IntColumn get startedAt => integer().nullable()();

  /// Timestamp when the task completed successfully.
  ///
  /// Unix epoch milliseconds.
  IntColumn get completedAt => integer().nullable()();

  /// Timestamp when the task permanently failed.
  ///
  /// Unix epoch milliseconds.
  IntColumn get failedAt => integer().nullable()();

  /// Human-readable error from the most recent failure.
  TextColumn get failure => text().nullable()();

  /// Type or category of the most recent error.
  TextColumn get failureType => text().nullable()();

  /// Stack trace from the most recent failure, where available.
  TextColumn get failureStackTrace => text().nullable()();

  /// Optional server associated with this task.
  TextColumn get serverId =>
      text()
          .nullable()
          .references(
            Servers,
            #serverId,
            onDelete: KeyAction.setNull,
          )();

  /// Additional task metadata.
  ///
  /// JSON stored as text.
  TextColumn get taskData => text().nullable()();

  /// Sync state flags.
  IntColumn get syncedToState =>
      integer()
          .withDefault(const Constant(0))
          .check(syncedToState.isIn([0, 1]))();

  IntColumn get syncedToServer =>
      integer()
          .withDefault(const Constant(0))
          .check(syncedToServer.isIn([0, 1]))();

  IntColumn get syncedToClient =>
      integer()
          .withDefault(const Constant(0))
          .check(syncedToClient.isIn([0, 1]))();

  IntColumn get syncedToDb =>
      integer()
          .withDefault(const Constant(0))
          .check(syncedToDb.isIn([0, 1]))();

  @override
  Set<Column> get primaryKey => {taskId};
}

