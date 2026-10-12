# `lib/engine` — Task Engine & Core Logic

The entire engine layer: a resilient, offline-first **task engine**, the
encrypted Drift database, the crypto subsystem, all network services, and the
executable business-logic functions. Task executors run on the coordinator
isolate (see below); genuinely CPU-heavy helpers offload to `compute()`.

## Top-level files

| File | Purpose |
|---|---|
| `engine.dart` | `TaskEngine` — the public handle (`start`, `ping`, `updateNetworkState`, `dispose`). The coordinator claims tasks and runs their executors on the coordinator isolate (up to 3 in flight, with a 2-second slow threshold), reaps results, retries failures up to 10,000 times, and gatekeeps network tasks on connectivity. Executors run on the coordinator isolate so they can reach plugins (secure storage, shared preferences, dotenv) and write through the same Drift connection the UI watches, keeping Drift stream queries live. Genuinely CPU-heavy helpers (e.g. image compression) are offloaded with `compute()`. Starts with crash recovery: any tasks stuck in "in-progress" from a previous run are returned to the pending pool. |
| `task_queue.dart` | `TaskQueue` — **enqueue-only**. Validates arguments, JSON-serializes them, splits `Uint8List` parameters into up to 5 blob columns, stamps the row with the `TaskKind` (network or non-network) from the function registry, and pings the engine. |
| `functions_list.dart` | `FunctionsList` — the **public typed façade** exposing every engine function (login, sendChatMessage, handshake, createGroup, etc.) as static async methods. Also contains the `functionRegistry` map (consumed by the task engine) that maps string names to `TaskDefinition` objects (kind + executor). |
| `network_state.dart` | `NetworkStateManager` — listens to `connectivity_plus` on the main isolate, persists the state to SharedPreferences, and exposes a `stateChanges` stream. The engine is told about state changes via `TaskEngine.updateNetworkState()` so network tasks are frozen when offline. |

## Subfolders

| Folder | README | What lives there |
|---|---|---|
| [`crypto/`](crypto/README.md) | Three separate crypto systems: 1-to-1 E2E encryption (ratchet + DH), group encryption (shared keys + rotation), and Shamir secret sharing for password recovery. |
| [`database/`](database/README.md) | Drift schema (14 tables) + DAOs (14 query classes) + the encrypted-DB initialisation that manages the AES-256 key in secure storage. |
| [`functions/`](functions/README.md) | The 40+ task functions that run on the coordinator isolate: auth, chat send/receive/handshake, contacts/groups/networks, Shamir share custody, server CRUD. |
| [`network/`](network/README.md) | All HTTP (Dio) and SSE services: the multi-server `ApiClient` registry, unauthenticated `MainServerClient`, plus subfolders for auth, messaging, notifications, people, servers, and social-feed updates. |
| [`media_handling/`](media_handling/README.md) | Dicebear avatar generation, image compression (96×96 px WebP, ≤4 KB — run via `compute()`), media file storage, and base64 ↔ blob conversion. |
| [`securestore/`](securestore/README.md) | Wrapper around `FlutterSecureStorage` for the post-registration security token. |

## How it's wired up in `main.dart`

```dart
await dotenv.load();
MainServerClient.init();                                    // .env → Dio
final database = await DatabaseInitializer.initialize();    // encrypted DB
await TaskEngine.start(database: database);
runApp(ProviderScope(overrides: [appDatabaseProvider...], ...));
```

The `NetworkStateManager` is not yet wired to `TaskEngine.updateNetworkState()`
in `main.dart`; the engine defaults to **offline** and network tasks stay
frozen until that connection is added.

## Design notes

- **One encrypted database file, one connection.** The UI and the task engine
  share a single Drift `AppDatabase` handle, so a write made by a task is seen
  by the UI's stream queries immediately. WAL mode
  (`PRAGMA journal_mode=WAL`) and a `busy_timeout` are applied in
  `init_db.dart`; see `applyConcurrencyPragmas`.
- **Executors run on the coordinator isolate.** Tasks reach platform plugins
  and the shared Drift connection directly. Keep per-task work off the critical
  path and push anything CPU-bound behind `compute()`.
- **Retry is generous.** Failed tasks go back to the pending pool (not to the
  front of the line) and are retried up to 10,000 times before being marked
  terminally failed.
- **The protocol needs tests.** The crypto/protocol state machine is not yet
  covered by the tests it needs (see root README for details).