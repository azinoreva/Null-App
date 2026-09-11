# `lib/engine/network/servers` — Server-Directory & Multi-Server Auth

Two concerns: fetching the directory of servers you can connect to, and the
per-server authentication challenge that the `ApiClient` interplay handles.

| File | Service | Endpoint | Purpose |
|---|---|---|---|
| `servers.dart` | `ServerDirectoryService` | `GET /api/servers` (via main-server `ApiClient`) | Fetch `List<ServerInfo>` (serverId, name, url, media fields, capabilities, maxPayload). `discoverAndRegisterServers(...)` goes further: it fetches the list, then calls `ApiClient.registerServer` for each — but tokens are not obtained yet (credentials exchange is still required). |
| `server_authority.dart` | `AuthChallengeService` | `POST /api/auth/challenge` (deliberately a raw `Dio`, no `ApiClient`) | Step 1 of per-server auth: exchange a signed `Credential` for a time-limited `challenge` + `challenge_id` + `expires_at`. Not run through `ApiClient` because this happens before the target server has any tokens. |
| `server_credentials.dart` | ⚠️ stale/duplicate variant. Contains `Credential`, `CredentialResponse`, and a `UserCredentialsService` in broken form (`ApiClient.instance` as a static tearoff). Do not use — see `user_credentials_service.dart`. |
| `user_credentials_service.dart` | `UserCredentialsService` | `POST /api/users/credentials` (via one server's `ApiClient`) | Step 2 of multi-server auth: request a signed `Credential` from one server (typically the main server) on behalf of a *different* target server the user wants to log into. The resulting credential is then fed to the target server's challenge endpoint. |

The two-step dance is: main-server issues a signed credential for the target
→ client sends that credential to the target → target returns a challenge →
client signs the challenge (Ed25519) → target issues tokens → `ApiClient`
registers the target server and stores them. The actual token-issuance step is
not yet fully wired up.