# `lib/engine/functions` — Task-Engine Executable Functions

Each function here is a **top-level or static** function (no closures, no bound
instance methods) because task workers run on background isolates that can only
call isolate-safe code. They are registered in `../functions_list.dart`
(the `functionRegistry` map consumed by the task engine) and execute message
payloads handed to them as a `TaskPayload`.

> A function is where local business logic runs — it mutates the database via
> the DAOs in `../database/queries/` and calls out to `../network/` for anything
> that needs HTTP.

## Subfolders

| Folder | Purpose |
|---|---|
| [`auth/`](auth/README.md) | Login and full end-to-end user registration (vault creation + server post-process + local identity row). |
| [`chats/`](chats/README.md) | Send/receive encrypted messages and the authenticated 2-phase handshake that establishes a conversation. |
| [`people/`](people/README.md) | Contacts, connection requests, vCard exchange, groups, group members, and contact networks. |
| [`security/`](security/README.md) | Dispensing/reversing Shamir recovery shares to trusted identities. |
| [`servers/`](servers/README.md) | Server row CRUD, distinct colour picking, and remote server-directory refresh. |

## How a function gets called

1. UI/business code calls `FunctionsList.<name>(...)` (the typed façade in
   `../functions_list.dart`), which forwards to the matching executor here.
2. Or, work is enqueued through `TaskQueue.queueTask(...)`; the engine's
   `getNextPendingTask()` claims it and the worker isolate runs the registered
   executor with the deserialized `TaskPayload`.

Naming convention note: a couple of files carry numbering prefixes
(`01_send_message.dart`, `22_contact.dart`) that mirror the wire-level message
type; filenames are otherwise free-form.