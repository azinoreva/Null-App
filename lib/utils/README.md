# `lib/utils` — Pure Utility Functions

| File | Purpose |
|---|---|
| `formatting.dart` | Two pure, side-effect-free helpers used across the UI:
  - `parseHexColour(String)` — parses `"0xRRGGBB"` or `"#RRGGBB"` into a `Color` (falls back to `Colors.transparent`). Used for the conversation avatar ring colour in `ChatScreen`.
  - `formatChatTime(int timestampMillis)` — formats an epoch-ms timestamp: time-of-day for today, "Yesterday", weekday name for < 7 days, else `"Jan 5"` style. Used for conversation-list time labels and chat message timestamps (via `chatMessagesProvider`). |

Keep this folder free of Flutter-widget or database dependencies — it's pure
formatting/parsing shared by screens, widgets, and state.