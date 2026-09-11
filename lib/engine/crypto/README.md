# `lib/engine/crypto` — Cryptographic Subsystem

All cryptography in the app lives under this folder. It is split into three
independent areas, each with its own README:

| Folder | Purpose |
|---|---|
| [`chat/`](chat/README.md) | 1-to-1 end-to-end encryption: Ed25519 identities, X25519 + authenticated DH handshake, symmetric key ratchet (Double-Ratchet symmetric half), XChaCha20-Poly1305 per-message encryption. |
| [`groups/`](groups/README.md) | Multi-party encryption: shared AES-256 group keys distributed via per-member X25519/AES-GCM envelopes, AES-256-GCM group messages, and admin-signed key rotation. |
| [`shamirs/`](shamirs/README.md) | Social password recovery: password encrypted with a random AES-256 key, the key split using Shamir's Secret Sharing (2-of-5), and the split shares distributed to trusted contacts. |

## Shared dependencies

All key material and ratchet/vault state is persisted in **platform secure
storage** (`flutter_secure_storage` — Keystore/Keychain) rather than plain
SharedPreferences. Everything is built on the `cryptography` package
(Ed25519, X25519, AES-256-GCM, XChaCha20-Poly1305, HKDF-SHA256, SHA-256).

The facade the rest of the app talks to is **`NullCrypto`** (in
`chat/null_crypto.dart`) for 1-to-1, **`GroupProtocol`** (in
`groups/group_protocol.dart`) for groups, and the **`createPasswordVault` /
`reconstructKey`** helpers (in `shamirs/password_vault.dart`) for the vault.

> ⚠️ See the root README for the current caveat: the protocol state machine is
> not yet covered by the tests it needs.