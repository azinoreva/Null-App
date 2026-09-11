# `lib/engine/network` — HTTP / SSE Networking Layer

All outbound HTTP is done with **Dio**. The layer is split into two client
regimes, plus a small error class, and a subfolder per feature domain.

## Core files

| File | Purpose |
|---|---|
| `api_client.dart` | `ApiClient` — a **multi-server** static registry: `registerServer(serverId, baseUrl, onAuthFailure)` produces its own Dio instance per server. The request interceptor injects a Bearer access token from secure storage; the error interceptor catches 4xx/5xx, performs a **refresh-on-401** (`POST /api/refresh`) with coalesced refreshes per server, retries the request once, and calls `onAuthFailure` if that also fails. Exposes `saveTokens`, `getAccessToken`, `getRefreshToken`, `unregisterServer`, and `handleAuthFailure`. |
| `main_server_client.dart` | `MainServerClient` — a single shared Dio instance for the **main/authority server** (`MAIN_SERVER_URL` from dotenv). Intentionally has **no auth interceptors** — it's for unauthenticated flows (sign-in, registration) that happen before any tokens exist. |
| `server_error_exception.dart` | `ServerErrorException(Exception)` — carries `message` (from the backend's `detail` field) and `statusCode`; thrown by both client regimes on 4xx/5xx. |

## Subfolders

| Folder | Purpose |
|---|---|
| [`auth/`](auth/README.md) | Login, registration (pre/post-process), password change, invitation generation and counting. |
| [`chats/`](chats/README.md) | Send/receive messages, message-ack, presence check, and SSE (server-sent events) for realtime push. |
| [`notifications/`](notifications/README.md) | Push-token registration and sending. |
| [`people/`](people/README.md) | Invite creation and acceptance. |
| [`servers/`](servers/README.md) | Server directory and the per-server credential/challenge auth flow. |
| [`updates/`](updates/README.md) | Social-feed updates, comments, and update-progress tracking. |

## How auth flows

Unauthenticated bootstrap (register / login) always goes through
`MainServerClient`. Once tokens are returned, they are stored via
`ApiClient.saveTokens` under the main-server id. Every subsequent request
through `ApiClient.instance(serverId)` is automatically authenticated with a
`Bearer` token and retried on 401.

## Relevant server endpoints (all observed)

`/api/refresh`, `/api/sign-in`, `/api/create-new-user-preprocess`,
`/api/create-new-user-postprocess`, `/api/account/change-password`,
`/api/invitation_count`, `/api/invite-user`,
`/api/account/accept-an-invite`, `/api/account/invite-contact`,
`/api/account/push-notification-token`, `/api/account/send_push_notification`,
`/api/users/credentials`, `/api/auth/challenge`, `/api/servers`,
`/api/messages`, `/api/messages/ack`, `/api/message`, `/api/presence`,
`/api/subscribe` (SSE), `/api/get_updates`, `/api/updates`,
`/api/comment_to_post`, `/api/comment_to_comment`, `/api/check_comments`,
`/api/check_update_progress`, `/api/mark_update_read`.