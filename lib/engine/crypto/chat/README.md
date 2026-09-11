# `lib/engine/crypto/chat` — 1-to-1 End-to-End Encryption

The primitives for end-to-end encrypted one-on-one messaging. This folder
implements a Signal-style encrypted channel: long-lived **Ed25519 signing
identities**, an authenticated **X25519 Diffie-Hellman handshake**, and a
**symmetric key ratchet** (symmetric half of the Double Ratchet) for
per-message encryption.

## File-by-file

| File | Purpose |
|---|---|
| `crypto_types.dart` | Core immutable value types shared by every file here: `DhKeyPair`, `RatchetState`, `KeyExchangeResult`, `SignedKeyExchange`, and `EncryptedMessage`. Pure data with `copyWith` helpers. |
| `identity_crypto.dart` | `IdentityCrypto` — generates/stores/loads the user's long-lived **Ed25519** signing keypair in `FlutterSecureStorage`, and provides `sign()` / `verify()`. The public key is also written to the local `Identity` DB row. |
| `asymetric_encryption.dart` | One-shot "sealed box" encryption: fresh ephemeral X25519 keypair per message + ECDH + **AES-256-GCM**, packed into a single Base64 string (mirrors libsodium `crypto_box_seal`). Used for identity-card / vCard exchange, not for the ratchet. |
| `key_exchange.dart` | `KeyExchange` — authenticates the DH handshake. Builds a canonical pipe-delimited transcript binding both parties' identities, signs/verifies it with Ed25519, and derives the raw X25519 shared secret. |
| `symmetric_ratchet.dart` | `SymmetricRatchet` — the symmetric (chain-key) half of the Double Ratchet. Derives a root key plus initiator/responder chain keys from the shared secret via **HKDF-SHA256**, advances chains per message, and caches up to 100 skipped keys for out-of-order delivery. |
| `message_crypto.dart` | `MessageCrypto` — per-message **XChaCha20-Poly1305** AEAD encryption/decryption using a message key + chain index + optional AAD. |
| `ratchet_store.dart` | `RatchetStore` — persists ratchet state and the skipped-key list in `FlutterSecureStorage` (JSON, base64url key material). |
| `conversation_key_store.dart` | Alternative/legacy ratchet persistence layer. The active path uses `RatchetStore` via `NullCrypto`; this appears to be an earlier iteration of the same idea (root keys stored separately). Keep unless you are certain it is unused. |
| `null_crypto.dart` | **Facade used by the rest of the app.** `NullCrypto` composes `IdentityCrypto` + `RatchetStore` and exposes the full lifecycle: identity key creation, ephemeral keys, shared-secret derivation, transcript signing/verification, `establishConversation()`, `encryptMessage()`, `decryptMessage()`, and `deleteConversation()`. |

## How a conversation is secured (summary)

1. Both users have an `IdentityCrypto` Ed25519 keypair (their long-term
   identity) and publish the public key (via invites / identity cards).
2. The initiator generates an ephemeral X25519 keypair, builds a transcript
   that binds both long-term identities and both ephemeral keys, signs it,
   and sends it (message type 0 — see `lib/engine/functions/chats/handshake.dart`).
3. The receiver verifies the signature, derives the shared secret via ECDH,
   stores it in the `Sessions` table, and replies. After an "ok null"
   confirmation, the conversation is established.
4. `NullCrypto.encryptMessage()` advances the sending chain to produce a fresh
   message key per message; the payload (`chain_index`, `ciphertext`, `nonce`,
   `mac`) is shipped through `lib/engine/functions/chats/01_send_message.dart`.
5. `NullCrypto.decryptMessage()` advances the receiving chain (or uses a
   skipped key) and only persists ratchet state after a successful decrypt.

> ⚠️ The README at the repo root states that the protocol state machine is not
> yet trustworthy for real messages — it still needs tests around simultaneous
> sends, duplicate delivery, skipped-key limits, and crash/rollback behaviour.