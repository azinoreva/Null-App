// Ties together: security_token.dart (reads the passport saved at signup),
// identity_queries.dart (reads the local user id), identity_crypto.dart (signs
// the server's challenge with the Ed25519 identity key registered at signup),
// enter_server.dart (the two-step POST /api/auth/server-entry ->
// /api/auth/server-challenge exchange), and api_client.dart (persists the
// resulting access/refresh token pair scoped per server_id).

import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../crypto/chat/identity_crypto.dart';
import '../../database/app_database.dart';
import '../../network/api_client.dart';
import '../../network/servers/enter_server.dart';
import '../../securestore/security_token.dart';
import '../auth/refresh_passportfxn.dart';

/// How [connectServerUsingPassport] concluded.
enum ServerConnectOutcome {
  success,
  noPassport,
  noIdentity,
  noIdentityKey,
  challengeExpired,
  passportRejected,
  failed,
}

/// Result of [connectServerUsingPassport]. Check [outcome] first:
/// - [ServerConnectOutcome.success] — [signIn] holds the verified token pair.
/// - [ServerConnectOutcome.noPassport] — no passport is saved in secure
///   storage.
/// - [ServerConnectOutcome.noIdentity] — the local database has no Identity
///   row to read a user id from.
/// - [ServerConnectOutcome.noIdentityKey] — the Ed25519 private key is gone
///   from secure storage, so the challenge cannot be signed.
/// - [ServerConnectOutcome.challengeExpired] — the challenge TTL (60s) lapsed
///   between receiving it and answering it.
/// - [ServerConnectOutcome.passportRejected] — the server refused the passport
///   or the signature (expired passport, unknown server key, invite pin
///   missing on a private server, or a local identity key that no longer
///   matches the public key registered at signup). [errorMessage] carries the
///   server's own `detail` text.
/// - [ServerConnectOutcome.failed] — [failedStep] and [errorMessage] describe
///   what went wrong (usually the network).
class ServerConnectResult {
  final ServerConnectOutcome outcome;
  final String? failedStep;
  final String? errorMessage;
  final SignInReturn? signIn;

  const ServerConnectResult._({
    required this.outcome,
    this.failedStep,
    this.errorMessage,
    this.signIn,
  });

  factory ServerConnectResult.success(SignInReturn signIn) =>
      ServerConnectResult._(
        outcome: ServerConnectOutcome.success,
        signIn: signIn,
      );

  factory ServerConnectResult.noPassport() =>
      const ServerConnectResult._(outcome: ServerConnectOutcome.noPassport);

  factory ServerConnectResult.noIdentity() =>
      const ServerConnectResult._(outcome: ServerConnectOutcome.noIdentity);

  factory ServerConnectResult.noIdentityKey() =>
      const ServerConnectResult._(outcome: ServerConnectOutcome.noIdentityKey);

  factory ServerConnectResult.challengeExpired() => const ServerConnectResult._(
    outcome: ServerConnectOutcome.challengeExpired,
  );

  factory ServerConnectResult.passportRejected(String message) =>
      ServerConnectResult._(
        outcome: ServerConnectOutcome.passportRejected,
        errorMessage: message,
      );

  factory ServerConnectResult.failed(String step, String message) =>
      ServerConnectResult._(
        outcome: ServerConnectOutcome.failed,
        failedStep: step,
        errorMessage: message,
      );

  bool get isSuccess => outcome == ServerConnectOutcome.success;

  @override
  String toString() {
    switch (outcome) {
      case ServerConnectOutcome.success:
        return 'ServerConnectResult.success($signIn)';
      case ServerConnectOutcome.noPassport:
        return 'ServerConnectResult.noPassport';
      case ServerConnectOutcome.noIdentity:
        return 'ServerConnectResult.noIdentity';
      case ServerConnectOutcome.noIdentityKey:
        return 'ServerConnectResult.noIdentityKey';
      case ServerConnectOutcome.challengeExpired:
        return 'ServerConnectResult.challengeExpired';
      case ServerConnectOutcome.passportRejected:
        return 'ServerConnectResult.passportRejected($errorMessage)';
      case ServerConnectOutcome.failed:
        return 'ServerConnectResult.failed(step: $failedStep, error: $errorMessage)';
    }
  }
}

