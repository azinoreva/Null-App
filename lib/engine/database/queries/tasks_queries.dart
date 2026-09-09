
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tasks.dart';

part 'tasks_queries.g.dart';

/// Persistent task states.
///
/// These values are stored in the Tasks.taskStatus column.
///
/// 0 = pending
/// 1 = running
/// 2 = retry
/// 3 = completed
/// 4 = failed
class TaskStatus {
  static const int pending = 0;
  static const int running = 1;
  static const int retry = 2;
  static const int completed = 3;
  static const int failed = 4;
}

/// Data Access Object for the Tasks table.
///
/// The database is the source of truth for task state.
///
/// The task engine is responsible for scheduling.
/// This DAO is responsible for safely reading and mutating
/// persistent task state.
@DriftAccessor(tables: [Tasks])
class TasksDao extends DatabaseAccessor<AppDatabase>
    with _$TasksDaoMixin {
  TasksDao(super.db);

  // ---------------------------------------------------------------------------
  // Query methods
  // ---------------------------------------------------------------------------

  /// Get a single task by ID.
  Future<Task?> getTaskById(String taskId) {
    return (select(db.tasks)
          ..where((t) => t.taskId.equals(taskId)))
        .getSingleOrNull();
  }

  /// Get all tasks.
  Future<List<Task>> getAllTasks() {
    return select(db.tasks).get();
  }

  /// Get tasks by status.
  Future<List<Task>> getTasksByStatus(int status) {
    return (select(db.tasks)
          ..where((t) => t.taskStatus.equals(status)))
        .get();
  }

  /// Get all actionable tasks.
  ///
  /// Includes:
  /// - pending
  /// - retry
  ///
  /// Excludes:
  /// - running
  /// - completed
  /// - failed
  Future<List<Task>> getActionableTasks() {
    return (select(db.tasks)
          ..where(
            (t) =>
                t.taskStatus.equals(TaskStatus.pending) |
                t.taskStatus.equals(TaskStatus.retry),
          ))
        .get();
  }

  /// Get fresh pending tasks.
  ///
  /// Fresh tasks always have higher priority than retries.
  Future<List<Task>> getPendingTasks() {
    return (select(db.tasks)
          ..where((t) => t.taskStatus.equals(TaskStatus.pending))
          ..orderBy([
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
  }

  /// Get retry tasks whose retry time has arrived.
  ///
  /// Retry tasks are ordered by nextRetryAt so that the oldest
  /// eligible retry is considered first.
  Future<List<Task>> getEligibleRetryTasks({
    required int now,
  }) {
    return (select(db.tasks)
          ..where(
            (t) =>
                t.taskStatus.equals(TaskStatus.retry) &
                (t.nextRetryAt.isNull() |
                    t.nextRetryAt.isSmallerOrEqualValue(now)),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.nextRetryAt),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
  }

  /// Get the next batch of tasks according to queue priority.
  ///
  /// Fresh pending tasks ALWAYS come before retry tasks.
  ///
  /// Retry tasks are only returned when there are no eligible pending tasks.
  Future<List<Task>> getNextTasks({
    required int now,
    int limit = 3,
  }) async {
    final pending = await (select(db.tasks)
          ..where((t) => t.taskStatus.equals(TaskStatus.pending))
          ..orderBy([
            (t) => OrderingTerm.asc(t.createdAt),
          ])
          ..limit(limit))
        .get();

    if (pending.isNotEmpty) {
      return pending;
    }

    return (select(db.tasks)
          ..where(
            (t) =>
                t.taskStatus.equals(TaskStatus.retry) &
                (t.nextRetryAt.isNull() |
                    t.nextRetryAt.isSmallerOrEqualValue(now)),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.nextRetryAt),
            (t) => OrderingTerm.asc(t.createdAt),
          ])
          ..limit(limit))
        .get();
  }

  /// Get tasks currently marked as running.
  ///
  /// Used during engine startup to recover interrupted work.
  Future<List<Task>> getRunningTasks() {
    return (select(db.tasks)
          ..where((t) => t.taskStatus.equals(TaskStatus.running)))
        .get();
  }

  /// Get incomplete/actionable tasks.
  ///
  /// This excludes completed and permanently failed tasks.
  Future<List<Task>> getIncompleteTasks() {
    return (select(db.tasks)
          ..where(
            (t) =>
                t.taskStatus.equals(TaskStatus.pending) |
                t.taskStatus.equals(TaskStatus.running) |
                t.taskStatus.equals(TaskStatus.retry),
          ))
        .get();
  }

  /// Get tasks for a specific server.
  Future<List<Task>> getTasksForServer(String serverId) {
    return (select(db.tasks)
          ..where((t) => t.serverId.equals(serverId)))
        .get();
  }

  /// Get tasks by type.
  Future<List<Task>> getTasksByType(int taskType) {
    return (select(db.tasks)
          ..where((t) => t.taskType.equals(taskType)))
        .get();
  }

  /// Get tasks that have not been synced to a particular target.
  ///
  /// target:
  /// - state
  /// - server
  /// - client
  /// - db
  Future<List<Task>> getUnsyncedTasks(String target) {
    final flagColumn = switch (target) {
      'state' => db.tasks.syncedToState,
      'server' => db.tasks.syncedToServer,
      'client' => db.tasks.syncedToClient,
      'db' => db.tasks.syncedToDb,
      _ => throw ArgumentError(
          'Unknown sync target: $target',
        ),
    };

    return (select(db.tasks)
          ..where((t) => flagColumn.equals(0)))
        .get();
  }

  // ---------------------------------------------------------------------------
  // Insert / Upsert / Update / Delete
  // ---------------------------------------------------------------------------

  /// Insert a new task.
  Future<int> insertTask(Insertable<Task> task) {
    return into(db.tasks).insert(task);
  }

  /// Insert or update a task.
  Future<void> upsertTask(TasksCompanion task) async {
    await into(db.tasks).insertOnConflictUpdate(task);
  }

  /// Replace an entire task row.
  Future<bool> updateTask(Task task) {
    return update(db.tasks).replace(task);
  }

  /// Update selected fields of a task.
  Future<void> updateTaskCompanion(
    String taskId,
    TasksCompanion companion,
  ) async {
    await (update(db.tasks)
          ..where((t) => t.taskId.equals(taskId)))
        .write(companion);
  }

  /// Delete a task.
  Future<int> deleteTask(String taskId) {
    return (delete(db.tasks)
          ..where((t) => t.taskId.equals(taskId)))
        .go();
  }

  /// Delete completed tasks.
  Future<int> deleteCompletedTasks() {
    return (delete(db.tasks)
          ..where((t) => t.taskStatus.equals(TaskStatus.completed)))
        .go();
  }

  // ---------------------------------------------------------------------------
  // State transitions
  // ---------------------------------------------------------------------------

  /// Update task status.
  Future<void> updateTaskStatus(
    String taskId,
    int newStatus,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await (update(db.tasks)
          ..where((t) => t.taskId.equals(taskId)))
        .write(
      TasksCompanion(
        taskStatus: Value(newStatus),
        updatedAt: Value(now),
      ),
    );
  }

  /// Atomically claim a pending task.
  ///
  /// Returns true only when this call successfully changed the task
  /// from pending -> running.
  ///
  /// This prevents two engine operations from claiming the same task.
  Future<bool> claimPendingTask(String taskId) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final affected = await (update(db.tasks)
          ..where(
            (t) =>
                t.taskId.equals(taskId) &
                t.taskStatus.equals(TaskStatus.pending),
          ))
        .write(
      TasksCompanion(
        taskStatus: const Value(TaskStatus.running),
        startedAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    return affected == 1;
  }

  /// Atomically claim an eligible retry task.
  ///
  /// The retry task must:
  /// - currently be in retry state
  /// - have no retry delay
  ///   OR
  /// - have reached its nextRetryAt
  Future<bool> claimRetryTask(
    String taskId, {
    required int now,
  }) async {
    final affected = await (update(db.tasks)
          ..where(
            (t) =>
                t.taskId.equals(taskId) &
                t.taskStatus.equals(TaskStatus.retry) &
                (t.nextRetryAt.isNull() |
                    t.nextRetryAt.isSmallerOrEqualValue(now)),
          ))
        .write(
      TasksCompanion(
        taskStatus: const Value(TaskStatus.running),
        startedAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    return affected == 1;
  }

  /// Mark a task as successfully completed.
  ///
  /// This is only a valid terminal success transition.
  Future<bool> markTaskCompleted(
    String taskId, {
    int? timestamp,
  }) async {
    final now =
        timestamp ?? DateTime.now().millisecondsSinceEpoch;

    final affected = await (update(db.tasks)
          ..where(
            (t) =>
                t.taskId.equals(taskId) &
                t.taskStatus.equals(TaskStatus.running),
          ))
        .write(
      TasksCompanion(
        taskStatus: const Value(TaskStatus.completed),
        completedAt: Value(now),
        startedAt: const Value(null),
        updatedAt: Value(now),
      ),
    );

    return affected == 1;
  }

  /// Move a running task to retry.
  ///
  /// This method:
  /// - increments retry count
  /// - records the error
  /// - clears startedAt
  /// - calculates nextRetryAt
  ///
  /// If the task has reached the maximum retry count, it is instead
  /// permanently marked as failed.
  Future<int> failOrRetryTask(
    String taskId, {
    required String failure,
    String? failureType,
    String? failureStackTrace,
    required int nextRetryAt,
    int maxRetries = 10000,
  }) async {
    final task = await getTaskById(taskId);

    if (task == null) {
      return 0;
    }

    final newRetryCount = task.retryCount + 1;
    final now = DateTime.now().millisecondsSinceEpoch;

    final shouldPermanentlyFail =
        newRetryCount >= maxRetries;

    final status = shouldPermanentlyFail
        ? TaskStatus.failed
        : TaskStatus.retry;

    final affected = await (update(db.tasks)
          ..where(
            (t) =>
                t.taskId.equals(taskId) &
                t.taskStatus.equals(TaskStatus.running),
          ))
        .write(
      TasksCompanion(
        taskStatus: Value(status),
        retryCount: Value(newRetryCount),
        nextRetryAt: shouldPermanentlyFail
            ? const Value(null)
            : Value(nextRetryAt),
        startedAt: const Value(null),
        failedAt: shouldPermanentlyFail
            ? Value(now)
            : const Value(null),
        failure: Value(failure),
        failureType: Value(failureType),
        failureStackTrace: Value(failureStackTrace),
        updatedAt: Value(now),
      ),
    );

    return affected;
  }

  /// Move a timed-out running task to retry.
  ///
  /// A timeout is treated as a failed execution attempt.
  Future<int> markTaskTimedOut(
    String taskId, {
    required int nextRetryAt,
    String failure = 'Task execution timed out.',
    int maxRetries = 10000,
  }) {
    return failOrRetryTask(
      taskId,
      failure: failure,
      failureType: 'timeout',
      nextRetryAt: nextRetryAt,
      maxRetries: maxRetries,
    );
  }

  /// Recover a task that was left in running state because the
  /// application or engine terminated unexpectedly.
  ///
  /// This converts the interrupted task into a retry.
  Future<int> recoverRunningTask(
    String taskId, {
    required int nextRetryAt,
    String failure = 'Task interrupted before completion.',
    int maxRetries = 10000,
  }) {
    return failOrRetryTask(
      taskId,
      failure: failure,
      failureType: 'interrupted',
      nextRetryAt: nextRetryAt,
      maxRetries: maxRetries,
    );
  }

  /// Recover every task that was left running after an interruption.
  Future<int> recoverRunningTasks({
    required int nextRetryAt,
    int maxRetries = 10000,
  }) async {
    final runningTasks = await getRunningTasks();

    var recovered = 0;

    for (final task in runningTasks) {
      final affected = await recoverRunningTask(
        task.taskId,
        nextRetryAt: nextRetryAt,
        maxRetries: maxRetries,
      );

      recovered += affected;
    }

    return recovered;
  }

  // ---------------------------------------------------------------------------
  // Retry helpers
  // ---------------------------------------------------------------------------

  /// Increment retry count atomically.
  ///
  /// Prefer [failOrRetryTask] for normal execution failures because
  /// it performs the retry state transition together with the count
  /// update.
  Future<void> incrementRetryCount(String taskId) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await customUpdate(
      '''
      UPDATE tasks
      SET retrys = retrys + 1,
          updated_at = ?
      WHERE task_id = ?
      ''',
      variables: [
        Variable.withInt(now),
        Variable.withString(taskId),
      ],
      updates: {db.tasks},
    );
  }

  /// Set the next retry time.
  Future<void> setNextRetryAt(
    String taskId,
    int timestamp,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await (update(db.tasks)
          ..where((t) => t.taskId.equals(taskId)))
        .write(
      TasksCompanion(
        nextRetryAt: Value(timestamp),
        updatedAt: Value(now),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sync flags
  // ---------------------------------------------------------------------------

  /// Update task synchronization flags.
  Future<void> updateSyncFlags(
    String taskId, {
    int? syncedToState,
    int? syncedToServer,
    int? syncedToClient,
    int? syncedToDb,
  }) async {
    final companion = TasksCompanion(
      syncedToState: syncedToState != null
          ? Value(syncedToState)
          : const Value.absent(),
      syncedToServer: syncedToServer != null
          ? Value(syncedToServer)
          : const Value.absent(),
      syncedToClient: syncedToClient != null
          ? Value(syncedToClient)
          : const Value.absent(),
      syncedToDb: syncedToDb != null
          ? Value(syncedToDb)
          : const Value.absent(),
      updatedAt: Value(
        DateTime.now().millisecondsSinceEpoch,
      ),
    );

    await (update(db.tasks)
          ..where((t) => t.taskId.equals(taskId)))
        .write(companion);
  }
}

