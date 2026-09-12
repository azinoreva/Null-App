// task_queue.dart
//
// This is now enqueue-only. Execution moved to task_engine.dart's
// TaskEngine, which runs entirely off the main isolate -- the old
// nudge()/_process() loop that used to live here is gone, since having
// two separate things pulling from the same "pending" pool would race.
//
// TaskQueue's one job: validate + serialize arguments, figure out whether
// this task is network or non-network (from functions_list.dart, NOT a
// caller-supplied param -- see the file header in task_engine.dart), write
// the row, and ping the engine so it notices.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart';

import 'database/app_database.dart';
import 'database/queries/tasks_queries.dart';
import 'functions_list.dart' as functions;
import 'engine.dart';

class TaskQueue {
  TaskQueue({
    required this.database,
    required this.engine,
  });

  final AppDatabase database;
  final TaskEngine engine;

  Future<String> queueTask({
    required String functionName,
    required List<dynamic> args,
    String? serverId,
    String? taskData,
  }) async {
    final definition = functions.functionRegistry[functionName];
    if (definition == null) {
      throw ArgumentError(
        'No executor registered for "$functionName" in functions_list.dart.',
      );
    }

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
        taskType: definition.kind, // TaskKind.network / TaskKind.nonNetwork
        taskStatus: Value(TaskStatus.pending),
        functionName: functionName,
        functionArgs: Value(jsonEncode(encodedArguments)),
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

    engine.ping();
    return taskId;
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
}