// app_queue.dart
//
// App-wide handle on the running TaskQueue, set once at startup (main.dart).
// Engine-side functions that already live inside a queued task (and so have
// no TaskQueue of their own) use this to enqueue follow-up work — e.g. the
// DH-drop flow queues the first "hi" message through it.

import 'task_queue.dart';

/// Set right after [TaskQueue] construction in main(). Null until then, or
/// on a fresh engine task raced against startup.
TaskQueue? appTaskQueueRef;