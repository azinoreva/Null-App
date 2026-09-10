// task_engine.dart
//
// The whole point of this file: nothing task-related runs on the main
// isolate. `TaskEngine` (bottom half of this file, "public" side) is a
// lightweight handle you can call from anywhere in the app. Everything
// below the `EVERYTHING BELOW RUNS INSIDE THE ENGINE ISOLATE` marker
// executes on a background isolate that this file spawns for you.
//
// ---------------------------------------------------------------------
// Wiring it up
// ---------------------------------------------------------------------
//   final engine = await TaskEngine.start(dbPath: pathToYourSqliteFile);
//
//   // any time new work might exist (after inserting a task, on app
//   // resume, on connectivity regained, etc.) just call:
//   engine.ping();
//
//   // on app shutdown:
//   engine.dispose();
//
// ---------------------------------------------------------------------
// Contract expected from functions_list.dart
// ---------------------------------------------------------------------
// Each task-executing worker isolate is a fresh isolate, so it can only
// call TOP-LEVEL or STATIC functions -- no closures, no instance methods
// bound to some object that only exists on the main isolate. Your
// functions_list.dart should expose something like:
//
//   typedef IsolateTaskExecutor = Future<void> Function(TaskPayload payload);
//
//   final Map<String, IsolateTaskExecutor> functionRegistry = {
//     'sendMessage': _sendMessage,
//     'uploadFile': _uploadFile,
//     // ...
//   };
//
//   Future<void> _sendMessage(TaskPayload p) async {
//     final to = p.get<String>(0);
//     final body = p.get<String>(1);
//     ...
//   }
//
// `TaskPayload` (defined below) is the isolate-safe replacement for the
// old `TaskArguments` -- same `get<T>()` / `getBlob()` idea, just without
// a dependency on the drift row type, since that has to cross an isolate
// boundary as plain data.
//
// ---------------------------------------------------------------------
// A couple of things worth double-checking against your actual project
// ---------------------------------------------------------------------
// 1. Row type name: your tasks_queries.dart DAO methods return `Task?`,
//    but task_queue.dart's TaskExecutor typedef used `Tasks`. Drift only
//    generates one or the other depending on your build setup -- fix the
//    type name below to whatever your generated code actually calls it.
// 2. `AppDatabase(NativeDatabase(File(dbPath)))` below is a placeholder.
//    Swap it for however your app really constructs AppDatabase, as long
//    as it points at the same sqlite file the main isolate uses.
// 3. Two isolates writing to the same sqlite file benefits a lot from
//    WAL mode (`PRAGMA journal_mode=WAL`) -- turn it on wherever you
//    open the DB, or you'll see more `SQLITE_BUSY` contention than you'd
//    like under load.
// 4. The "max 3 isolates" cap below counts concurrently-*executing task*
//    isolates, not the engine isolate itself (which is just an
//    orchestrator, mostly idle/awaiting). Bump kMaxConcurrentIsolates if
//    you intended the engine isolate to count toward that budget.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'database/app_database.dart';
import 'database/queries/tasks_queries.dart';
import 'functions_list.dart' as functions;

const int kMaxConcurrentIsolates = 3;
const Duration kSlowTaskThreshold = Duration(seconds: 2);
const Duration kHardIsolateTimeout = Duration(seconds: 10);
const int kMaxRetries = 10000;

/// What an executor function in functions_list.dart actually receives.
/// Deliberately plain data -- no drift row objects, no closures -- since
/// it has to be sent across an isolate boundary.
class TaskPayload {
  const TaskPayload({
    required this.taskId,
    required this.functionArgs,
    required this.blobs,
    this.taskData,
  });

  final String taskId;
  final List<dynamic> functionArgs;
  final List<Uint8List?> blobs;
  final String? taskData;

  dynamic operator [](int index) => functionArgs[index];

  T get<T>(int index) {
    final value = functionArgs[index];
    if (value is T) return value;
    throw StateError(
      'Task argument $index expected $T but received ${value.runtimeType}.',
    );
  }

