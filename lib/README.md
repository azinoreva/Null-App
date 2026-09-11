# `lib` — Application Source

The Dart/Flutter source tree for **Null App**, an end-to-end encrypted,
offline-first messaging client with multi-server support and social password
recovery.

## Layout overview

| Path | README | Contents |
|---|---|---|
| `main.dart` | — | App bootstrap: loads `.env`, initializes the `MainServerClient`, opens the encrypted database, starts the `TaskEngine`, and runs the app inside a `ProviderScope` with `appDatabaseProvider` overridden. Also defines `MyApp` plus the post-splash `DecisionScreen` (routes to Chat / Signup / Login based on SharedPreferences flags). |
| `engine/` | [engine/README.md](engine/README.md) | The whole engine layer: background-isolate task engine (`engine.dart`, `task_queue.dart`, `functions_list.dart`, `network_state.dart`) plus the crypto, database, functions, network, image-handling, and secure-store subfolders. |
| `screens/` | [screens/README.md](screens/README.md) | The user-facing screens (splash, login, signup, chat list, chat detail, contacts) and their modals. |
| `state/` | [state/README.md](state/README.md) | Central Riverpod providers — chat sync state, message lists, and DAO providers. |
| `widgets/` | [widgets/README.md](widgets/README.md) | Reusable UI components: theme, buttons, chat bubbles + composer, display cards, navigation shell, and inputs. |
| `utils/` | [utils/README.md](utils/README.md) | Pure helpers (colour parsing, chat-time formatting). |

## The big picture

```
main.dart
 ├─ starts NetworkStateManager (planned), MainServerClient, encrypted DB, TaskEngine
 ├─ ProviderScope overrides appDatabaseProvider
 └─ MyApp → SplashScreen → DecisionScreen → ChatScreen | SignupScreen | LoginScreen

UI (screens)  →  reads/writes via Riverpod (state/providers.dart) and DAOs
                 (engine/database/queries/)
Engine         →  TaskQueue.enqueue + TaskEngine worker isolates run functions/
                 (auth, chat, people, servers...)
Crypto         →  engine/crypto/  (1-1 ratchet, group keys, shamir vault)
Network        →  engine/network/ (ApiClient multi-server Dio + SSE)
Persistence    →  engine/database/ (encrypted SQLite via SQLCipher, Drift ORM)
```

## Data-flow example: a sent chat message

1. User taps send in `Chatting` → `ChatInput.onSendMessage(...)`.
2. (currently stubbed — the intended path) work is enqueued via `TaskQueue`,
   `engine.dart` claims it on the worker isolate, and
   `functions/chats/01_send_message.dart` runs.
3. `NullCrypto.encryptMessage()` advances the sending ratchet and encrypts.
4. `SendMessageService` (`network/chats/send_message.dart`) POSTs to
   `/api/message`. Results update `Messages` and `SyncState` tables, which the
   Riverpod providers stream back into the UI.

## Conventions

- **Never touch raw SQL.** Use the DAOs in `engine/database/queries/`.
- **Never run heavy work on the main isolate.** That's what the task engine is for.
- **Never edit `.g.dart` files.** Regenerate with `dart run build_runner build`.
- **Don't hard-code secrets.** Env/config lives in `.env` (loaded by
  `flutter_dotenv`); keys and tokens live in `FlutterSecureStorage`.