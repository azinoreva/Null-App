# `lib/engine/network/chats` — Messaging Network Services

HTTP + realtime (SSE) services for message delivery.

| File | Service | Endpoint | Purpose |
|---|---|---|---|
| `send_message.dart` | `SendMessageService` | `POST /api/message` | Deliver a message (already encrypted client-side) to one or more recipients in a conversation. |
| `pull_messages.dart` | `MessagesQueueService` | `GET /api/messages` | Fetch all queued/undelivered messages for the current user. Returns `List<QueuedMessage>` (sender_id, conversation_id, messageId, logicalId, messageType, message, messageOrder, nonce, timestamp, protocolVersion, serverId, senderSequence). Paired with ack. |
| `delete_message.dart` | `MessagesService.ackMessages` | `POST /api/messages/ack` | Acknowledge delivery of message ids (raw JSON array body) so the server can delete them. |
| `prescence_check.dart` | ⚠️ note the typo in the filename. `PresenceService` | `POST /api/presence` | Check whether one or more users are online (`Map<userId, bool>` + `isOnline()` helper). |
| `sse_connect.dart` | `SseHub` | `GET /api/subscribe` (SSE) | **Realtime push layer.** One long-lived SSE connection per server, with `Last-Event-ID` resume, exponential backoff reconnect (1s → 30s max), stream byte-buffering, and SSE line parsing (`event:`/`data:`/`id:`). Listens on `NetworkStateManager` changes and drives the handshake/message receive handlers when `"message"` events arrive. |

## Casing note

Message endpoints mix camelCase (`messageId`, `logicalId`, `senderSequence`)
and snake_case (`sender_id`, `conversation_id`) JSON keys — keep their exact
shape when calling these endpoints.