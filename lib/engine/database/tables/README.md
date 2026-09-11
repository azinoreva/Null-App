# `lib/engine/database/tables` — Drift Table Definitions

One file per SQLite table (plus `networks.dart`, which defines two tables).
These are the source of truth for the schema, consumed by
`../app_database.dart` via the `@DriftDatabase` annotation. Timestamps are
Unix epoch **milliseconds**, stored as integers.

> The generated companion/data classes live in `app_database.g.dart` after
> running `dart run build_runner build`.

## Tables

| File | Table(s) | What it models |
|---|---|---|
| `identity.dart` | `Identity` | The current user — a **single row**. Profile (displayName, avatar, bio), `phoneNumber`, `publicKey`, and security/sync settings (`saltVersion`, `shamirNumber`, `passportVersion`, `autoSync`, `allowConnectReq`, `recoveryType`, `invitationCount`). |
| `servers.dart` | `Servers` | Messaging servers the user can connect to: `serverUrl`, `mediaUrl`, media limits (`mediaSizeLimit`, `mediaTimer`, `totalMediaSent`, `mediaLastReset`), `maxPayload`, `capabilities` bitmask, and a display `colour`. |
| `conversations.dart` | `Conversations` | Chat-list entries per conversation: type, `lastMessageId`/`lastMessageTime`, `unreadCount`, notification prefs (`muted`, `pinned`, `archived`, `sound`, `badge`, `vibration`), and `draft`. |
| `messages.dart` | `Messages` | Messages with E2E metadata: `ciphertext`/`nonce`/`mac`, `chainIndex`, `keyVersion`, ordering (`senderSequence`, `messageOrder`), delivery/read state, `decryptedMessage`, `replyTo`, `edited`. |
| `contacts.dart` | `Contacts` | The user's contacts: nickname, `avatar` (BLOB), `bio`, `publicKey`, `isOnline`, `lastSeen`, `connectionStatus`, `serverId`/`mainServerId`, notification prefs, and the linked `conversationId`. |
| `networks.dart` | `ContactsNetwork` + `ContactNetworkMembers` | User-defined lists of contacts ("networks") and the many-to-many junction table linking contacts to networks. |
| `groups.dart` | `Groups` | Group chat metadata: `ownerId`, `groupName`, `groupType` (0 private / 1 public), `avatar`, plus the current/pending symmetric keys and `swapTime` for scheduled key rotation, and `isOwner`. |
| `group_members.dart` | `GroupMembers` | Membership linking `groupId` ↔ `identityId` (composite PK), with group-specific `publicKey`, `bio`, `avatar`, `name`, `joinedAt`. |
| `connection_requests.dart` | `ConnectionRequests` | Friend/connection requests: requester/recipient/group, `introduction`, status lifecycle (0 pending / 1 accepted / 2 rejected), timestamps, `expiresAt`. |
| `tasks.dart` | `Tasks` | The background task-engine queue (the DB is the source of truth): `functionName`, JSON `functionArgs`, up to 5 `blobparamN` columns, status/retry/error fields, server binding, and 4 `syncedTo*` flags. |
| `shamirs_secret.dart` | `ShamirsSecret` | Shamir recovery material per recipient identity: the `secretShare`, encrypted `passwordBlob`, and optional encrypted `settingsPayload`. |
| `secret_share.dart` | `SecretShare` | Bookkeeping for what has been shared to each identity: last-shared timestamp plus password/settings **version numbers**. |
| `sync_state.dart` | `SyncState` | Lightweight, denormalized per-conversation UI state (the "conversation list" mirror): `displayName`, `avatar`, `status`, `unreadCount`, last-message preview, `draft`, `pinned`/`pinnedPosition`, `colour`, `muted`, `mentions`. |

## Foreign-key graph (mostly CASCADE)

- `Contacts → Conversations`, `Messages / Sessions → Conversations`,
  `GroupMembers → Groups / Identity`, `ConnectionRequests → Identity / Groups`,
  `SecretShare / ShamirsSecret → Identity`,
  `ContactNetworkMembers → ContactsNetwork / Contacts`.
- Two `SET NULL` links, by design: `Contacts.conversationId` and
  `Tasks.serverId`.

## Note

Dart-reserved words are stored under alternate column names:
`ConnectionRequests.status → _status`, `Messages.timestamp → _timestamp`,
`Messages.status → _status`, `GroupMembers.name → _name`,
`Tasks.retryCount → retrys`. Always use the DAO/companion fields rather than
raw column names wherever possible.