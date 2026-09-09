# Task Engine Implementation Requirements

Build a production-grade task execution engine for the `Tasks` table.

The task engine must use the `Tasks` Drift table as the persistent source of truth for all task state.

Task execution functions are defined in:

`functions_list.dart`

The engine must execute functions based on the `functionName` stored in each task.

---

# 1. Engine lifecycle

The engine must not run continuously.

It must only run when explicitly triggered through a public function such as:

```dart
start()
```

or:

```dart
trigger()
```

Calling this function should wake the task engine.

The engine should then inspect the database for work that needs processing.

If no work exists, the engine should become idle and stop processing.

The engine must not continuously poll the database.

The engine should only execute when:

* Explicitly triggered
* New work is added and triggers the engine
* A retry task becomes eligible and triggers the engine
* Network state changes from unavailable to available, if eligible network tasks exist

The Flutter UI isolate must never be blocked by task scheduling or task execution.

The task engine must run in a dedicated Dart isolate.

---

# 1.1 Network state management

Network connectivity must be managed independently from the task engine.

The application must have a dedicated network-state component responsible for determining whether network connectivity is currently available.

The network-state component must:

1. Detect connectivity changes
2. Maintain the current network state
3. Persist the latest state in `SharedPreferences`
4. Expose the state through a stream or equivalent event mechanism
5. Notify subscribers whenever the state changes

The task engine must subscribe to this network-state component.

The task engine must not continuously poll the network.

The task engine must not be responsible for detecting network connectivity.

The persisted network state may be represented as:

```text
network_available = true
```

or:

```text
network_available = false
```

The engine may keep the current network state in memory after receiving it from the network-state component.

`SharedPreferences` is the persisted cache of the latest network state. It is not the task engine's event mechanism.

The network-state component should expose an interface conceptually equivalent to:

```dart
enum NetworkState {
  online,
  offline,
}
```

and:

```dart
NetworkState get currentState;

Stream<NetworkState> get stateChanges;
```

When the network becomes available, the network-state component must emit the new state.

The task engine must respond by triggering another scheduling pass.

When the network becomes unavailable, the task engine must stop assigning network-dependent tasks to workers.

The engine must not treat loss of connectivity by itself as a task failure.

It must not increment `retryCount` merely because the device is offline.

It must not repeatedly retry network tasks while the device is offline.

Network unavailability is an execution constraint, not a task failure.

---

# 1.2 Network-aware task types

The existing:

```dart
taskType
```

column must be used to classify task execution requirements.

Do not add a separate `requiresNetwork` column unless there is a future architectural reason to do so.

Task types should be centrally defined, for example:

```dart
abstract final class TaskType {
  static const int local = 0;
  static const int network = 1;
}
```

The exact numeric values may be expanded as additional task categories are introduced.

A task whose:

```text
taskType = network
```

requires network availability before execution.

A task whose:

```text
taskType = local
```

does not require network availability.

The task type is part of the persistent task definition and must remain available after application restart.

---

# 1.3 Network-aware scheduling

The scheduler must consider both:

```text
taskStatus
```

and:

```text
taskType
```

when determining whether a task is executable.

When network connectivity is available:

```text
local tasks    → executable
network tasks → executable
```

When network connectivity is unavailable:

```text
local tasks    → executable
network tasks → blocked
```

Blocked network tasks must remain in their current persistent state.

For example:

```text
pending + network
```

must remain:

```text
pending + network
```

while offline.

Likewise:

```text
retry + network
```

must remain:

```text
retry + network
```

until both conditions are satisfied:

```text
nextRetryAt <= currentTime
```

and:

```text
network_available = true
```

The engine must not claim a blocked network task.

The engine must not change a blocked network task to `failed`.

The engine must not increment its retry count simply because connectivity is unavailable.

The engine must not create a retry loop while offline.

---

# 1.4 Network state changes

When the network changes from:

```text
offline → online
```

the network-state component must emit the event.

The task engine must receive the event and trigger a scheduling pass.

The engine must then inspect the database for newly executable tasks.

When the network changes from:

```text
online → offline
```

the engine must prevent new network-dependent tasks from being assigned.

Network tasks that are already running must not automatically be cancelled solely because connectivity was lost.

An already-running network task may complete, fail, or reach its normal execution timeout.

If the network request itself fails, the normal task failure and retry rules apply.

The engine must distinguish between:

```text
network unavailable before execution
```

and:

```text
network failure during execution
```

The first must not count as a failed attempt.

The second may count as a failed execution attempt and follow the normal retry policy.

---

# 1.5 Network state and retry scheduling

Network unavailability must not cause retry timers to repeatedly wake the task engine.

For a network task that is waiting for connectivity:

```text
no connectivity
       ↓
do not execute
       ↓
do not increment retryCount
       ↓
do not continuously retry
       ↓
wait for network-state event
       ↓
network becomes available
       ↓
trigger engine
```

The engine should therefore remain idle when its only remaining executable candidates are network tasks and the network is unavailable.

The engine must not poll the database waiting for connectivity.

The network-state event is responsible for waking the engine when connectivity becomes available.

---

# 1.6 Initial network state

When the task engine starts, it should obtain the latest network state from the network-state component.

The network-state component may initialize itself using the persisted `SharedPreferences` value and then establish the current connectivity state.

The task engine must not assume that a missing network state means that network connectivity is available.

An unknown or unavailable network state should be treated conservatively for network-dependent tasks.

Local tasks may continue to execute independently.

---

# 2. Task status values

The `taskStatus` column is the authoritative source of task lifecycle state.

Use the following values:

```text
0 = pending
1 = running
2 = retry
3 = completed
4 = failed
```

A task must never have conflicting state.

The lifecycle should normally follow:

```text
pending
   ↓
running
   ↓
completed
```

or:

```text
pending
   ↓
running
   ↓
retry
   ↓
running
   ↓
completed
```

or eventually:

```text
pending
   ↓
running
   ↓
retry
   ↓
failed
```

---

# 3. Engine startup and recovery

Whenever the engine starts, it must first inspect tasks currently marked as:

```text
running
```

A running task may have been interrupted because:

* The application was closed
* The application crashed
* The isolate terminated
* The process was killed
* The device shut down

A task must never remain permanently stuck in the running state.

If a previously running task is discovered during engine startup, the engine should return it to:

```text
retry
```

The retry count should be incremented only if the interrupted execution counts as a failed attempt.

The previous execution information should remain available through the task error fields where appropriate.

---

# 4. Loading tasks

The engine must query the database for eligible tasks.

There are two queue priorities.

## Priority 1: Fresh tasks

Fresh tasks are tasks with:

```text
taskStatus = pending
```

Fresh tasks always have the highest priority.

## Priority 2: Retry tasks

Retry tasks are tasks with:

```text
taskStatus = retry
```

A retry task may only execute when:

```text
nextRetryAt <= currentTime
```

or:

```text
nextRetryAt IS NULL
```

Retry tasks must never be processed ahead of fresh pending tasks.

The engine must always exhaust currently available fresh tasks before processing retry tasks.

If a new fresh task appears while retry tasks are being processed, fresh tasks must take priority for the next available worker.

Existing retry tasks that are already running should not be interrupted.

When network connectivity is unavailable, network-dependent tasks must be excluded from the set of eligible tasks.

Local tasks must remain eligible.

---

# 5. Task scheduling

The engine is a scheduler and coordinator.

The engine itself must not perform heavy task execution.

The engine must:

* Load tasks
* Prioritize tasks
* Assign tasks to workers
* Track running tasks
* Track worker availability
* Measure task execution time
* Detect timeouts
* Record results
* Schedule retries
* Recover interrupted work
* Respect network availability when scheduling network-dependent tasks

The engine must maintain a record of active jobs.

Every active task should be tracked using its `taskId`.

The scheduler should track:

```text
taskId
workerId
startedAt
executionState
```

The task ID is the identity of the job.

The engine should track jobs rather than relying only on isolate identity.

---

# 6. Worker isolates

Task execution must occur in worker isolates.

Worker isolates should only be responsible for:

1. Receiving a task
2. Resolving the execution function from `functions_list.dart`
3. Parsing `functionArgs`
4. Accessing any required blob parameters
5. Executing the function
6. Returning success or failure information to the engine

Worker isolates must not:

* Control queue priority
* Schedule retries
* Decide whether to create additional workers
* Modify global task scheduling state
* Decide whether network-dependent tasks may execute

The engine remains the central coordinator.

---

# 7. Maximum concurrency

The maximum number of concurrently active worker isolates is:

```text
3
```

The engine must never execute more than three tasks concurrently.

The engine should initially execute work using one worker.

If that worker has been executing its current task for more than:

```text
2 seconds
```

