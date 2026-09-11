# `lib/engine/functions/auth` — Authentication Task Functions

Executable functions registered with the task engine for user authentication.

| File | Purpose |
|---|---|
| `loginfxn.dart` | `login(phoneNumber, password)` — thin wrapper around `SignInService.signIn()` (see `network/auth/login.dart`) against the hardcoded main server (`'server_1'`). Returns a `SignInResponse`. |
| `registerfxn.dart` | `registerNewUser(...)` — the end-to-end registration orchestrator, in 6 steps: ① generate an AES-256 key and encrypt the password; ② split the key via Shamir (2-of-5); ③ save the vault to secure storage; ④ call `POST /api/create-new-user-postprocess` with the encrypted blob; ⑤ save the returned security token; ⑥ insert the local `Identity` row. Skips straight to "already exists" if a local registration is present. Returns a `RegistrationResult` with a step-level error report. |

Both are surfaced to the rest of the app through
`../functions_list.dart` (`FunctionsList.login` /
`FunctionsList.registerNewUser`).