  T? getNullable<T>(int index) {
    final value = functionArgs[index];
    if (value == null) return null;
    if (value is T) return value;
    throw StateError(
      'Task argument $index expected $T? but received ${value.runtimeType}.',
    );
  }

  /// index here is 0-based (0 -> blobparam1, 1 -> blobparam2, ...).
  Uint8List blob(int index) {
    final value = blobs[index];
    if (value == null) {
      throw StateError('blobparam${index + 1} is null for task $taskId.');
    }
    return value;
  }

  Uint8List? getNullableBlob(int index) => blobs[index];
}

/// -----------------------------------------------------------------------
/// PUBLIC SIDE -- safe to hold onto and call from the main isolate.
/// -----------------------------------------------------------------------
class TaskEngine {
  TaskEngine._(this._toEngine, this._isolate);

  final SendPort _toEngine;
  final Isolate _isolate;

  /// Spawns the engine isolate, waits for it to come up, does an initial
  /// crash-recovery + ping so anything left undone from a previous run
  /// gets picked up immediately.
  static Future<TaskEngine> start({required String dbPath}) async {
    final readyPort = ReceivePort();

    final isolate = await Isolate.spawn(
      _engineEntryPoint,
      _EngineInit(readyPort.sendPort, dbPath),
      debugName: 'task_engine',
    );

    final toEngine = await readyPort.first as SendPort;
    readyPort.close();

    final engine = TaskEngine._(toEngine, isolate);
    engine.ping();
    return engine;
  }

  /// This is "the trigger". Call it any time new or incomplete work might
  /// be waiting. Cheap to call repeatedly -- pings that arrive while the
  /// engine is mid-run just get coalesced into "check again once done",
  /// they don't stack up or start parallel drains.
  void ping() => _toEngine.send(const _Ping());

  void dispose() {
    _toEngine.send(const _Shutdown());
    _isolate.kill(priority: Isolate.immediate);
  }
}

class _EngineInit {
  const _EngineInit(this.readyPort, this.dbPath);
  final SendPort readyPort;
  final String dbPath;
}

class _Ping {
  const _Ping();
}

class _Shutdown {
  const _Shutdown();
}

/// -----------------------------------------------------------------------
/// EVERYTHING BELOW RUNS INSIDE THE ENGINE ISOLATE.
/// -----------------------------------------------------------------------

void _engineEntryPoint(_EngineInit init) {
  final controlPort = ReceivePort();
  final worker = _EngineWorker(dbPath: init.dbPath);

  init.readyPort.send(controlPort.sendPort);

  controlPort.listen((message) {
    if (message is _Ping) {
      worker.ping();
    } else if (message is _Shutdown) {
      controlPort.close();
      worker.dispose();
    }
  });
}

class _EngineWorker {
  _EngineWorker({required String dbPath})
      : database = AppDatabase(NativeDatabase(File(dbPath))) {
    // Anything left "inProgress" from a previous run (crash, force-quit,
    // etc.) couldn't possibly still be running -- put it back in the
    // pending pool before we do anything else.
    _recoverInterruptedTasks().then((_) => ping());
  }

  final AppDatabase database;

  bool _processing = false;
  bool _pingedAgain = false;

  void ping() {
    if (_processing) {
      _pingedAgain = true;
      return;
    }
    unawaited(_run());
  }

  Future<void> _run() async {
    _processing = true;
    try {
      do {
        _pingedAgain = false;
        await _drainQueue();
      } while (_pingedAgain);
    } finally {
      _processing = false;
    }
  }

  Future<void> _recoverInterruptedTasks() async {
    final stuck = await database.tasksDao.getTasksByStatus(TaskStatus.inProgress);
    for (final task in stuck) {
      await database.tasksDao.updateTaskCompanion(
        task.taskId,
        const TasksCompanion(taskStatus: Value(TaskStatus.pending)),
      );
    }
  }

