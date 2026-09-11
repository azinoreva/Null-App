# `lib/engine/network/auth` — Auth Network Services

Authenticated-account HTTP services. All requests go through
`ApiClient.instance(serverId)` so `Bearer` auth, 401-refresh, and retry are
handled automatically.

| File | Service | Endpoint | Purpose |
|---|---|---|---|
| `change_password.dart` | `AccountService.changePassword` | `POST /api/account/change-password` | Change the account password. Sends a client-side re-encrypted `encrypted_blob` plus current/new passwords. Returns `ChangePasswordResponse`. |
| `invitations.dart` | `InvitationService` | `GET /api/invitation_count` | How many invite slots remain (`InvitationCount.remaining` / `nextResetDate`). |
| `invite_user.dart` | `InviteUserService` | `POST /api/invite-user` | Generate a one-time invitation token for the current user (`InviteUserResponse`). |
| `login.dart` | `SignInService` | `POST /api/sign-in` (via `MainServerClient`, unauthenticated) | Sign in with phone + password. Stores the returned token pair in `ApiClient` under the main server id, making the main server usable via `ApiClient.instance(mainServerId)`. |
| `register.dart` | `UserRegistrationService` | `POST /api/create-new-user-preprocess` then `POST /api/create-new-user-postprocess` (both unauthenticated) | Two-step registration: step 1 gets an OTP sent to the phone; step 2 submits `phone_number`, `pin`, `password`, and the `encrypted_blob`, returning `user_id`, `salt_version`, `security_token`, `schema_version`, `recovery_type`, `invitation_count`. Does **not** return tokens — login happens separately. |

`login.dart` and `register.dart` are the only services that deliberately use
`MainServerClient` (no auth) because they run before tokens exist.