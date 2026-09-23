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