  /// The core loop. Runs tasks essentially one at a time -- but if a task
  /// is still going after kSlowTaskThreshold, the loop moves on and starts
  /// the next one concurrently in its own isolate (up to
  /// kMaxConcurrentIsolates at once). Anything that's still running after
  /// kHardIsolateTimeout gets killed and sent to retry.
  Future<void> _drainQueue() async {
    final active = <_RunningWorker>[];

    while (true) {
      await _reap(active);
      await _enforceHardTimeout(active);

      if (active.length < kMaxConcurrentIsolates) {
        final claim = await _claimNextTask();

        if (claim != null) {
          final worker = _spawnWorker(claim);
          active.add(worker);

          // Wait up to kSlowTaskThreshold to see if it finishes quickly.
          // If it does, we loop straight back around and claim the next
          // task sequentially -- no extra isolate churn for the common,
          // fast case. If it doesn't, we loop back anyway, but now with
          // room to spawn another isolate for the next task in parallel.
          await Future.any([
            worker.completer.future,
            Future<void>.delayed(kSlowTaskThreshold),
          ]);
          continue;
        }
      }

      if (active.isEmpty) return; // queue is empty and nothing in flight

      // Pool is full, or there was nothing fresh to claim: wait for a
      // worker to finish, or wake up periodically to re-check the hard
      // timeout on anything still running.
      await Future.any([
        ...active.map((w) => w.completer.future),
        Future<void>.delayed(const Duration(seconds: 1)),
      ]);
    }
  }

  Future<_TaskClaim?> _claimNextTask() async {
    // getNextPendingTask() orders fresh work (retrys = 0) ahead of any
    // retries, and only returns a retry when no fresh task exists -- see
    // tasks_queries.dart. That ordering is what enforces "retries always
    // go to the back of the queue".
    final row = await database.tasksDao.getNextPendingTask();
    if (row == null) return null;

    final claimed = await database.tasksDao.claimTask(row.taskId);
    if (!claimed) return null; // lost a race, someone else claimed it

    return _TaskClaim(
      taskId: row.taskId,
      functionName: row.functionName,
      functionArgsJson: row.functionArgs,
      taskData: row.taskData,
      blobs: [
        row.blobparam1,
        row.blobparam2,
        row.blobparam3,
        row.blobparam4,
        row.blobparam5,
      ],
    );
  }

  _RunningWorker _spawnWorker(_TaskClaim task) {
    final completer = Completer<_WorkerResult>();
    final replyPort = ReceivePort();
    final errorPort = ReceivePort();

    final handle = _RunningWorker(
      taskId: task.taskId,
      startedAt: DateTime.now(),
      completer: completer,
    );

    void finish(_WorkerResult result) {
      if (!completer.isCompleted) completer.complete(result);
      replyPort.close();
      errorPort.close();
    }

    replyPort.listen((message) {
      if (message is _WorkerResult) finish(message);
    });

    // Isolate.spawn's onError port delivers [errorMessage, stackTrace],
    // not a _WorkerResult -- an uncaught error escaping the isolate
    // entirely (rather than being caught by the try/catch in
    // _workerEntryPoint) still needs to count as a failure.
    errorPort.listen((error) {
      final description = error is List ? error.join('\n') : error.toString();
      finish(_WorkerResult.failure(task.taskId, description));
    });

    Isolate.spawn(
      _workerEntryPoint,
      _WorkerRequest(
        taskId: task.taskId,
        functionName: task.functionName,
        functionArgsJson: task.functionArgsJson,
        blobs: task.blobs,
        taskData: task.taskData,
        replyPort: replyPort.sendPort,
      ),
      onError: errorPort.sendPort,
      debugName: 'task_${task.taskId}',
    ).then((isolate) => handle.isolate = isolate);

    return handle;
  }