and additional eligible tasks are waiting, the scheduler may allocate another worker.

The engine may continue expanding concurrency until:

```text
3 workers
```

are active.

A worker exceeding two seconds does not mean the task has failed.

The task may continue running until it either:

* Completes
* Fails
* Reaches the execution timeout

Worker isolates should be reused where practical.

Do not create and destroy an isolate for every individual task unless necessary.

---

# 8. Task execution timing

Immediately before assigning a task to a worker, the engine must:

1. Set:

```text
taskStatus = running
```

2. Set:

```text
startedAt = current Unix epoch milliseconds
```

3. Update:

```text
updatedAt = current Unix epoch milliseconds
```

The engine must begin timing the task immediately after it is marked as running.

The execution timer must stop when the engine receives:

* Success
* Failure
* Timeout

The execution duration may be calculated from:

```text
currentTime - startedAt
```

The task execution time should be available for logging or debugging.

---

# 9. Successful execution

When a worker successfully completes a task, it must return a success result to the engine.

The engine must then update the database atomically.

The task should become:

```text
taskStatus = completed
completedAt = currentTime
updatedAt = currentTime
```

The task must no longer be eligible for execution.

A completed task must never be executed again.

---

# 10. Task failure

If a worker returns an error before the execution timeout, the engine must:

1. Stop tracking the task as actively running
2. Record the failure message
3. Record the failure type
4. Record the stack trace where available
5. Increment `retryCount`
6. Determine whether the maximum retry limit has been reached

If the retry limit has not been reached, the task must be moved to:

```text
taskStatus = retry
```

The task must be placed at the logical end of the queue.

The task must not block fresh pending tasks.

---

# 11. Execution timeout

The maximum execution time for a task is:

```text
10 seconds
```

If a task has not returned success or failure after ten seconds, the engine must treat the execution attempt as timed out.

The engine must:

1. Mark the execution attempt as no longer active
2. Record a timeout error
3. Increment `retryCount`
4. Move the task to retry if retries remain
5. Set an appropriate `nextRetryAt`
6. Release the worker slot for future work

The engine must protect against stale or late responses from a timed-out worker.

Every worker response must be validated against the currently active execution attempt for that task.

A late response from a previously timed-out attempt must not overwrite a newer retry attempt.

---

# 12. Retry scheduling

The maximum retry count is:

```text
10000
```

A task must remain eligible for retries until it reaches the maximum retry count.

However, retries must not happen immediately in a tight loop.

Every retry should use a delay or backoff.

The next allowed execution time must be stored in:

```text
nextRetryAt
```

Retry tasks must only be selected when:

```text
nextRetryAt <= currentTime
```

or:

```text
nextRetryAt IS NULL
```

Retry tasks must always have lower priority than fresh tasks.

The priority order is:

```text
1. pending
2. retry
```

A retry task must never be inserted ahead of fresh tasks.

Network-dependent retry tasks must additionally require:

```text
network_available = true
```

before execution.

---

# 13. Retry exhaustion

After every failed or timed-out attempt:

```text
retryCount += 1
```

If:

```text
retryCount < 10000
```

the task should return to:

```text
taskStatus = retry
```

If:

```text
retryCount >= 10000
```

the task must be permanently marked:

```text
taskStatus = failed
failedAt = currentTime
updatedAt = currentTime
```

The final error information must remain stored in:

```text
failure
failureType
failureStackTrace
```

A permanently failed task must never be automatically executed again.

A failed task must never block the remaining queue.

---

# 14. Function resolution

Task functions must be resolved from:

```text
functions_list.dart
```

The engine must use:

```text
functionName
```

to identify the correct execution function.

The implementation must use a controlled function registry.

Do not use reflection.

Do not dynamically execute arbitrary function names.

Only functions explicitly registered in `functions_list.dart` may be executed.

If `functionName` does not exist in the approved registry:

1. Record an error
2. Increment the retry count only if the failure is considered recoverable
3. Otherwise permanently mark the task as failed

An unknown function name should normally be treated as a non-recoverable failure.

---

# 15. Function arguments

`functionArgs` should be treated as serialized structured data.

JSON should be used instead of comma-separated values.

The engine must safely deserialize:

```text
functionArgs
```

and pass the resulting values to the registered task function.

Null values must remain valid parameters.

Blob parameters may be referenced through:

```text
blobparam1
blobparam2
blobparam3
blobparam4
blobparam5
```