/// Connects to [serverId] using the passport saved at registration time.
///
/// The exchange is deliberately two-legged — a passport alone only proves you
/// once held the main server's blessing, so the peer challenges you to prove
/// you still hold the identity key whose public half it has on file:
///
/// 1. Reads the passport (`passport`) from secure storage.
/// 2. Reads the local user id (the `Identity` row's `identityId`) from the
///    database.
/// 3. `POST /api/auth/server-entry` → the peer verifies the passport and
///    returns a random challenge (60s TTL).
/// 4. Signs those challenge bytes with the Ed25519 identity key that was
///    registered at signup.
/// 5. `POST /api/auth/server-challenge` with the signature → token pair.
/// 6. Persists the token pair under server-scoped keys
///    (`access_token_<serverId>`, `refresh_token_<serverId>`) so ApiClient
///    authenticates against that server from now on.
///
/// [invitePin] is only needed for private servers; public servers ignore it.
///
/// If the peer refuses the passport at entry — it has expired, or the local
/// identity key no longer matches the one the passport was minted for — one
/// re-mint and one retry are attempted automatically before giving up, since
/// a stale passport is the single most common reason this fails and the fix
/// is a free authenticated call to the main service. The retry is not repeated
/// a second time.
///
/// The server must already be registered with ApiClient (see
/// ApiClient.registerServer) — that registration is what lets the request
/// resolve against the server's base URL. Nothing here throws: every failure
/// maps to a [ServerConnectOutcome] (offline/HTTP errors land in
/// [ServerConnectOutcome.failed] with a failed step of 'server_entry',
/// 'sign_challenge', 'server_challenge', or 'save_tokens').
Future<ServerConnectResult> connectServerUsingPassport({
  required String serverId,
  required AppDatabase database,
  String? invitePin,
}) async {
  final passport = await getPassport();
  if (passport == null || passport.isEmpty) {
    return ServerConnectResult.noPassport();
  }

  final identity = await database.identityDao.getCurrentIdentityOrNull();
  if (identity == null) {
    return ServerConnectResult.noIdentity();
  }

  const crypto = IdentityCrypto();
  if (await crypto.loadPrivateKey() == null) {
    return ServerConnectResult.noIdentityKey();
  }

  final result = await _attemptHandshake(
    serverId: serverId,
    identity: identity,
    passport: passport,
    crypto: crypto,
    invitePin: invitePin,
  );

  if (!result.usedUpPassportRetry) return result.result;

  // Re-mint against the *current* identity key — the peer verifies the
  // challenge with whatever public key the new passport names.
  final refreshed = await refreshPassport();
  if (!refreshed.isSuccess) {
    return result.result;
  }

  return (await _attemptHandshake(
    serverId: serverId,
    identity: identity,
    passport: refreshed.passport!,
    crypto: crypto,
    invitePin: invitePin,
  )).result;
}

/// Runs one full entry -> sign -> challenge -> save pass.
Future<_HandshakeAttempt> _attemptHandshake({
  required String serverId,
  required IdentityData identity,
  required String passport,
  required IdentityCrypto crypto,
  String? invitePin,
}) async {
  final service = ServerEntryService();

  try {
    final challenge = await service.serverEntry(
      serverId: serverId,
      passport: passport,
      userId: identity.identityId,
      invitePin: invitePin,
    );

    // The challenge dies in 60s; a slow round trip or a stalled signing key
    // can outrun it, and the server would answer 401/410 anyway. Fail with a
    // clear outcome instead of a confusing "invalid challenge".
    if (challenge.isExpired) {
      return _HandshakeAttempt(ServerConnectResult.challengeExpired());
    }

    final Uint8List signature;
    try {
      signature = await crypto.sign(challenge.challengeBytes);
    } catch (e) {
      return _HandshakeAttempt(
        ServerConnectResult.failed('sign_challenge', e.toString()),
      );
    }

    final SignInReturn signIn;
    try {
      signIn = await service.serverChallenge(
        serverId: serverId,
        challengeId: challenge.challengeId,
        signature: signature,
      );
    } on PassportRejectedException catch (e) {
      if (e.statusCode == 410) {
        return _HandshakeAttempt(ServerConnectResult.challengeExpired());
      }
      return _HandshakeAttempt(ServerConnectResult.passportRejected(e.message));
    }

    try {
      await ApiClient.saveTokens(
        serverId: serverId,
        accessToken: signIn.accessToken,
        refreshToken: signIn.refreshToken,
      );
    } catch (e) {
      return _HandshakeAttempt(
        ServerConnectResult.failed('save_tokens', e.toString()),
      );
    }

    return _HandshakeAttempt(ServerConnectResult.success(signIn));
  } on PassportRejectedException catch (e) {
    // 403 is the peer saying the passport itself is no good. Peers that
    // predate the 403 mapping answer 500 instead (Null-KIB let
    // verify_passport's ValueError escape), so treat both as "re-mint me".
    final retryWithNewPassport = e.statusCode == 403 || e.statusCode == 500;
    return _HandshakeAttempt(
      ServerConnectResult.passportRejected(e.message),
      usedUpPassportRetry: retryWithNewPassport,
    );
  } on DioException catch (e) {
    return _HandshakeAttempt(
      ServerConnectResult.failed(
        'server_entry',
        e.message ?? 'Network request failed',
      ),
    );
  } catch (e) {
    return _HandshakeAttempt(
      ServerConnectResult.failed('unknown', e.toString()),
    );
  }
}

/// One handshake pass plus whether it ended in a way worth re-minting the
/// passport for.
class _HandshakeAttempt {
  final ServerConnectResult result;

  /// True when this failure was caused by the passport and the caller should
  /// re-mint it and try once more.
  final bool usedUpPassportRetry;

  const _HandshakeAttempt(this.result, {this.usedUpPassportRetry = false});
}
