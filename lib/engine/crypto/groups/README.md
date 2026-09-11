# `lib/engine/crypto/groups` — Group (Multi-Party) Encryption

Primitives for end-to-end encrypted group messaging. Rather than a per-member
ratchet, groups use a shared **symmetric group key** that is distributed to
each member inside a per-member encrypted *envelope*, with **admin-signed key
rotation** for forward secrecy.

## File-by-file

| File | Purpose |
|---|---|
| `group_key.dart` | `GroupKey` — generates a random 256-bit **AES-256** group key (`AesGcm.with256bits()`), plus base64url encode/decode/`isValid()` helpers. |
| `group_key_envelope.dart` | `GroupKeyEnvelope` (DTO) + `GroupKeyEnvelopeCrypto`. `encryptForMember()` wraps the group key for one recipient: ephemeral X25519 + ECDH + **HKDF-SHA256** (info `NULL-GROUP-KEY-WRAP-v1`) + **AES-256-GCM**. `decryptEnvelope()` unwraps it with the recipient's private key. The group key is never transmitted in plaintext. |
| `group_message.dart` | `GroupEncryptedMessage` (DTO) + `GroupMessageCrypto`. `encrypt()`/`decrypt()` per-message **AES-256-GCM** using the group key. The `keyVersion` field tells receivers which group-key version to use. |
| `group_key_rotation.dart` | `GroupKeyRotation` (DTO) + `GroupKeyRotationCrypto`. Builds a **SHA-256 commitment** of the new key, signs the rotation payload with the admin's **Ed25519** key, and verifies it — so rotation cannot be tampered with. |
| `group_protocol.dart` | **Facade.** `GroupProtocol` is a static-only API over the files above: `createGroupKey()`, `prepareMemberKey()` / `recoverMemberKey()`, `createRotation()` (new key + per-member envelopes + commitment + signature), `encryptMessage()` / `decryptMessage()`. Also defines `GroupMemberPublicKey` and `GroupRotationResult`. |

## Data flow

- Owner creates a group → `GroupProtocol.createGroupKey()` generates the key
  (`functions/people/groupsfxn.dart`).
- Each added member gets `prepareMemberKey()` → one `GroupKeyEnvelope`
  encrypted to their public key, stored on the group.
- Messages are `AES-256-GCM` encrypted with the current key version and
  decrypted on the receiver's side with the matching stored envelope.
- `createRotation()` produces a new key; the `newPrivateKey` / `swapTime`
  columns on the `Groups` table hold the pending key until the swap time
  (`database/queries/groups_queries.dart`).