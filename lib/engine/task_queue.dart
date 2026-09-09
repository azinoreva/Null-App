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

