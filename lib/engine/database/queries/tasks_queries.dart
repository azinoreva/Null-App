import 'package:drift/drift.dart';
import '../tables/tasks.dart';

part 'tasks_queries.g.dart';

/// Data Access Object for the `Tasks` table.
@DriftAccessor(tables: [Tasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  // Get a single task by its ID.
  Future<Tasks?> getTaskById(String id) =>
      (select(db.tasks)..where((t) => t.taskId.equals(id))).getSingleOrNull();

  // Get all tasks.
  Future<List<Tasks>> getAllTasks() => select(db.tasks).get();

  // Get tasks by status (0 = pending, 1 = in progress, 2 = completed, 3 = failed, 4 = cancelled).
  Future<List<Tasks>> getTasksByStatus(int status) =>
      (select(db.tasks)..where((t) => t.taskStatus.equals(status))).get();

  // Get tasks that are not yet completed (status != 2).
  Future<List<Tasks>> getIncompleteTasks() =>
      (select(db.tasks)..where((t) => t.taskStatus.equals(2).not())).get();

  // Get tasks for a specific server.
  Future<List<Tasks>> getTasksForServer(String serverId) =>
      (select(db.tasks)..where((t) => t.serverId.equals(serverId))).get();

  // Insert a new task.
  Future<int> insertTask(Insertable<Tasks> task) =>
      into(db.tasks).insert(task);

  // Upsert (insert or update) a task.
  Future<void> upsertTask(Tasks task) =>
      into(db.tasks).insertOnConflictUpdate(task);

  // Update an existing task row.
  Future<bool> updateTask(Tasks task) =>
      update(db.tasks).replace(task);

  // Delete a task by ID.
  Future<int> deleteTask(String id) =>
      (delete(db.tasks)..where((t) => t.taskId.equals(id))).go();

  // Update the task status.
  Future<void> updateTaskStatus(String taskId, int newStatus) async {
    await (update(db.tasks)..where((t) => t.taskId.equals(taskId)))
        .write(TasksCompanion(
      taskStatus: Value(newStatus),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  // Mark a task as completed (sets status = 2 and completed_at timestamp).
  Future<void> markTaskCompleted(String taskId, {int? timestamp}) async {
    final now = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    await (update(db.tasks)..where((t) => t.taskId.equals(taskId)))
        .write(TasksCompanion(
      taskStatus: const Value(2),
      completedAt: Value(now),
      completed: const Value(1),
      updatedAt: Value(now),
    ));
  }

  // Mark a task as failed (sets status = 3 and stores failure reason).
  Future<void> markTaskFailed(String taskId, String failureReason) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(db.tasks)..where((t) => t.taskId.equals(taskId)))
        .write(TasksCompanion(
      taskStatus: const Value(3),
      failure: Value(failureReason),
      updatedAt: Value(now),
    ));
  }

  // Update the sync flags for a task.
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
    );
    await (update(db.tasks)..where((t) => t.taskId.equals(taskId)))
        .write(companion);
  }

  // Increment the retry count.
  Future<void> incrementRetryCount(String taskId) async {
    final task = await getTaskById(taskId);
    if (task != null) {
      await (update(db.tasks)..where((t) => t.taskId.equals(taskId)))
          .write(TasksCompanion(
        retryCount: Value(task.retryCount + 1),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));
    }
  }
}