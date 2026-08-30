// Pulls one remaining share out of the vault in secure storage, writes it
// (plus the encrypted password blob) to the ShamirsSecret table for the
// given recipient, verifies the write actually landed, and only then
// removes that one share from the vault — so a failed/partial write can
// never cause the same share to be dispensed to two different people.
//
// Adjust the relative import paths below to match your project layout.
// Assumes a single AppDatabase registers Identity, ShamirsSecret, and
// SecretShare tables together with IdentityDao, ShamirsSecretDao, and
// SecretShareDao, so `database.shamirsSecretDao` / `database.secretShareDao`
// are available (matching the drift convention already used for
// `database.identityDao` in the registration orchestrator).

import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;

import '../../database/app_database.dart'; // AppDatabase
import '../../crypto/shamirs/password_vault.dart'; // VaultResult
import '../../crypto/shamirs/shamir_secret.dart' show Share;
import '../../database/queries/shamirs_secret_queries.dart'; // ShamirsSecretDao, ShamirsSecret, ShamirsSecretCompanion
import '../../crypto/shamirs/vault_secrets.dart'; // getVaultFromSecureStorage, saveVaultToSecureStorage, kShamirSecretStorageKey
import '../../database/queries/identity_queries.dart' show IdentityCompanion; // for the shamirNumber update

// Total shares a vault is split into (see _shamirTotalShares in
// password_vault.dart) — used to bound the shamirNumber counter below.
const int _totalShares = 5;

/// How [shareSecretWithUser] concluded.
enum ShareSecretOutcome { success, failed }

/// Reads the current `Identity` row's `shamirNumber` and adjusts it by
/// [delta], clamped to `[0, _totalShares]`. Used to keep a running count
/// of how many of the 5 shares have actually been dispensed to trusted
/// contacts. No-ops if there's no `Identity` row yet.
Future<void> _adjustShamirNumber(AppDatabase database, int delta) async {
  final current = await database.identityDao.getCurrentIdentityOrNull();
  if (current == null) return;
  final next = (current.shamirNumber + delta).clamp(0, _totalShares);
  await database.identityDao.updateIdentityFields(
    IdentityCompanion(shamirNumber: Value(next)),
  );
}

/// Result of [shareSecretWithUser]. On [ShareSecretOutcome.success],
/// [share] is the one that was dispensed. On
/// [ShareSecretOutcome.failed], [failedStep] and [errorMessage] describe
/// what went wrong.
class ShareSecretResult {
  final ShareSecretOutcome outcome;
  final Share? share;
  final String? failedStep;
  final String? errorMessage;

  const ShareSecretResult._({
    required this.outcome,
    this.share,
    this.failedStep,
    this.errorMessage,
  });

  factory ShareSecretResult.success(Share share) => ShareSecretResult._(
        outcome: ShareSecretOutcome.success,
        share: share,
      );

  factory ShareSecretResult.failed(String step, String message) =>
      ShareSecretResult._(
        outcome: ShareSecretOutcome.failed,
        failedStep: step,
        errorMessage: message,
      );

  bool get isSuccess => outcome == ShareSecretOutcome.success;

  @override
  String toString() {
    return outcome == ShareSecretOutcome.success
        ? 'ShareSecretResult.success(share: $share)'
        : 'ShareSecretResult.failed(step: $failedStep, error: $errorMessage)';
  }
}

