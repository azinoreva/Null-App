// Ties together: password_vault.dart (key generation + AES-GCM encrypt +
// Shamir split), vault_secure_storage.dart (persist the vault),
// security_token_storage.dart (persist the security token),
// register_null.dart (the actual network call), and identity_queries.dart
// (the local Identity row).
//
// Adjust the relative import paths below to match your project layout.

import 'dart:convert';

import 'package:dio/dio.dart';

import '../../database/app_database.dart'; // AppDatabase, IdentityDao, IdentityData
import '../../crypto/shamirs/password_vault.dart'; // createPasswordVault, VaultResult
import '../../network/auth/register.dart'; // registerNewUser
import '../../network/server_error_exception.dart';
import '../../securestore/security_token.dart';
import '../../crypto/shamirs/vault_secrets.dart'; // saveVaultToSecureStorage, hasVaultInSecureStorage

/// How [registerNewUser] concluded.
enum RegistrationOutcome { success, alreadyExists, failed }

/// Result of [registerNewUser]. Check [outcome] first:
/// - [RegistrationOutcome.success] — [response] is populated.
/// - [RegistrationOutcome.alreadyExists] — nothing was done; a complete
///   registration was already found locally.
/// - [RegistrationOutcome.failed] — [failedStep] and [errorMessage]
///   describe what went wrong.
class RegistrationResult {
  final RegistrationOutcome outcome;
  final String? failedStep;
  final String? errorMessage;
  final CreateUserPostprocessResponse? response;

  const RegistrationResult._({
    required this.outcome,
    this.failedStep,
    this.errorMessage,
    this.response,
  });

  factory RegistrationResult.success(CreateUserPostprocessResponse response) =>
      RegistrationResult._(
        outcome: RegistrationOutcome.success,
        response: response,
      );

  factory RegistrationResult.alreadyExists() =>
      const RegistrationResult._(outcome: RegistrationOutcome.alreadyExists);

  factory RegistrationResult.failed(String step, String message) =>
      RegistrationResult._(
        outcome: RegistrationOutcome.failed,
        failedStep: step,
        errorMessage: message,
      );

  bool get isSuccess => outcome == RegistrationOutcome.success;

  @override
  String toString() {
    switch (outcome) {
      case RegistrationOutcome.success:
        return 'RegistrationResult.success($response)';
      case RegistrationOutcome.alreadyExists:
        return 'RegistrationResult.alreadyExists';
      case RegistrationOutcome.failed:
        return 'RegistrationResult.failed(step: $failedStep, error: $errorMessage)';
    }
  }
}

/// Registers a new user end-to-end:
/// 1. Generates an AES-256 key and encrypts [password] with it.
/// 2. Splits the key 2-of-5 via Shamir's Secret Sharing.
/// 3. Saves the resulting vault (shares + encrypted payload + key +
///    keyHash) to secure storage under `"shamir_secret"` — the 5 shares
///    can be handed to trusted contacts later; this call only stores
///    them locally.
/// 4. Makes the one network call, `POST /api/create-new-user-postprocess`,
///    sending the encrypted payload as `encrypted_blob`.
/// 5. Saves the returned `securityToken` to secure storage.
/// 6. Writes an `Identity` row to the local database from the response,
///    with `displayName` fixed to `"Null User"`.
///
/// Before doing any of this, unless [forceOverwrite] is true, it checks
/// whether a complete local registration already exists (Shamir vault +
/// security token + Identity row, all three). If all three are present,
/// it returns [RegistrationOutcome.alreadyExists] without touching
/// anything. If [forceOverwrite] is true, that check is skipped entirely
/// and everything is regenerated and overwritten. If some but not all
/// three are present and [forceOverwrite] is false, the partial state is
/// NOT patched up piecemeal — the whole flow runs again from scratch, as
/// if nothing existed, and overwrites whatever was there.
///
/// Every step is wrapped individually: if something fails partway
/// through, [RegistrationResult.failed] reports which step
/// (`encrypt_and_split`, `save_vault`, `network_call`,
/// `save_security_token`, or `save_identity`) and why. Steps completed
/// before the failure are NOT rolled back — e.g. a failure in
/// `save_identity` still leaves the vault, token, and server-side user
/// in place. A subsequent call (without [forceOverwrite]) will detect
/// the incomplete local state and retry the whole flow, which does mean
/// `create-new-user-postprocess` may be called again for an already
/// -registered phone number; how the server handles that repeat call is
/// outside this function's control.
Future<RegistrationResult> registerNewUser({
  required String phoneNumber,
  required String pin,
  required String password,
  required AppDatabase database,
  bool forceOverwrite = false,
}) async {
  try {
    if (!forceOverwrite) {
      final complete = await _localRegistrationIsComplete(database);
      if (complete) {
        return RegistrationResult.alreadyExists();
      }
      // Partial or no local state: fall through and run the full flow,
      // overwriting whatever partial state exists.
    }

    // 1 & 2. Generate the key, encrypt the password, split the key.
    final VaultResult vault;
    try {
      vault = await createPasswordVault(password);
    } catch (e) {
      return RegistrationResult.failed('encrypt_and_split', e.toString());
    }

    // 3. Persist the vault (shares + payload + key + keyHash) locally.
    try {
      await saveVaultToSecureStorage(vault);
    } catch (e) {
      return RegistrationResult.failed('save_vault', e.toString());
    }

    // 4. The one network call.
    final CreateUserPostprocessResponse response;
    try {
      final encryptedBlob = jsonEncode(vault.payload.toJson());
      response = await UserRegistrationService().postprocess(
        phoneNumber: phoneNumber,
        pin: pin,
        password: password,
        encryptedBlob: encryptedBlob,
      );
    } on ServerErrorException catch (e) {
      return RegistrationResult.failed('network_call', e.message);
    } on DioException catch (e) {
      return RegistrationResult.failed(
        'network_call',
        e.message ?? 'Network request failed',
      );
    } catch (e) {
      return RegistrationResult.failed('network_call', e.toString());
    }

    // 5. Save the security token.
    try {
      await saveSecurityToken(response.securityToken);
    } catch (e) {
      return RegistrationResult.failed('save_security_token', e.toString());
    }

    // 6. Persist the Identity row.
    try {
      final identity = IdentityData(
        identityId: response.userId,
        displayName: 'Null User',
        avatar: null,
        bio: null,
        phoneNumber: phoneNumber,
        saltVersion: response.saltVersion,
        // No shares have been handed to trusted contacts yet at
        // registration time.
        shamirNumber: 0,
        publicKey: null,
        passportVersion: response.schemaVersion,
        autoSync: 0,
        allowConnectReq: 0,
        recoveryType: response.recoveryType,
        invitationCount: response.invitationCount,
      );
      await database.identityDao.upsertIdentity(identity);
    } catch (e) {
      return RegistrationResult.failed('save_identity', e.toString());
    }

    return RegistrationResult.success(response);
  } catch (e) {
    return RegistrationResult.failed('unknown', e.toString());
  }
}

/// True only if all three pieces of a completed registration are
/// present locally: the Shamir vault, the security token, and the
/// Identity row.
Future<bool> _localRegistrationIsComplete(AppDatabase database) async {
  final hasVault = await hasVaultInSecureStorage();
  final hasToken = await hasSecurityToken();
  final identity = await database.identityDao.getCurrentIdentityOrNull();
  return hasVault && hasToken && identity != null;
}