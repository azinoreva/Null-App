import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart';

import 'app_database.dart';
import 'tasks.dart';

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

  bool get isRunning => _running;

  Future<String> queueTask({
    required String functionName,
    required List<dynamic> args,
    int taskType = 0,
    String? serverId,
    String? taskData,
  }) async {
    final taskId = 'task_${DateTime.now().microsecondsSinceEpoch}';
    final now = DateTime.now().millisecondsSinceEpoch;

    final encodedArguments = <dynamic>[];
    final blobs = <Uint8List?>[null, null, null, null, null];

    var blobIndex = 0;

    for (final argument in args) {
      if (argument is Uint8List || argument is List<int>) {
        blobIndex++;
        if (blobIndex > 5) {
          throw ArgumentError('A task can contain at most 5 blob parameters.');
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

    _scheduleNudge();
    return taskId;
  }

  void nudge() {
    _nudged = true;
    if (!_running) {
      unawaited(_process());
    }
  }

  Future<void> start() async {
    await _recoverInterruptedTasks();
    nudge();
  }

  void _scheduleNudge() {
    _nudgeTimer?.cancel();
    _nudgeTimer = Timer(
      const Duration(milliseconds: 500),
      nudge,
    );
  }

  Future<void> _process() async {
    if (_running) return;

    _running = true;

    try {
      do {
        _nudged = false;
        await _processPendingTasks();

        if (await _hasPendingTasks()) {
          _nudged = true;
        }
      } while (_nudged);
    } finally {
      _running = false;
      if (_nudged) {
        unawaited(_process());
      }
    }
  }

  Future<void> _processPendingTasks() async {
    while (true) {
      final task = await _claimNextTask();
      if (task == null) return;
      await _executeTask(task);
    }
  }

  Future<Tasks?> _claimNextTask() async {
    final task = await database.tasksDao.getNextPendingTask();
    if (task == null) return null;

    final claimed = await database.tasksDao.claimTask(task.taskId);
    if (!claimed) return null;

    return database.tasksDao.getTaskById(task.taskId);
  }

  Future<void> _executeTask(Tasks task) async {
    final executor = _executors[task.functionName];

    if (executor == null) {
      await database.tasksDao.markTaskFailed(
        task.taskId,
        'No executor registered for "${task.functionName}".',
      );
      return;
    }

    try {
      final args = TaskArguments.fromTask(task);
      await executor(task, args);
      await database.tasksDao.markTaskCompleted(task.taskId);
    } catch (error, stackTrace) {
      await database.tasksDao.markTaskFailed(
        task.taskId,
        '$error\n$stackTrace',
      );
    }
  }

  Future<bool> _hasPendingTasks() async {
    return await database.tasksDao.getNextPendingTask() != null;
  }

  Future<void> _recoverInterruptedTasks() async {
    final tasks = await database.tasksDao.getTasksByStatus(
      TaskStatus.inProgress,
    );

    for (final task in tasks) {
      await database.tasksDao.updateTaskCompanion(
        task.taskId,
        const TasksCompanion(
          taskStatus: Value(TaskStatus.pending),
        ),
      );
    }
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
          throw ArgumentError('Task map keys must be strings.');
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
        final index = int.tryParse(value.substring(9));

        if (index == null || index < 1 || index > 5) {
          throw FormatException('Invalid blob parameter marker: $value');
        }

        final blob = _getBlob(task, index);

        if (blob == null) {
          throw StateError(
            'Task ${task.taskId} references blobparam$index, but the blob is missing.',
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

  static Uint8List? _getBlob(Tasks task, int index) {
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
    }
    return null;
  }

  int get length => _values.length;

  dynamic operator [](int index) => _values[index];

  T get<T>(int index) {
    final value = _values[index];
    if (value is T) return value;

    throw StateError(
      'Task argument $index expected $T but received ${value.runtimeType}.',
    );
  }

  T? getNullable<T>(int index) {
    final value = _values[index];
    if (value == null) return null;
    if (value is T) return value;

    throw StateError(
      'Task argument $index expected $T? but received ${value.runtimeType}.',
    );
  }

  Uint8List getBlob(int index) {
    final value = _values[index];

    if (value is Uint8List) return value;
    if (value is List<int>) return Uint8List.fromList(value);

    throw StateError('Task argument $index is not a blob.');
  }

  Uint8List? getNullableBlob(int index) {
    final value = _values[index];

    if (value == null) return null;
    if (value is Uint8List) return value;
    if (value is List<int>) return Uint8List.fromList(value);

    throw StateError('Task argument $index is not a blob.');
  }
}
