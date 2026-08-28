// Requires the `flutter_secure_storage` package (Keychain on iOS,
// Keystore-backed EncryptedSharedPreferences on Android). Add to
// pubspec.yaml:
//   dependencies:
//     flutter_secure_storage: ^9.2.2
//
// Depends on password_vault.dart and shamir_secret_sharing.dart from the
// same project.

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'password_vault.dart';

/// Default key name under which the vault is stored in secure storage.
const String kShamirSecretStorageKey = 'shamir_secret';

const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

/// Serializes and saves a [VaultResult] to platform secure storage under
/// [storageKey]. Overwrites whatever was previously stored there.
///
/// SECURITY NOTE: this stores the full [VaultResult], including the raw
/// AES key (`VaultResult.key`). Persisting the key alongside the shares
/// defeats the purpose of the 2-of-5 Shamir split — anyone with read
/// access to this storage entry gets the key directly, no quorum of
/// shares required. If you want the split to actually provide
/// protection, use [saveVaultWithoutRawKey] instead and distribute the
/// shares to separate custodians/locations rather than keeping them all
/// on this device.
Future<void> saveVaultToSecureStorage(
  VaultResult vault, {
  String storageKey = kShamirSecretStorageKey,
}) async {
  final json = jsonEncode(vault.toJson());
  await _secureStorage.write(key: storageKey, value: json);
}

/// Saves a [VaultResult] with the raw `key` field stripped (replaced
/// with an empty string) so the persisted record alone cannot decrypt
/// the payload — recovery then genuinely requires collecting >= 2 of
/// the 5 shares from wherever they've been distributed.
Future<void> saveVaultWithoutRawKey(
  VaultResult vault, {
  String storageKey = kShamirSecretStorageKey,
}) {
  final stripped = VaultResult(
    shares: vault.shares,
    payload: vault.payload,
    key: '',
    keyHash: vault.keyHash,
  );
  return saveVaultToSecureStorage(stripped, storageKey: storageKey);
}

/// Reads and deserializes the [VaultResult] stored under [storageKey].
/// Returns null if nothing is stored there.
Future<VaultResult?> getVaultFromSecureStorage({
  String storageKey = kShamirSecretStorageKey,
}) async {
  final json = await _secureStorage.read(key: storageKey);
  if (json == null) return null;
  return VaultResult.fromJson(jsonDecode(json) as Map<String, dynamic>);
}

/// Reads the vault under [storageKey], applies [update] to it, writes
/// the result back, and returns the updated vault.
///
/// Throws [StateError] if nothing is stored under [storageKey] yet —
/// call [saveVaultToSecureStorage] first to create it.
///
/// Example — replace the encrypted payload after a password change,
/// keeping the same key/shares:
/// ```dart
/// await editVaultInSecureStorage((vault) => VaultResult(
///       shares: vault.shares,
///       payload: newPayload,
///       key: vault.key,
///       keyHash: vault.keyHash,
///     ));
/// ```
Future<VaultResult> editVaultInSecureStorage(
  VaultResult Function(VaultResult current) update, {
  String storageKey = kShamirSecretStorageKey,
}) async {
  final current = await getVaultFromSecureStorage(storageKey: storageKey);
  if (current == null) {
    throw StateError('No vault stored under "$storageKey" to edit');
  }
  final updated = update(current);
  await saveVaultToSecureStorage(updated, storageKey: storageKey);
  return updated;
}

/// Deletes the vault stored under [storageKey], if any. No-op if
/// nothing is stored there.
Future<void> deleteVaultFromSecureStorage({
  String storageKey = kShamirSecretStorageKey,
}) {
  return _secureStorage.delete(key: storageKey);
}

/// Changes the password without changing the key or its Shamir shares.
///
/// Reads the vault already in secure storage, re-encrypts [newPassword]
/// with the *same* AES key that's already there, and overwrites only
/// the `payload` blob — `shares` and `keyHash` are left exactly as they
/// were. The 5 share-holders never need to regenerate or resubmit
/// anything, since the key itself never changes, only what it encrypts.
///
/// Throws [StateError] if:
/// - nothing is stored under [storageKey] yet, or
/// - the stored vault has no raw key (e.g. it was saved with
///   [saveVaultWithoutRawKey]) — in that case reconstruct the key from
///   >= 2 shares yourself and call [reencryptWithExistingKey] instead, or
/// - the stored key doesn't hash to the stored `keyHash`, which would
///   mean the stored record is corrupted or tampered with; re-encrypting
///   with an unverified key is refused rather than done silently.
Future<VaultResult> changePasswordInSecureStorage(
  String newPassword, {
  String storageKey = kShamirSecretStorageKey,
}) async {
  final current = await getVaultFromSecureStorage(storageKey: storageKey);
  if (current == null) {
    throw StateError('No vault stored under "$storageKey" to update');
  }
  if (current.key.isEmpty) {
    throw StateError(
      'Stored vault under "$storageKey" has no raw key (it was saved '
      'with saveVaultWithoutRawKey). Reconstruct the key from >= 2 '
      'shares and call reencryptWithExistingKey instead.',
    );
  }

  final keyBytes = keyFromHex(current.key);

  final keyIsValid = await verifyKeyHash(keyBytes, current.keyHash);
  if (!keyIsValid) {
    throw StateError(
      'Stored key does not match stored keyHash under "$storageKey"; '
      'refusing to re-encrypt with a possibly corrupted key.',
    );
  }

  return reencryptWithExistingKey(
    newPassword,
    keyBytes,
    current,
    storageKey: storageKey,
  );
}

/// Lower-level version of [changePasswordInSecureStorage] for when you
/// already have the AES key in hand (e.g. reconstructed from >= 2
/// shares because the stored vault has no raw `key`, per
/// [saveVaultWithoutRawKey]).
///
/// Re-encrypts [newPassword] with [key], replaces only `payload` on
/// [current], writes the updated vault back to [storageKey], and
/// returns it. Does not verify [key] against `current.keyHash` first —
/// callers using this directly are expected to have already confirmed
/// the key (e.g. via [verifyKeyHash]) since it usually came from a
/// share-reconstruction step they control.
Future<VaultResult> reencryptWithExistingKey(
  String newPassword,
  Uint8List key,
  VaultResult current, {
  String storageKey = kShamirSecretStorageKey,
}) async {
  final newPayload = await encryptPasswordWithKey(newPassword, key);

  final updated = VaultResult(
    shares: current.shares, // unchanged — no need to touch the 5 shares
    payload: newPayload, // only the encrypted blob is replaced
    key: current.key, // unchanged
    keyHash: current.keyHash, // unchanged — same key, same hash
  );

  await saveVaultToSecureStorage(updated, storageKey: storageKey);
  return updated;
}

/// True if a vault currently exists under [storageKey].
Future<bool> hasVaultInSecureStorage({
  String storageKey = kShamirSecretStorageKey,
}) async {
  return _secureStorage.containsKey(key: storageKey);
}