The implementation must not lose binary data while passing task arguments.

---

# 16. Database consistency

The database is the persistent source of truth.

All important task state transitions must be persisted.

The following transitions should be performed safely:

```text
pending → running
running → completed
running → retry
running → failed
retry → running
```

A task must not be simultaneously processed by multiple workers.

Before assigning a task, the engine must atomically claim it by changing its state from:

```text
pending or retry
```

to:

```text
running
```

The claim operation must ensure that another engine trigger cannot execute the same task concurrently.

Network availability must not be persisted as task lifecycle state. It is an external execution constraint.

---

# 17. Trigger behavior

Multiple calls to the engine trigger function must not create duplicate engines or duplicate task execution.

If the engine is already active, another trigger should notify the existing engine that new work may be available.

The engine should then re-check the database when appropriate.

There must only be one active task engine scheduler for the application.

The engine must protect against concurrent trigger calls.

A network-state transition to:

```text
online
```

must behave as an engine trigger.

A network-state transition to:

```text
offline
```

must not continuously trigger the engine.

---

# 18. Error handling

All errors must be captured safely.

Where available, store:

```text
error message
error type
stack trace
timestamp
retry count
```

A worker failure must never crash the engine.

An engine failure must never crash the Flutter UI isolate.

Unexpected errors must be contained and reported through the task database.

---

# 19. Final architecture

The intended architecture is:

```text
                         Flutter UI Isolate
                                │
                                │ trigger()
                                ▼
                       Task Engine Isolate
                                │
                         ┌──────┴──────┐
                         │             │
                         │ scheduler   │
                         │             │
                         ▼             │
                    Drift Database     │
                         │             │
                         │             │
                         ▼             │
                 Eligible Tasks        │
                         │             │
                ┌────────┴────────┐    │
                │                 │    │
                ▼                 ▼    │
            Worker 1          Worker 2 │
                │                 │    │
                └────────┬────────┘    │
                         │             │
                         ▼             │
                       Results         │
                         │             │
                         └──────┬──────┘
                                │
                                ▼
                         Task Engine


                  Network State Component
                           │
                           ├── detects connectivity
                           │
                           ├── SharedPreferences
                           │
                           └── stateChanges stream
                                      │
                                      ▼
                              Task Engine Isolate
                                      │
                                      ▼
                         network task scheduling
```

The task engine is the scheduler and coordinator.

Worker isolates execute tasks.

The database stores persistent task state.

The network-state component detects and publishes connectivity state.

`SharedPreferences` stores the latest network state.

The task engine subscribes to network-state changes rather than polling connectivity.

Network availability determines whether network-dependent tasks are currently executable.

The Flutter UI isolate must remain independent from task execution.

