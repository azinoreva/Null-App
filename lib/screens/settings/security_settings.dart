import 'package:flutter/material.dart';

import '../../engine/functions/settings/settings.dart';
import '../../widgets/app_theme.dart';
import '../modals/change_password.dart';
import 'settings_widgets.dart';

/// "Security" leaf page: credentials, app lock and account recovery.
class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  void _openChangePassword(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangePasswordModal(
        onSave: (currentPassword, newPassword) async {
          // The account API also requires a re-encrypted vault payload,
          // which is not available from the settings screen yet.
          return 'Password change service is not configured yet.';
        },
      ),
    );
  }

  void _openBlockedUsers() {
    // TODO: navigate to the blocked users list.
  }

  void _openMigrateAccount() {
    // TODO: navigate to the migrate-account flow.
  }

  void _openRecoveryContacts() {
    // TODO: navigate to recovery contacts management.
  }

  void _openRecoveryManagement() {
    // TODO: navigate to recovery management.
  }

  void _confirmDeleteAllData() {
    // TODO: show a confirmation dialog, then call `settings.resetAll()`
    // plus whatever wipes the rest of the app's data.
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;
    final settings = AppSettings.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return SettingsScaffold(
          icon: Icons.shield_outlined,
          title: 'Security',
          children: [
            SettingsSectionHeader(title: 'Sign In', theme: theme),
            SettingsNavRow(
              theme: theme,
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your login credentials.',
              onTap: () => _openChangePassword(context),
            ),
            SettingsToggleRow(
              theme: theme,
              icon: Icons.fingerprint,
              title: 'Biometric Toggle',
              subtitle: 'Use fingerprint or face ID for login.',
              value: settings.useBiometrics,
              onChanged: (v) => settings.setUseBiometrics(v),
            ),
            SettingsToggleRow(
              theme: theme,
              icon: Icons.shield_outlined,
              title: 'Require Password Immediately',
              subtitle: "Lock app as soon as it's closed.",
              value: settings.appLock,
              onChanged: (v) => settings.setAppLock(v),
            ),
            SettingsLockoutTimeoutSlider(
              theme: theme,
              lockTimerSeconds: settings.lockTimer,
              onChanged: (seconds) => settings.setLockTimer(seconds),
            ),

            const SettingsSectionGap(),
            SettingsSectionHeader(title: 'Account', theme: theme),
            SettingsNavRow(
              theme: theme,
              icon: Icons.block_outlined,
              title: 'Blocked Users',
              subtitle: 'Manage people you have restricted.',
              onTap: _openBlockedUsers,
            ),
            SettingsNavRow(
              theme: theme,
              icon: Icons.phone_iphone_outlined,
              title: 'Migrate Account to New Device',
              subtitle: 'Transfer your data to another device.',
              onTap: _openMigrateAccount,
            ),
            SettingsNavRow(
              theme: theme,
              icon: Icons.people_outline,
              title: 'Recovery Contacts',
              subtitle: 'Trusted contacts to help you unlock.',
              onTap: _openRecoveryContacts,
            ),
            SettingsNavRow(
              theme: theme,
              icon: Icons.settings_backup_restore,
              title: 'Recovery Management',
              subtitle: 'Configure secondary access methods.',
              onTap: _openRecoveryManagement,
            ),
            SettingsNavRow(
              theme: theme,
              icon: Icons.delete_outline,
              title: 'Delete All Data',
              subtitle: 'Permanently erase your account info.',
              onTap: _confirmDeleteAllData,
              isDestructive: true,
            ),
          ],
        );
      },
    );
  }
}