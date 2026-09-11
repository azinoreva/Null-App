# `lib/screens/sync_state` — Sync-State UI (placeholder)

This directory is currently **empty**. It exists as a placeholder for the
planned "Sync State" screen section mentioned in the root README — the intended
home for functions/UI that render and control the `SyncState` table content
(conversation list state, last-read/last-message markers, unread counts,
drafts, pins, colours, mentions).

Streaming providers for that data already exist in `lib/state/providers.dart`
(`syncStatesProvider`, `conversationSyncStateProvider`), so the future UI here
should consume those rather than querying the DAO directly.