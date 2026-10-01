import 'package:flutter/material.dart';

import '../engine/network/auth_failure_handler.dart';
import '../widgets/app_theme.dart';
import 'settings/notifications_settings.dart';
import 'settings/privacy_settings.dart';
import 'settings/profile_settings.dart';
import 'settings/security_settings.dart';
import 'settings/servers_settings.dart';
import 'settings/settings_widgets.dart';
import 'settings/storage_settings.dart';

/// Settings hub: one row per area, each pushing its own screen.
///
/// The individual rows (toggles, nav rows, the profile editor) now live in
/// the leaf screens under `screens/settings/`, so this file only decides what
/// the areas are and what order they appear in.
class SettingsScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const SettingsScreen({super.key, this.onBack});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _handleLogout() async {
    await redirectToLogin();
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

    return SettingsScaffold(
      icon: Icons.settings_outlined,
      title: 'Settings',
      onBack: onBack,
      children: [
        SettingsNavRow(
          theme: theme,
          icon: Icons.notifications_none,
          title: 'Notifications',
          subtitle: 'Sounds, vibration and auto-replies.',
          onTap: () => _open(context, const NotificationsSettingsScreen()),
        ),
        SettingsNavRow(
          theme: theme,
          icon: Icons.tune,
          title: 'Privacy & Appearance',
          subtitle: 'What others see, plus light and dark theme.',
          onTap: () => _open(context, const PrivacySettingsScreen()),
        ),
        SettingsNavRow(
          theme: theme,
          icon: Icons.person_outline,
          title: 'Edit Profile',
          subtitle: 'Photo, nickname, title and bio.',
          onTap: () => _open(context, const ProfileSettingsScreen()),
        ),
        SettingsNavRow(
          theme: theme,
          icon: Icons.shield_outlined,
          title: 'Security',
          subtitle: 'Password, biometrics and account recovery.',
          onTap: () => _open(context, const SecuritySettingsScreen()),
        ),
        SettingsNavRow(
          theme: theme,
          icon: Icons.dns_outlined,
          title: 'Servers',
          subtitle: 'Networks and groups you are connected to.',
          onTap: () => _open(context, const ServersSettingsScreen()),
        ),
        SettingsNavRow(
          theme: theme,
          icon: Icons.storage_outlined,
          title: 'Storage',
          subtitle: 'Media, cache and backups.',
          onTap: () => _open(context, const StorageSettingsScreen()),
        ),
        const SizedBox(height: 24.0),
        SettingsLogoutButton(
          theme: theme,
          onTap: _handleLogout,
        ),
      ],
    );
  }
}