/// Reverses a previously-dispensed share: puts it back in the vault in
/// secure storage and clears the DB records that marked it as given
/// out. Intended for "changed my mind mid-flow" — e.g. the UI dispensed
/// a share via [shareSecretWithUser] but the send-to-friend step never
/// completed. It does NOT know whether the share actually reached the
/// recipient by some other channel; only call this when you're sure it
/// didn't.
///
/// Mirrors [shareSecretWithUser]'s ordering for the same reason: nothing
/// is deleted from the database until the share is confirmed back in
/// the vault, so a failure partway through never loses the share
/// entirely — it's always safe to retry.
///
/// Returns [ReverseShareOutcome.failed] with step `'not_found'` if
/// [identityId] has no dispensed share on file to reverse.
Future<ReverseShareResult> reverseShareSecretForUser({
  required String identityId,
  required AppDatabase database,
  String storageKey = kShamirSecretStorageKey,
}) async {
  try {
    // 1. Look up what was dispensed to this identity.
    final ShamirsSecret? dispensed;
    try {
      dispensed =
          await database.shamirsSecretDao.getShamirsSecretByIdentityId(
        identityId,
      );
    } catch (e) {
      return ReverseShareResult.failed('db_lookup', e.toString());
    }
    if (dispensed == null) {
      return ReverseShareResult.failed(
        'not_found',
        'No share on file for identity "$identityId" to reverse',
      );
    }

    // 2. Decode the share that was given out.
    final Share share;
    try {
      share = Share.fromJson(
        jsonDecode(dispensed.secretShare) as Map<String, dynamic>,
      );
    } catch (e) {
      return ReverseShareResult.failed(
        'decode_share',
        'Stored secretShare is malformed: $e',
      );
    }

    // 3. Read the current vault.
    final vault = await getVaultFromSecureStorage(storageKey: storageKey);
    if (vault == null) {
      return ReverseShareResult.failed(
        'no_vault',
        'No Shamir vault found in secure storage under "$storageKey"; '
            'cannot restore the share there.',
      );
    }

    // 4. Add the share back to the vault (unless it's somehow already
    //    there), and confirm the write before touching the DB.
    final alreadyPresent = vault.shares.any((s) => s.id == share.id);
    if (!alreadyPresent) {
      final restoredShares = [...vault.shares, share]
        ..sort((a, b) => a.id.compareTo(b.id));
      final restoredVault = VaultResult(
        shares: restoredShares,
        payload: vault.payload,
        key: vault.key,
        keyHash: vault.keyHash,
        passwordVersion: vault.passwordVersion,
      );
      try {
        await saveVaultToSecureStorage(restoredVault, storageKey: storageKey);
      } catch (e) {
        return ReverseShareResult.failed(
          'restore_share_to_vault',
          e.toString(),
        );
      }

      // Verify it actually landed before deleting anything from the DB.
      final verifyVault =
          await getVaultFromSecureStorage(storageKey: storageKey);
      final verified = verifyVault?.shares.any(
            (s) => s.id == share.id && s.value == share.value,
          ) ??
          false;
      if (!verified) {
        return ReverseShareResult.failed(
          'verify_restore',
          'Share was not confirmed back in the vault; the database '
              'record was left untouched, so this is safe to retry.',
        );
      }
    }

    // 5. Only now clear the DB records — the share is confirmed back in
    //    the vault, so it's safe to stop treating it as dispensed.
    try {
      await database.shamirsSecretDao.deleteShamirsSecretByIdentityId(
        identityId,
      );
    } catch (e) {
      return ReverseShareResult.failed(
        'delete_shamirs_secret',
        e.toString(),
      );
    }

    try {
      await database.secretShareDao.deleteShare(identityId);
    } catch (e) {
      // The share is already back in the vault and the ShamirsSecret
      // row is gone; only the bookkeeping row failed to clear.
      return ReverseShareResult.failed(
        'delete_secret_share_record',
        e.toString(),
      );
    }

    // 6. Decrement the dispensed-share counter to match. The restore is
    //    already committed by this point, so a failure here just
    //    leaves the counter stale rather than undoing the restore.
    try {
      await _adjustShamirNumber(database, -1);
    } catch (e) {
      return ReverseShareResult.failed('update_shamir_number', e.toString());
    }

    return ReverseShareResult.success(share);
  } catch (e) {
    return ReverseShareResult.failed('unknown', e.toString());
  }
}

/// How [reverseShareSecretForUser] concluded.
enum ReverseShareOutcome { success, failed }

/// Result of [reverseShareSecretForUser]. On
/// [ReverseShareOutcome.success], [share] is the one restored to the
/// vault. On [ReverseShareOutcome.failed], [failedStep] and
/// [errorMessage] describe what went wrong.
class ReverseShareResult {
  final ReverseShareOutcome outcome;
  final Share? share;
  final String? failedStep;
  final String? errorMessage;

  const ReverseShareResult._({
    required this.outcome,
    this.share,
    this.failedStep,
    this.errorMessage,
  });

  factory ReverseShareResult.success(Share share) => ReverseShareResult._(
        outcome: ReverseShareOutcome.success,
        share: share,
      );

  factory ReverseShareResult.failed(String step, String message) =>
      ReverseShareResult._(
        outcome: ReverseShareOutcome.failed,
        failedStep: step,
        errorMessage: message,
      );

  bool get isSuccess => outcome == ReverseShareOutcome.success;

  @override
  String toString() {
    return outcome == ReverseShareOutcome.success
        ? 'ReverseShareResult.success(share: $share)'
        : 'ReverseShareResult.failed(step: $failedStep, error: $errorMessage)';
  }
}

