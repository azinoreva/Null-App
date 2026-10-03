import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart' show appServerConnections;
import '../../screens/login_screen.dart';
import 'main_server_client.dart';

/// Global navigator key so non-widget code (Dio interceptors, SSE handlers)
/// can trigger navigation back to the sign-in screen on auth failure.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Clears the main-server (login) credentials and the signed-in flag, tears
/// down any live SSE subscriptions, and routes the user to the sign-in
/// screen.
///
/// Safe to call from anywhere (Dio interceptors, background tasks, logout,
/// ...); if no navigator is mounted yet the flags/tokens are still cleared
/// so the next launch lands on the login screen.
Future<void> redirectToLogin() async {
  await MainServerClient.clearTokens();

  final service = appServerConnections;
  if (service != null) {
    service.stop();
    appServerConnections = null;
  }

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_logged_in', false);

  final navigator = rootNavigatorKey.currentState;
  if (navigator == null) return;
  navigator.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}

/// Whether [serverId] names the main/authority server — the one whose tokens
/// come from signing in, as opposed to the per-server tokens minted by the
/// passport/challenge handshake.
///
/// Server ids are arbitrary (`server_1`, `server_SHRU`, a uuid — whatever the
/// directory hands out), so this is a comparison against the `SERVER` value in
/// `.env`, never a shape or a prefix. Everything that behaves differently for
/// the main server must go through here rather than testing ids itself.
bool isMainServerId(String serverId) => serverId == MainServerClient.serverId;

/// The app's single answer to "`serverId` refused our credentials".
///
/// Only the main server can end the session: its tokens *are* the login, so
/// when they are gone the user genuinely has to sign in again. Every other
/// server holds an independent pair obtained through the passport handshake,
/// and one of those refusing says nothing about the account — the user is still
/// signed in and still reachable on the main server. Signing them out because
/// a peer rotated a token, was reinstalled, or lost its key would be wrong.
///
/// The peer's tokens are deliberately left in place: the failure has already
/// been through a refresh, and keeping the pair means a later attempt (or a
/// fresh passport exchange) can still use it. Callers are expected to have
/// stopped retrying on their own by the time this runs.
Future<void> respondToServerAuthFailure(String serverId) async {
  if (!isMainServerId(serverId)) return;
  await redirectToLogin();
}

/// [respondToServerAuthFailure] as a callback for
/// `ApiClient.registerServer(onAuthFailure:)`, which wants a `VoidCallback`.
VoidCallback serverAuthFailureCallbackFor(String serverId) =>
    () => unawaited(respondToServerAuthFailure(serverId));
