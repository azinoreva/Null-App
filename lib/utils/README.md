# `lib/utils` — Pure Utility Functions

| File | Purpose |
|---|---|
| `formatting.dart` | Two pure, side-effect-free helpers used across the UI:
  - `parseHexColour(String)` — parses `"0xRRGGBB"` or `"#RRGGBB"` into a `Color` (falls back to `Colors.transparent`). Used for the conversation avatar ring colour in `ChatScreen`.
  - `formatChatTime(int timestampMillis)` — formats an epoch-ms timestamp: time-of-day for today, "Yesterday", weekday name for < 7 days, else `"Jan 5"` style. Used for conversation-list time labels and chat message timestamps (via `chatMessagesProvider`). |
| `server_model.dart` | The server value types shared by every layer: `ServerType`, `MediaType` and `ServerMedia` (the backend's `Media` block). Re-exported from `lib/engine/network/servers/servers.dart`, so the API models, the persisted list and the database all agree on one set of names, types and JSON keys. |
| `server_list.dart` | `ServerConfig` — the local, persisted mirror of a server, field for field identical to the API's `Server` payload, plus `ServerListService`, the `ChangeNotifier` that keeps the list in `SharedPreferences` and notifies the SSE supervisor. |

Keep this folder free of Flutter-widget or database dependencies — it's pure
formatting/parsing and plain data models shared by screens, widgets, and state.