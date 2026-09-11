# `lib/engine/securestore` — Secure-Storage Abstraction

| File | Purpose |
|---|---|
| `security_token.dart` | Persists the post-registration **security token** in platform secure storage (`FlutterSecureStorage` with `AndroidOptions(resetOnError: false)`). Four functions: `saveSecurityToken(token)`, `getSecurityToken()`, `hasSecurityToken()`, `deleteSecurityToken()` — each accepting an optional `storageKey` override (default `'securityToken'`). |

All vault-related secure-storage operations live in
`lib/engine/crypto/shamirs/vault_secrets.dart` instead; this file only
handles the auth/security token.