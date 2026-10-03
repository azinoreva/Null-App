// Ties together: identity_crypto.dart (the Ed25519 identity keypair the
// passport is bound to), new_passport.dart (POST /api/new-passport on the
// main service), and security_token.dart (where the passport is persisted —
// the same key signup writes).

import 'dart:convert';

import 'package:dio/dio.dart';

import '../../crypto/chat/identity_crypto.dart';
import '../../network/auth/new_passport.dart';
import '../../network/main_server_client.dart';
import '../../network/server_error_exception.dart';
import '../../securestore/security_token.dart';

/// How [refreshPassport] concluded.
enum PassportRefreshOutcome { success, failed }

/// Result of [refreshPassport].
class PassportRefreshResult {
  final PassportRefreshOutcome outcome;
  final String? failedStep;
  final String? errorMessage;

  /// The freshly minted passport, on success.
  final String? passport;

  const PassportRefreshResult._({
    required this.outcome,
    this.failedStep,
    this.errorMessage,
    this.passport,
  });

  factory PassportRefreshResult.success(String passport) =>
      PassportRefreshResult._(
        outcome: PassportRefreshOutcome.success,
        passport: passport,
      );

  factory PassportRefreshResult.failed(String step, String message) =>
      PassportRefreshResult._(
        outcome: PassportRefreshOutcome.failed,
        failedStep: step,
        errorMessage: message,
      );

  bool get isSuccess => outcome == PassportRefreshOutcome.success;

  @override
  String toString() => isSuccess
      ? 'PassportRefreshResult.success'
      : 'PassportRefreshResult.failed(step: $failedStep, error: $errorMessage)';
}

/// Mints a new passport for the account and persists it over the old one.
///
/// The passport is the credential a *peer* server accepts at
/// `/api/auth/server-entry`, and it expires (30 days). When it does, the only
/// fix is to ask the main service for another one — the device holds no
/// signing key for it. This is that call.
///
/// The passport is minted against the current Ed25519 identity public key,
/// because the peer verifies the challenge signature with exactly the key the
/// passport names (`authorisations.py` stores `payload["pub"]` at entry and
/// verifies the answer against it). A missing keypair is generated first,
/// mirroring signup: nothing can be signed without one, and because the new
/// passport carries the new public key the two stay consistent.
///
/// Requires an authenticated main-server session — this goes through
/// [MainServerClient], so a 401 triggers the usual refresh-and-retry and only
/// a genuinely dead session surfaces as a failure here.
///
/// Nothing throws; failures come back as [PassportRefreshOutcome.failed].
Future<PassportRefreshResult> refreshPassport() async {
  const crypto = IdentityCrypto();

  final String publicKey;
  try {
    if (await crypto.loadPrivateKey() == null) {
      await crypto.generateIdentityKey();
    }
    publicKey = base64UrlEncode(await crypto.loadPublicKey());
  } catch (e) {
    return PassportRefreshResult.failed('generate_identity_key', e.toString());
  }

  final NewPassportResponse response;
  try {
    response = await PassportService().newPassport(publicKey: publicKey);
  } on ServerErrorException catch (e) {
    return PassportRefreshResult.failed('new_passport', e.message);
  } on DioException catch (e) {
    return PassportRefreshResult.failed(
      'new_passport',
      e.message ?? 'Network request failed',
    );
  } catch (e) {
    return PassportRefreshResult.failed('new_passport', e.toString());
  }

  try {
    await savePassport(response.passport);
  } catch (e) {
    return PassportRefreshResult.failed('save_passport', e.toString());
  }

  return PassportRefreshResult.success(response.passport);
}