Here are modules you can use or edit:```dart
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




// module name: task_queue.dart

import 'dart:async';
import 'convert';
import 'typed_data';

import 'package:drift/drift.dart';

import 'database/app_database.dart';
import 'database/queries/tasks_queries.dart';

typedef TaskExecutor = Future<void> Function(
  Tasks task,
  TaskArguments args,
);

class TaskQueue {
  TaskQueue({
    required this.database,
    required Map<String, TaskExecutor> executors,
  }) : _executors = Map.unmodifiable(executors);

  final AppDatabase database;
  final Map<String, TaskExecutor> _executors;

  Timer? _nudgeTimer;

  bool _running = false;
  bool _nudged = false;
  bool _started = false;

  bool get isRunning => _running;

  /// Queues a new task in the database and wakes the queue.
  ///
  /// The database is the source of truth. The in-memory nudge only tells
  /// the queue that it should look at the database again.
  Future<String> queueTask({
    required String functionName,
    required List<dynamic> args,
    int taskType = 0,
    String? serverId,
    String? taskData,
  }) async {
    final taskId = _generateTaskId();
    final now = DateTime.now().millisecondsSinceEpoch;

    final encodedArguments = <dynamic>[];
    final blobs = <Uint8List?>[
      null,
      null,
      null,
      null,
      null,
    ];

    var blobIndex = 0;

    for (final argument in args) {
      if (argument is Uint8List || argument is List<int>) {
        blobIndex++;

        if (blobIndex > 5) {
          throw ArgumentError(
            'A task can contain at most 5 blob parameters.',
          );
        }

        final blob = argument is Uint8List
            ? argument
            : Uint8List.fromList(argument);

        blobs[blobIndex - 1] = blob;

        encodedArguments.add('__BLOB__:$blobIndex');
      } else {
        _validateSerializableArgument(argument);
        encodedArguments.add(argument);
      }
    }

    await database.tasksDao.insertTask(
      TasksCompanion.insert(
        taskId: taskId,
        taskType: taskType,
        taskStatus: TaskStatus.pending,
        functionName: functionName,
        functionArgs: jsonEncode(encodedArguments),
        blobparam1: Value(blobs[0]),
        blobparam2: Value(blobs[1]),
        blobparam3: Value(blobs[2]),
        blobparam4: Value(blobs[3]),
        blobparam5: Value(blobs[4]),
        createdAt: now,
        updatedAt: now,
        serverId: Value(serverId),
        taskData: Value(taskData),
      ),
    );

    nudge();

    return taskId;
  }

  /// Starts the queue.
  ///
  /// This performs crash recovery once and then processes actionable tasks.
  Future<void> start() async {
    if (_started) {
      nudge();
      return;
    }

    _started = true;

    try {
      await _recoverInterruptedTasks();
    } catch (_) {
      // Recovery failure must not crash the application.
      //
      // The database remains the source of truth. A later nudge/start
      // can attempt recovery again.
    }

    nudge();
  }

  /// Wakes the queue.
  ///
  /// This does not start another queue if one is already processing.
  void nudge() {
    _nudged = true;

    if (!_running) {
      unawaited(_process());
    }
  }

  /// Delays a nudge slightly so multiple writes occurring together do not
  /// cause unnecessary queue wakeups.
  void _scheduleNudge() {
    _nudgeTimer?.cancel();

    _nudgeTimer = Timer(
      const Duration(milliseconds: 500),
      nudge,
    );
  }

  Future<void> _process() async {
    if (_running) {
      _nudged = true;
      return;
    }

    _running = true;

    try {
      do {
        _nudged = false;

        await _processTasks();

        // A task may have been inserted or transitioned into an actionable
        // state while processing was underway.
        if (await _hasActionableTasks()) {
          _nudged = true;
        }
      } while (_nudged);
    } catch (_) {
      // The queue must never take down the application.
      //
      // Individual task failures are handled inside _executeTask().
    } finally {
      _running = false;

      // A nudge can arrive between the final database check and setting
      // _running to false.
      if (_nudged) {
        unawaited(_process());
      }
    }
  }

  /// Processes tasks serially.
  ///
  /// Worker-isolate concurrency can be introduced above/below this layer
  /// without changing the database/task semantics.
  Future<void> _processTasks() async {
    while (true) {
      final task = await _claimNextTask();

      if (task == null) {
        return;
      }

      await _executeTask(task);
    }
  }

  /// Gets the highest-priority actionable task and atomically claims it.
  ///
  /// Priority:
  ///   1. pending tasks
  ///   2. eligible retry tasks
  ///
  /// The DAO performs the actual atomic state transition.
  Future<Tasks?> _claimNextTask() async {
    final candidates = await database.tasksDao.getNextTasks(
      DateTime.now().millisecondsSinceEpoch,
      limit: 1,
    );

    if (candidates.isEmpty) {
      return null;
    }

    final candidate = candidates.first;

    bool claimed;

    switch (candidate.taskStatus) {
      case TaskStatus.pending:
        claimed = await database.tasksDao.claimPendingTask(
          candidate.taskId,
        );
        break;

      case TaskStatus.retry:
        claimed = await database.tasksDao.claimRetryTask(
          candidate.taskId,
          DateTime.now().millisecondsSinceEpoch,
        );
        break;

      default:
        return null;
    }

    if (!claimed) {
      // Another queue/worker/process may have claimed it.
      //
      // Do not mutate it. Simply wake the queue again and let the database
      // determine what should happen next.
      _nudged = true;
      return null;
    }

    return database.tasksDao.getTaskById(candidate.taskId);
  }

  Future<void> _executeTask(Tasks task) async {
    final executor = _executors[task.functionName];

    if (executor == null) {
      await database.tasksDao.failOrRetryTask(
        task.taskId,
        failure: 'No executor registered for "${task.functionName}".',
        failureType: 'executor_not_found',
      );

      return;
    }

    try {
      final args = TaskArguments.fromTask(task);

      await executor(task, args);

      await database.tasksDao.markTaskCompleted(
        task.taskId,
      );
    } catch (error, stackTrace) {
      await database.tasksDao.failOrRetryTask(
        task.taskId,
        failure: error.toString(),
        failureType: 'execution_error',
        failureStackTrace: stackTrace.toString(),
      );
    }
  }

  /// Returns whether there is work that can currently be executed.
  ///
  /// This includes:
  ///   - pending tasks
  ///   - retry tasks whose nextRetryAt has arrived
  Future<bool> _hasActionableTasks() async {
    final tasks = await database.tasksDao.getNextTasks(
      DateTime.now().millisecondsSinceEpoch,
      limit: 1,
    );

    return tasks.isNotEmpty;
  }

  /// Converts tasks left in RUNNING state after an application/process
  /// interruption into retryable tasks.
  ///
  /// The DAO owns the state transition and retry accounting.
  Future<void> _recoverInterruptedTasks() async {
    await database.tasksDao.recoverRunningTasks();
  }

  static String _generateTaskId() {
    return 'task_${DateTime.now().microsecondsSinceEpoch}';
  }

  static void _validateSerializableArgument(dynamic value) {
    if (value == null ||
        value is String ||
        value is num ||
        value is bool) {
      return;
    }

    if (value is List) {
      for (final item in value) {
        _validateSerializableArgument(item);
      }

      return;
    }

    if (value is Map) {
      for (final entry in value.entries) {
        if (entry.key is! String) {
          throw ArgumentError(
            'Task map keys must be strings.',
          );
        }

        _validateSerializableArgument(entry.value);
      }

      return;
    }

    throw ArgumentError(
      'Unsupported task argument type: ${value.runtimeType}. '
      'Use JSON-compatible values or Uint8List.',
    );
  }

  void dispose() {
    _nudgeTimer?.cancel();
    _nudgeTimer = null;

    _nudged = false;
  }
}

class TaskArguments {
  TaskArguments._({
    required List<dynamic> values,
    required this.task,
  }) : _values = values;

  final Tasks task;
  final List<dynamic> _values;

  static TaskArguments fromTask(Tasks task) {
    final decoded = jsonDecode(task.functionArgs);

    if (decoded is! List) {
      throw const FormatException(
        'Task functionArgs must contain a JSON array.',
      );
    }

    final values = List<dynamic>.from(decoded);

    for (var i = 0; i < values.length; i++) {
      final value = values[i];

      if (value is String && value.startsWith('__BLOB__:')) {
        final index = int.tryParse(
          value.substring('__BLOB__:'.length),
        );

        if (index == null || index < 1 || index > 5) {
          throw FormatException(
            'Invalid blob parameter marker: $value',
          );
        }

        final blob = _getBlob(task, index);

        if (blob == null) {
          throw StateError(
            'Task ${task.taskId} references blobparam$index, '
            'but the blob is missing.',
          );
        }

        values[i] = blob;
      }
    }

    return TaskArguments._(
      values: values,
      task: task,
    );
  }

  static Uint8List? _getBlob(
    Tasks task,
    int index,
  ) {
    switch (index) {
      case 1:
        return task.blobparam1;
      case 2:
        return task.blobparam2;
      case 3:
        return task.blobparam3;
      case 4:
        return task.blobparam4;
      case 5:
        return task.blobparam5;
      default:
        return null;
    }
  }

  int get length => _values.length;

  dynamic operator [](int index) => _values[index];

  T get<T>(int index) {
    final value = _values[index];

    if (value is T) {
      return value;
    }

    throw StateError(
      'Task argument $index expected $T '
      'but received ${value.runtimeType}.',
    );
  }

  T? getNullable<T>(int index) {
    final value = _values[index];

    if (value == null) {
      return null;
    }

    if (value is T) {
      return value;
    }

    throw StateError(
      'Task argument $index expected $T? '
      'but received ${value.runtimeType}.',
    );
  }

  Uint8List getBlob(int index) {
    final value = _values[index];

    if (value is Uint8List) {
      return value;
    }

    if (value is List<int>) {
      return Uint8List.fromList(value);
    }

    throw StateError(
      'Task argument $index is not a blob.',
    );
  }

  Uint8List? getNullableBlob(int index) {
    final value = _values[index];

    if (value == null) {
      return null;
    }

    if (value is Uint8List) {
      return value;
    }

    if (value is List<int>) {
      return Uint8List.fromList(value);
    }

    throw StateError(
      'Task argument $index is not a blob.',
    );
  }
}


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