/// Dispenses one of the remaining Shamir shares to [identityId].
///
/// Order of operations matters here: the share is only removed from
/// secure storage AFTER it's been written to the database and read back
/// to confirm it's really there. If the DB write or the verification
/// read fails, the function stops and returns
/// [ShareSecretOutcome.failed] with the vault untouched — nothing is
/// deleted from secure storage unless the DB is confirmed to have it,
/// so a share can never be silently lost, and a failed attempt can
/// simply be retried.
///
/// If [identityId] already has a share on file (the `ShamirsSecret`
/// table has one row per identity, keyed on `identityId`), the insert
/// fails with a primary-key conflict and this returns
/// [ShareSecretOutcome.failed] with step `'db_insert'` — it will NOT
/// consume a share from the vault in that case, so retrying after
/// clearing the duplicate is always safe.
///
/// If no shares remain in the vault (all 5 already dispensed), returns
/// [ShareSecretOutcome.failed] with step `'no_shares_left'`.
Future<ShareSecretResult> shareSecretWithUser({
  required String identityId,
  required AppDatabase database,
  String storageKey = kShamirSecretStorageKey,
}) async {
  try {
    final vault = await getVaultFromSecureStorage(storageKey: storageKey);
    if (vault == null) {
      return ShareSecretResult.failed(
        'no_vault',
        'No Shamir vault found in secure storage under "$storageKey"',
      );
    }
    if (vault.shares.isEmpty) {
      return ShareSecretResult.failed(
        'no_shares_left',
        'All shares have already been dispensed',
      );
    }

    // Take the next available share. Which one is arbitrary — any share
    // is equally usable — so the first remaining one is fine.
    final shareToGive = vault.shares.first;
    final encodedShare = jsonEncode(shareToGive.toJson());
    final now = DateTime.now().millisecondsSinceEpoch;
    final passwordBlobBytes = Uint8List.fromList(
      utf8.encode(jsonEncode(vault.payload.toJson())),
    );

    // 1. Write the share + password blob to the DB first.
    try {
      await database.shamirsSecretDao.insertShamirsSecret(
        ShamirsSecretCompanion.insert(
          identityId: identityId,
          secretShare: encodedShare,
          updatedAt: now,
          passwordBlob: passwordBlobBytes,
          // No settings-encryption feature exists yet; left unset.
        ),
      );
    } catch (e) {
      // Most commonly a primary-key conflict if identityId already has
      // a share on file. No share has been touched in the vault yet.
      return ShareSecretResult.failed('db_insert', e.toString());
    }

    // 2. Verify it actually landed before touching secure storage.
    final inserted =
        await database.shamirsSecretDao.getShamirsSecretByIdentityId(
      identityId,
    );
    if (inserted == null || inserted.secretShare != encodedShare) {
      return ShareSecretResult.failed(
        'db_verify',
        'Insert did not verify; the share was NOT removed from secure '
            'storage, so this is safe to retry.',
      );
    }

    // 3. Only now remove that one share from the vault, so it can never
    //    be handed to a second person.
    final remainingShares =
        vault.shares.where((s) => s.id != shareToGive.id).toList();
    final updatedVault = VaultResult(
      shares: remainingShares,
      payload: vault.payload,
      key: vault.key,
      keyHash: vault.keyHash,
      passwordVersion: vault.passwordVersion,
    );
    try {
      await saveVaultToSecureStorage(updatedVault, storageKey: storageKey);
    } catch (e) {
      return ShareSecretResult.failed('remove_share_from_vault', e.toString());
    }

    // 4. Record the share event for recovery bookkeeping. Settings
    //    versioning has no real value yet since settings-encryption
    //    isn't implemented — recorded as 0 as a placeholder.
    try {
      await database.secretShareDao.recordShare(
        identityId,
        passwordVersion: vault.passwordVersion,
        settingsVersion: 0,
        timestamp: now,
      );
    } catch (e) {
      // The share is already dispensed and removed from the vault at
      // this point; only the bookkeeping record failed.
      return ShareSecretResult.failed('record_share', e.toString());
    }

    // 5. Track how many of the 5 shares have been dispensed so far. The
    //    share is already committed by this point (steps 1-4 all
    //    succeeded), so a failure here just leaves the counter stale
    //    rather than undoing anything already done.
    try {
      await _adjustShamirNumber(database, 1);
    } catch (e) {
      return ShareSecretResult.failed('update_shamir_number', e.toString());
    }

    return ShareSecretResult.success(shareToGive);
  } catch (e) {
    return ShareSecretResult.failed('unknown', e.toString());
  }
}