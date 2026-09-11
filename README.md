# Null App (`null_app`)

An end-to-end encrypted, offline-first messaging app for Flutter with
multi-server federation and social (Shamir) password recovery. Built with
**Drift** over an **encrypted SQLite** database, a **background-isolate task
engine**, **Riverpod** state management, and a multi-server **Dio** networking
layer. Targets Android, iOS, Web, Windows, Linux, and macOS.

> ⚠️ **Status:** This is a work in progress. The UI and the underlying
> primitives are established, but the crypto/protocol state machine needs
> serious tests — especially simultaneous sends, duplicate delivery,
> skipped-key limits, crash/rollback behaviour, recovery, and authenticated
> session setup — before you trust real messages to it. Several UI handlers
> are still stubs (see [lib/screens/README.md](lib/screens/README.md)).

---

## Table of contents

- [Architecture](#architecture)
- [Folder map](#folder-map)
- [How it comes together](#how-it-comes-together)
  - [Startup](#startup)
  - [The task engine](#the-task-engine)
  - [Sending / receiving a message](#sending--receiving-a-message)
  - [Registration & password recovery](#registration--password-recovery)
- [Tech stack](#tech-stack)
- [Database schema](#database-schema)
- [Code-generation](#code-generation)
- [Configuration](#configuration)
- [Running the app](#running-the-app)
- [Tests](#tests)
- [Known issues & TODOs](#known-issues--todos)

---

## Architecture

```
UI layer          lib/screens/  +  lib/widgets/  +  lib/utils/        (Flutter UI)
       │
       ▼ reads/writes through Riverpod
State layer       lib/state/providers.dart                            (Riverpod)
       │
       ▼ streams from the encrypted DB via DAOs
Engine layer      lib/engine/engine.dart  (TaskEngine, background isolates)
                  lib/engine/functions/   (business-logic task functions)
                  lib/engine/crypto/      (E2E encryption + Shamir vault)
                  lib/engine/network/     (Dio HTTP + SSE, multi-server)
                  lib/engine/database/    (Drift ORM over encrypted SQLite)
```

Key principle: **nothing task-related runs on the main isolate.** UI code
enqueues work; a background orchestrator isolate claims tasks, spawns worker
isolates, and writes results back to the database. The UI then reacts to the
changed data through reactive DAO streams / Riverpod.

## Folder map

Every folder has a README describing its files. Starting points:

| Path | What it is |
|---|---|
| [`lib/README.md`](lib/README.md) | The whole `lib/` source tree in one page. |
| [`lib/main.dart`](lib/main.dart) | Bootstrap: `.env`, `MainServerClient`, encrypted DB, `TaskEngine`, `ProviderScope`, root routing. |
| [`lib/engine/README.md`](lib/engine/README.md) | The task engine + core logic. |
| [`lib/engine/database/README.md`](lib/engine/database/README.md) | Encrypted DB, 14 tables, 14 DAOs. |
| [`lib/engine/crypto/README.md`](lib/engine/crypto/README.md) | 1-to-1 ratchet crypto, group crypto, Shamir vault. |
| [`lib/engine/functions/README.md`](lib/engine/functions/README.md) | The executable task functions (auth, chat, people, servers…). |
| [`lib/engine/network/README.md`](lib/engine/network/README.md) | Multi-server Dio client, SSE, and all HTTP services. |
| [`lib/screens/README.md`](lib/screens/README.md) | Screens & navigation flow. |
| [`lib/state/README.md`](lib/state/README.md) | Riverpod providers (chat list, messages, DAO access). |
| [`lib/widgets/README.md`](lib/widgets/README.md) | Theme + reusable UI components. |
| [`lib/utils/README.md`](lib/utils/README.md) | Pure formatting helpers. |
| [`assets/README.md`](assets/README.md) | Bundled images/video. |

Also present and standard Flutter platform scaffolding (not documented in
detail): [`android/`](android/), [`ios/`](ios/), [`macos/`](macos/),
[`windows/`](windows/), [`linux/`](linux/), [`web/`](web/), and generated
output under `build/` and `.dart_tool/`.

## How it comes together

### Startup

1. `main()` loads `.env` and calls `MainServerClient.init()` (configures Dio
   for the main server, see `lib/engine/network/main_server_client.dart`).
2. `DatabaseInitializer.initialize()` opens the **encrypted** database —
   an AES-256 key is generated on first install, stored in
   `FlutterSecureStorage`, and unlocked via `PRAGMA hexkey`
   (SQLCipher / SQLite3MultipleCiphers) — see `lib/engine/database/init_db.dart`.
3. `TaskEngine.start(database)` spawns the background orchestrator isolate,
   which immediately **recovers interrupted tasks** (anything marked
   in-progress from a previous run goes back to pending) and starts draining.
4. The app runs inside `ProviderScope(overrides: [appDatabaseProvider …])` so
   every provider talks to the one real database.
5. `MyApp` shows `SplashScreen` (first run only) → `DecisionScreen` →
   `ChatScreen` / `SignupScreen` / `LoginScreen`, depending on
   SharedPreferences flags (`is_launched`, `is_logged_in`, `has_signed_up`).

### The task engine

`lib/engine/engine.dart` + `lib/engine/task_queue.dart`:

- `TaskQueue.queueTask(...)` validates/serializes arguments, splits blobs
  (max 5), looks up the `TaskKind` from the function registry
  (`lib/engine/functions_list.dart`), writes the row, and **pings** the engine.
- The orchestrator isolate claims tasks with `getNextPendingTask()` — fresh
  work before retries, network tasks before non-network, and **network tasks
  are skipped entirely while offline** (`TaskEngine.updateNetworkState`).
- Each task runs on its own worker isolate (up to 3 concurrently; 2s slow
  threshold, 10s hard kill timeout). Failures go back to the pending pool and
  are retried up to 10,000 times before being marked failed.
- Every registered executor is a static function in
  `lib/engine/functions/` — the directory READMEs list them all.

### Sending / receiving a message

1. **Handshake** (`functions/chats/handshake.dart` + `recieve_handshake.dart`):
   the initiator sends a signed X25519 ephemeral public key (message type 0);
   the receiver verifies the signature against a canonical transcript, derives
   the shared secret via ECDH, and stores the session key in the `Sessions`
   table; an "ok null" confirmation (type 1) completes the exchange. See
   `lib/engine/crypto/chat/README.md`.
2. **Send** (`functions/chats/01_send_message.dart`):
   `NullCrypto.encryptMessage()` advances the sending ratchet and encrypts with
   XChaCha20-Poly1305; the payload (`chain_index`, `ciphertext`, `nonce`,
   `mac`) is POSTed to `/api/message` (`network/chats/send_message.dart`).
3. **Receive** (`functions/chats/recieve_message.dart`): the SSE hub
   (`network/chats/sse_connect.dart`) or pull (`network/chats/pull_messages.dart`)
   delivers the payload; `NullCrypto.decryptMessage()` advances the receiving
   ratchet (or uses a skipped key), and the message is stored.
4. **UI:** the `Messages`/`SyncState` tables change → `syncStatesProvider` /
   `chatMessagesProvider` (in `lib/state/providers.dart`) stream the updates →
   `ChatScreen` / `Chatting` rebuild (bubbles via `ChatBubbleComponent`).

### Registration & password recovery

- **Register** (`functions/auth/registerfxn.dart`): a random AES-256 key
  encrypts the password; the key is split with **Shamir (2-of-5)**; the vault
  is saved to secure storage (`crypto/shamirs/`); the encrypted blob goes to
  `POST /api/create-new-user-postprocess`; the identity row is written locally.
- **Recovery**: ≥2 shares (dispensed via `functions/security/share_secret.dart`
  to trusted contacts) reconstruct the key (`password_vault.dart`), which
  decrypts the password (`decryptPassword`).

## Tech stack

| Area | Choice |
|---|---|
| Framework | Flutter (Dart SDK `^3.13.0`), app `com.example.null_app` |
| Database | `drift` + `drift_dev`, encrypted via `sqlcipher_flutter_libs` (SQLite3MultipleCiphers) |
| State | `flutter_riverpod` |
| Networking | `dio` (multi-server, 401-refresh), `http`; server push via SSE (`SseHub`) |
| Crypto | `cryptography` — Ed25519, X25519, AES-256-GCM, XChaCha20-Poly1305, HKDF-SHA256, SHA-256; Shamir secret sharing (pure Dart) |
| Secure storage | `flutter_secure_storage` (DB key, vault, tokens, security token) |
| Misc | `connectivity_plus`, `path_provider`, `shared_preferences`, `uuid`, `image`, `video_player`, `dice_bear`, `flutter_dotenv`, `cupertino_icons`, `flutter_lints` |

See [`pubspec.yaml`](pubspec.yaml) for the full manifest.

## Database schema

14 tables, all defined in `lib/engine/database/tables/` (schema version 3):

`Identity` (single-row user), `Servers`, `Conversations`, `Messages`,
`Contacts`, `ContactsNetwork` + `ContactNetworkMembers`, `Groups`,
`GroupMembers`, `ConnectionRequests`, `Tasks` (the engine queue), `ShamirsSecret`,
`SecretShare`, `SyncState` (denormalized conversation-list mirror).

See [`lib/engine/database/tables/README.md`](lib/engine/database/tables/README.md)
for columns and the foreign-key graph, and
[`lib/engine/database/queries/README.md`](lib/engine/database/queries/README.md)
for the DAOs that back every read/write.

## Code-generation

Drift requires code generation. After editing any table or DAO:

```sh
dart run build_runner build
```

Never hand-edit the generated `.g.dart` files (`app_database.g.dart`,
`*_queries.g.dart`).

## Configuration

- `.env` (bundled asset) — currently `MAIN_SERVER_URL=http://127.0.0.1:8000`,
  loaded by `flutter_dotenv` and consumed by `MainServerClient.init()`.
- Images/video are declared under `flutter: assets:` in `pubspec.yaml`.

## Running the app

```sh
flutter pub get
dart run build_runner build   # after pulling / editing schema
flutter run
```

Pick a device/target with `flutter run -d <device>` (Android, iOS, Web,
Windows, Linux, macOS are all configured).

## Tests

Only one widget test exists (`test/widget_test.dart` — asserts the signup
screen shows for a new user). Run with `flutter test`.

## Known issues & TODOs

- **Protocol not yet test-covered** — simultaneous sends, duplicate delivery,
  skipped-key limits, crash/rollback, recovery, authenticated session setup
  all need tests before real-message trust.
- **UI stubs:** login, biometrics, forgot-password, sending messages
  (`onSendMessage` is a no-op), adding contacts, profile save/block/mute/ping,
  contact-menu actions. `lib/screens/settings_screen.dart` is an empty
  placeholder. `lib/screens/sync_state/` is an empty placeholder directory.
- **Wiring gap:** `NetworkStateManager` is not yet connected to
  `TaskEngine.updateNetworkState()` in `main.dart`, so the engine currently
  stays offline for network tasks.
- **Known oddities / duplicates:** `handshake_registry.dart.dart` (double
  extension); `prescence_check.dart` (typo); duplicate model/class definitions
  in `network/notifications/send_notifications.dart` and the broken/stale
  `network/servers/server_credentials.dart`; an alternate ratchet store
  `crypto/chat/conversation_key_store.dart`. These are kept for now — see the
  individual folder READMEs.