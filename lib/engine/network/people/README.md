# `lib/engine/network/people` — Invitations Network Services

| File | Service | Endpoint | Purpose |
|---|---|---|---|
| `create_invite.dart` | `SendContactService` | `POST /api/account/invite-contact` | Generate a one-time invite for the current user. Sends the caller's `public_key`; the server returns `user_id`, `passcode`, `deeplink`, `server_id`. The `deeplink` is shared out-of-band. |
| `accept_invite.dart` | `AcceptInviteService` | `POST /api/account/accept-an-invite` | Accept an invite (sent to you as a deeplink `.../invite/{userId}-{passcode}`). Sends `user_id` and `passcode`; the server returns the **inviter's public key** as a raw string, which the client uses to establish an encrypted channel. |

Both requests run through `ApiClient` with automatic 401-refresh and retry.