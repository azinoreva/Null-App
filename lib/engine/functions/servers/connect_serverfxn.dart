// Ties together: security_token.dart (reads the passport saved at signup),
// identity_queries.dart (reads the local user id), enter_server.dart (the
// POST /api/server-entry exchange), and api_client.dart (persists the
// resulting access/refresh token pair scoped per server_id).

import 'package:dio/dio.dart';

import '../../database/app_database.dart';
import '../../network/api_client.dart';
import '../../network/servers/enter_server.dart';
import '../../securestore/security_token.dart';

/// How [connectServerUsingPassport] concluded.
enum ServerConnectOutcome { success, noPassport, noIdentity, failed }

/// Result of [connectServerUsingPassport]. Check [outcome] first:
/// - [ServerConnectOutcome.success] — [signIn] holds the verified token pair.
/// - [ServerConnectOutcome.noPassport] — no passport is saved in secure
///   storage.
/// - [ServerConnectOutcome.noIdentity] — the local database has no Identity
///   row to read a user id from.
/// - [ServerConnectOutcome.failed] — [failedStep] and [errorMessage] describe
///   what went wrong.
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
      case ServerConnectOutcome.failed:
        return 'ServerConnectResult.failed(step: $failedStep, error: $errorMessage)';
    }
  }
}

/// Connects to [serverId] using the passport saved at registration time:
/// 1. Reads the passport (`passport`) from secure storage.
/// 2. Reads the local user id (the `Identity` row's `identityId`) from the
///    database.
/// 3. Sends both to the server via POST /api/server-entry.
/// 4. Persists the returned access/refresh token pair under server-scoped
///    keys (`access_token_<serverId>`, `refresh_token_<serverId>`) so
///    ApiClient authenticates against that server from now on.
///
/// The server must already be registered with ApiClient (see
/// ApiClient.registerServer) — that registration is what lets the request
/// resolve against the server's base URL. When offline or on any HTTP error
/// the function returns [ServerConnectOutcome.failed] with a failed step
/// ('network_call', 'save_tokens', or 'unknown') instead of throwing.
Future<ServerConnectResult> connectServerUsingPassport({
  required String serverId,
  required AppDatabase database,
}) async {
  final passport = await getPassport();
  if (passport == null || passport.isEmpty) {
    return ServerConnectResult.noPassport();
  }

  final identity = await database.identityDao.getCurrentIdentityOrNull();
  if (identity == null) {
    return ServerConnectResult.noIdentity();
  }

  try {
    final signIn = await ServerEntryService().serverEntry(
      serverId: serverId,
      passport: passport,
      userId: identity.identityId,
    );

    try {
      await ApiClient.saveTokens(
        serverId: serverId,
        accessToken: signIn.accessToken,
        refreshToken: signIn.refreshToken,
      );
    } catch (e) {
      return ServerConnectResult.failed('save_tokens', e.toString());
    }

    return ServerConnectResult.success(signIn);
  } on DioException catch (e) {
    return ServerConnectResult.failed(
      'network_call',
      e.message ?? 'Network request failed',
    );
  } catch (e) {
    return ServerConnectResult.failed('unknown', e.toString());
  }
}