  Future<void> _reap(List<_RunningWorker> active) async {
    final finished = active.where((w) => w.completer.isCompleted).toList();
    for (final w in finished) {
      active.remove(w);
      w.isolate?.kill();
      final result = await w.completer.future;
      await _applyResult(w, result);
    }
  }

  Future<void> _enforceHardTimeout(List<_RunningWorker> active) async {
    final now = DateTime.now();
    for (final w in List<_RunningWorker>.from(active)) {
      if (w.completer.isCompleted) continue;
      if (now.difference(w.startedAt) < kHardIsolateTimeout) continue;

      w.isolate?.kill(priority: Isolate.immediate);
      final result = _WorkerResult.failure(
        w.taskId,
        'Task exceeded the ${kHardIsolateTimeout.inSeconds}s hard limit and was terminated.',
      );
      if (!w.completer.isCompleted) w.completer.complete(result);

      active.remove(w);
      await _applyResult(w, result);
    }
  }

  Future<void> _applyResult(_RunningWorker worker, _WorkerResult result) async {
    if (result.success) {
      await database.tasksDao.markTaskCompleted(worker.taskId);
      return;
    }

    final newRetryCount = await database.tasksDao.incrementRetryCount(worker.taskId);

    if (newRetryCount >= kMaxRetries) {
      await database.tasksDao.markTaskFailed(
        worker.taskId,
        result.error ?? 'Unknown error after $newRetryCount retries.',
      );
    } else {
      // Back to pending, not straight back to the front of the line --
      // getNextPendingTask()'s ordering handles keeping this behind any
      // fresh (retrys = 0) task.
      await database.tasksDao.requeueForRetry(
        worker.taskId,
        result.error ?? 'Unknown error.',
      );
    }
  }

  void dispose() {
    database.close();
  }
}

class _TaskClaim {
  const _TaskClaim({
    required this.taskId,
    required this.functionName,
    required this.functionArgsJson,
    required this.blobs,
    required this.taskData,
  });

  final String taskId;
  final String functionName;
  final String functionArgsJson;
  final List<Uint8List?> blobs;
  final String? taskData;
}

class _RunningWorker {
  _RunningWorker({
    required this.taskId,
    required this.startedAt,
    required this.completer,
  });

  final String taskId;
  final DateTime startedAt;
  final Completer<_WorkerResult> completer;
  Isolate? isolate;
}

class _WorkerRequest {
  const _WorkerRequest({
    required this.taskId,
    required this.functionName,
    required this.functionArgsJson,
    required this.blobs,
    required this.taskData,
    required this.replyPort,
  });

  final String taskId;
  final String functionName;
  final String functionArgsJson;
  final List<Uint8List?> blobs;
  final String? taskData;
  final SendPort replyPort;
}

class _WorkerResult {
  const _WorkerResult._(this.taskId, this.success, this.error);

  factory _WorkerResult.success(String taskId) => _WorkerResult._(taskId, true, null);

  factory _WorkerResult.failure(String taskId, String error) =>
      _WorkerResult._(taskId, false, error);

  final String taskId;
  final bool success;
  final String? error;
}

/// Entry point for each individual task's isolate. Pure compute -- it
/// never touches the database. It just runs the registered function and
/// reports success/failure back to the engine isolate.
void _workerEntryPoint(_WorkerRequest req) async {
  try {
    final executor = functions.functionRegistry[req.functionName];

    if (executor == null) {
      req.replyPort.send(_WorkerResult.failure(
        req.taskId,
        'No executor registered for "${req.functionName}".',
      ));
      return;
    }

    final decodedArgs = jsonDecode(req.functionArgsJson) as List<dynamic>;

    final payload = TaskPayload(
      taskId: req.taskId,
      functionArgs: decodedArgs,
      blobs: req.blobs,
      taskData: req.taskData,
    );

    await executor(payload);
    req.replyPort.send(_WorkerResult.success(req.taskId));
  } catch (error, stackTrace) {
    req.replyPort.send(_WorkerResult.failure(req.taskId, '$error\n$stackTrace'));
  }
}