import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../screens/login_screen.dart';

/// Global navigator key so non-widget code (Dio interceptors, SSE handlers)
/// can trigger navigation back to the sign-in screen on auth failure.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Clears the signed-in flag and routes the user to the sign-in screen.
///
/// Safe to call from anywhere (Dio interceptors, background tasks, ...);
/// if no navigator is mounted yet the flag is still cleared so the next
/// launch lands on the login screen.
Future<void> redirectToLogin() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_logged_in', false);

  final navigator = rootNavigatorKey.currentState;
  if (navigator == null) return;
  navigator.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}