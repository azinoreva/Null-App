import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tasks.dart';

part 'tasks_queries.g.dart';

/// Status constants for tasks.
class TaskStatus {
  static const int pending = 0;
  static const int inProgress = 1;
  static const int completed = 2;
  static const int failed = 3;
  static const int cancelled = 4;
}

/// What `taskType` on a row means. Set once at enqueue time (see
/// TaskQueue.queueTask) by looking up the function's declared kind in
/// functions_list.dart -- the function defines what it is, callers don't
/// choose it per-call.
class TaskKind {
  static const int nonNetwork = 0;
  static const int network = 1;
}

/// Data Access Object for the `Tasks` table.
@DriftAccessor(tables: [Tasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  // ---------------------------------------------------------------------
  // Query methods
  // ---------------------------------------------------------------------

  /// Get a single task by its ID.
  Future<Task?> getTaskById(String id) =>
      (select(db.tasks)..where((t) => t.taskId.equals(id))).getSingleOrNull();

  /// Get all tasks.
  Future<List<Task>> getAllTasks() => select(db.tasks).get();

  /// Get tasks by status.
  Future<List<Task>> getTasksByStatus(int status) =>
      (select(db.tasks)..where((t) => t.taskStatus.equals(status))).get();

  /// Get tasks that are not completed (status != 2).
  Future<List<Task>> getIncompleteTasks() =>
      (select(db.tasks)..where((t) => t.taskStatus.equals(TaskStatus.completed).not())).get();

  /// Get tasks for a specific server.
  Future<List<Task>> getTasksForServer(String serverId) =>
      (select(db.tasks)..where((t) => t.serverId.equals(serverId))).get();

  /// Get tasks by type.
  Future<List<Task>> getTasksByType(int taskType) =>
      (select(db.tasks)..where((t) => t.taskType.equals(taskType))).get();

  /// Get tasks that have not been synced to a particular target.
  /// `target` can be one of: 'state', 'server', 'client', 'db'.
  Future<List<Task>> getUnsyncedTasks(String target) {
    final flagColumn = switch (target) {
      'state' => db.tasks.syncedToState,
      'server' => db.tasks.syncedToServer,
      'client' => db.tasks.syncedToClient,
      'db' => db.tasks.syncedToDb,
      _ => throw ArgumentError('Unknown sync target: $target'),
    };
    return (select(db.tasks)..where((t) => flagColumn.equals(0))).get();
  }

  /// The single next task the engine should work on.
  ///
  /// Two rules stack here:
  ///
  /// 1. Fresh before retry, always: pending tasks are ordered by retry
  ///    count ascending first. A task with retrys = 0 is always returned
  ///    before ANY task with retrys > 0, no matter how long that retrying
  ///    task has been waiting.
  /// 2. Network before non-network, as a tiebreaker within each of those
  ///    retry tiers: among equally-fresh (or equally-retried) tasks, the
  ///    network one goes first.
  ///
  /// [networkAvailable] gates rule 2 entirely: when false, network tasks
  /// are excluded from the candidate set altogether ("frozen") and only
  /// non-network work is returned, regardless of retry count.
  Future<Task?> getNextPendingTask({required bool networkAvailable}) {
    final query = select(db.tasks)
      ..where((t) {
        final isPending = t.taskStatus.equals(TaskStatus.pending);
        if (networkAvailable) return isPending;
        return isPending & t.taskType.equals(TaskKind.nonNetwork);
      })
      ..orderBy([
        (t) => OrderingTerm(expression: t.retryCount),
        (t) => OrderingTerm(expression: t.taskType, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.createdAt),
      ])
      ..limit(1);

    return query.getSingleOrNull();
  }

  // ---------------------------------------------------------------------
  // Insert / Upsert / Update / Delete
  // ---------------------------------------------------------------------

  /// Insert a new task. Accepts either a [Tasks] object or a [TasksCompanion].
  Future<int> insertTask(Insertable<Task> task) =>
      into(db.tasks).insert(task);

  /// Upsert (insert or update) a task using a companion.
  Future<void> upsertTask(TasksCompanion task) =>
      into(db.tasks).insertOnConflictUpdate(task);

  /// Replace an entire task row with a [Tasks] object.
  /// Only use this if you are sure all fields are populated correctly.
  Future<bool> updateTask(Task task) =>
      update(db.tasks).replace(task);

  /// Update specific fields of a task using a companion.
  Future<void> updateTaskCompanion(String taskId, TasksCompanion companion) async {
    await (update(db.tasks)..where((t) => t.taskId.equals(taskId)))
        .write(companion);
  }

  /// Delete a task by ID.
  Future<int> deleteTask(String id) =>
      (delete(db.tasks)..where((t) => t.taskId.equals(id))).go();

  /// Delete all tasks that have been completed.
  Future<int> deleteCompletedTasks() =>
      (delete(db.tasks)..where((t) => t.taskStatus.equals(TaskStatus.completed))).go();

  // ---------------------------------------------------------------------
  // Convenience update methods
  // ---------------------------------------------------------------------

  /// Update the task status.
  Future<void> updateTaskStatus(String taskId, int newStatus) async {
    await (update(db.tasks)..where((t) => t.taskId.equals(taskId)))
        .write(TasksCompanion(
      taskStatus: Value(newStatus),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  /// Mark a task as completed (status = 2, completed_at, completed = 1).
  Future<void> markTaskCompleted(String taskId, {int? timestamp}) async {
    final now = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    await (update(db.tasks)..where((t) => t.taskId.equals(taskId)))
        .write(TasksCompanion(
      taskStatus: const Value(TaskStatus.completed),
      completedAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  Future<bool> claimTask(String taskId) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final affected = await (update(db.tasks)
          ..where(
            (t) =>
                t.taskId.equals(taskId) &
                t.taskStatus.equals(TaskStatus.pending),
          ))
        .write(
      TasksCompanion(
        taskStatus: const Value(TaskStatus.inProgress),
        updatedAt: Value(now),
      ),
    );

    return affected == 1;
  }

  /// Mark a task as terminally failed (status = 3, failure reason).
  /// Used once a task has exhausted its retries.
  Future<void> markTaskFailed(String taskId, String failureReason) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(db.tasks)..where((t) => t.taskId.equals(taskId)))
        .write(TasksCompanion(
      taskStatus: const Value(TaskStatus.failed),
      failure: Value(failureReason),
      updatedAt: Value(now),
    ));
  }

  /// Puts a task that just failed a run back into the pending pool so it
  /// can be retried. Does NOT change retrys itself -- call
  /// [incrementRetryCount] first (or pass its result along) so the retry
  /// counter and status update stay consistent. Because
  /// [getNextPendingTask] orders retrys = 0 ahead of retrys > 0, this task
  /// will only be picked up again once every fresh task has been drained.
  Future<void> requeueForRetry(String taskId, String failureReason) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(db.tasks)..where((t) => t.taskId.equals(taskId)))
        .write(TasksCompanion(
      taskStatus: const Value(TaskStatus.pending),
      failure: Value(failureReason),
      updatedAt: Value(now),
    ));
  }

  /// Update sync flags.
  Future<void> updateSyncFlags(
    String taskId, {
    int? syncedToState,
    int? syncedToServer,
    int? syncedToClient,
    int? syncedToDb,
  }) async {
    final companion = TasksCompanion(
      syncedToState: syncedToState != null ? Value(syncedToState) : const Value.absent(),
      syncedToServer: syncedToServer != null ? Value(syncedToServer) : const Value.absent(),
      syncedToClient: syncedToClient != null ? Value(syncedToClient) : const Value.absent(),
      syncedToDb: syncedToDb != null ? Value(syncedToDb) : const Value.absent(),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    );
    await (update(db.tasks)..where((t) => t.taskId.equals(taskId)))
        .write(companion);
  }

  /// Atomically increments the retry counter and returns the NEW value,
  /// so the caller can decide in one step whether this task has now hit
  /// the retry ceiling (e.g. >= 10000) and should be marked permanently
  /// failed instead of requeued.
  Future<int> incrementRetryCount(String taskId) {
    return transaction(() async {
      await customUpdate(
        'UPDATE tasks SET retrys = retrys + 1, updated_at = ? WHERE task_id = ?',
        variables: [
          Variable.withInt(DateTime.now().millisecondsSinceEpoch),
          Variable.withString(taskId),
        ],
        updates: {db.tasks},
      );

      final row =
          await (select(db.tasks)..where((t) => t.taskId.equals(taskId))).getSingle();
      return row.retryCount;
    });
  }
}