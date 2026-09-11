# `lib/engine/functions/security` — Shamir Share Distribution

| File | Purpose |
|---|---|
| `share_secret.dart` | Two fail-safe functions that custody the user's Shamir recovery shares to trusted identities:
  - `shareSecretWithUser(identityId, database)` — takes the next available share from the vault in secure storage, writes it (plus the encrypted password blob) to the `ShamirsSecret` DB row for that identity, **verifies the write by reading it back**, and only then removes the share from the vault. If any step fails, the share is never lost.
  - `reverseShareSecretForUser(identityId, database)` — reverses the custody: read the DB record, decode the share, add it back to the vault, verify, then clear the DB records.
  
  Both track a `shamirNumber` counter on the `Identity` row (clamped 0–5) and return `ShareSecretResult` / `ReverseShareResult` with step-level error reporting.

The crypto itself lives in `lib/engine/crypto/shamirs/`, persists shares to the
`ShamirsSecret` table via `lib/engine/database/queries/shamirs_secret_queries.dart`,
and is surfaced through `FunctionsList.shareSecretWithUser` /
`FunctionsList.reverseShareSecretForUser`.