# `lib/engine/crypto/shamirs` — Shamir's Secret Sharing (Password Recovery)

Implements a **social password-recovery** system: the user's password is
encrypted with a random AES-256 key, and that key is split into 5 Shamir
shares (threshold **2-of-5**) which can be distributed to trusted contacts.
With any 2 shares the key — and therefore the password — can be recovered.

## File-by-file

| File | Purpose |
|---|---|
| `shamir_secret.dart` | Pure-Dart **Shamir's Secret Sharing** over the secp256k1 field prime (~2^256). `splitSecret()` builds a threshold-degree polynomial (secret as the constant term) and evaluates it at x = 1..n; `combineShares()` reconstructs the secret via Lagrange interpolation. Includes uniform random field sampling (rejection sampling), modular inverse (extended Euclid), byte↔bigint↔hex helpers, `Share` DTO, and `ShamirException`. |
| `create_secret.dart` | Password-vault creation: random 256-bit key, **AES-256-GCM** encrypt the password, split the key 2-of-5, hash the key for verification. Exposes `reconstructKey()`, `verifyKeyHash()`, `decryptPassword()`, `keyFromHex()`, plus `EncryptedPayload` and `VaultResult`. |
| `password_vault.dart` | **Extended/superset version** of `create_secret.dart` and the file actually used by registration/vault storage. Adds `encryptPasswordWithKey()` (re-encrypt the password with an *existing* key so password changes don't need the 5 custodians), a `passwordVersion` counter (starts at 1, increments per re-encrypt), and full JSON serialization. |
| `vault_secrets.dart` | Secure-storage persistence for the vault (`FlutterSecureStorage`): `saveVaultToSecureStorage()`, `saveVaultWithoutRawKey()` (strips the raw key so recovery *requires* shares), `getVaultFromSecureStorage()`, `editVaultInSecureStorage()`, `deleteVaultFromSecureStorage()`, `changePasswordInSecureStorage()`, `reencryptWithExistingKey()`, `hasVaultInSecureStorage()`. |

## Two note-worthy relationships

- `registerfxn.dart` (`functions/auth`) creates the vault during registration
  and saves 2-of-5 shares locally.
- `share_secret.dart` (`functions/security`) dispenses individual shares to
  trusted identities (stored in the `ShamirsSecret` table) and can reverse the
  process — with fail-safe ordering so a database write always verifies before
  a share is removed from the vault.