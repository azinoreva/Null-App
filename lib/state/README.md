# `lib/state` — Riverpod State Layer

Central state management for the whole app, built with Riverpod.

| File | Purpose |
|---|---|
| `providers.dart` | All app-level providers:
  - `appDatabaseProvider` — must be **overridden in `main()`** with the real `AppDatabase` (from `DatabaseInitializer.initialize()`), otherwise providers have nothing to talk to.
  - DAO providers for `SyncState`, `Messages`, `Contacts`, `Identity`, `Groups`, `GroupMembers`.
  - `syncStatesProvider` (`AsyncNotifierProvider<SyncStatesNotifier, ...>`) — mirrors the whole `sync_state` table reactively (via the DAO's `.watch*` stream). Mutators: `upsert`, `markAllRead`, `markRead`, `updateLastMessage`, `setPinned`, `setMuted`, `updateColour`, `updateDraft`, `addMentions`, `remove`.
  - `conversationSyncStateProvider` (`StreamProvider.family<SyncStateData?, String>`) — streams a single conversation's sync row.
  - `chatMessagesProvider` (`family`, keyed by `conversationId`) — builds the visible message list anchored to `sync_state.lastMessageId` (last 20 messages) and **appends only new messages** when `lastMessageId` changes (delta updates, no full reloads).
  - `currentUserIdProvider` — resolves the current user's identity id from the `Identity` table, used to tell "my" messages apart from others'.

## How the chat list / chat screen use it

- `ChatScreen` watches `syncStatesProvider` to render the conversation list.
- `Chatting` watches `chatMessagesProvider(conversationId)` for messages and
  `conversationSyncStateProvider(conversationId)` for the draft.
- Message rows are turned into `ChatMessageItem`s (from
  `lib/widgets/chats/chat_bubble_component.dart`) with sender presentation
  (group-member name or contact nickname), delivery status, and timestamps
  formatted via `lib/utils/formatting.dart`.

## Adding a new provider

Follow the existing pattern: expose the DAO through a provider, wrap any
table-wide reactive read in a notifier driven by the DAO's `.watch*` stream,
and keep widget-specific derivation in `family` providers keyed by id.