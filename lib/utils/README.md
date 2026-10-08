# `lib/utils` — Pure Utility Functions

| File | Purpose |
|---|---|
| `formatting.dart` | Two pure, side-effect-free helpers used across the UI:
  - `parseHexColour(String)` — parses `"0xRRGGBB"` or `"#RRGGBB"` into a `Color` (falls back to `Colors.transparent`). Used for the conversation avatar ring colour in `ChatScreen`.
  - `formatChatTime(int timestampMillis)` — formats an epoch-ms timestamp: time-of-day for today, "Yesterday", weekday name for < 7 days, else `"Jan 5"` style. Used for conversation-list time labels and chat message timestamps (via `chatMessagesProvider`). |
| `server_model.dart` | The server value types shared by every layer: `ServerType`, `MediaType` and `ServerMedia` (the backend's `Media` block). Re-exported from `lib/engine/network/servers/servers.dart`, so the API models, the persisted list and the database all agree on one set of names, types and JSON keys. |
| `server_list.dart` | `ServerConfig` — the local, persisted mirror of a server, field for field identical to the API's `Server` payload, plus `ServerListService`, the `ChangeNotifier` that keeps **two** `SharedPreferences` lists side by side and notifies the SSE supervisor: the normal list (`server_list`, capped at `ServerListService.maxServers` = 8 — the only one `ServerConnectionService` opens websockets for) and the extra list (`extra_server_list`, joinable once the normal list is full). An extra server is a full peer —
  same directory entry, `ApiClient` registration and passport exchange — it
  just never gets a websocket, which is why the updates feed (plain HTTP)
  polls normal + extra while `ServerConnectionService` stays on the normal
  list (`UpdatesNotifier._serverIds`). Static helpers: `readServerIds()` (the normal list's ids, what contact-sharing flows read out of prefs) and `primaryServerIdFor(servers)` (contact's first server → local normal list → built-in main server id). |

Keep this folder free of Flutter-widget or database dependencies — it's pure
formatting/parsing and plain data models shared by screens, widgets, and state.