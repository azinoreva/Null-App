import 'package:flutter/material.dart';

import '../../engine/functions/settings/settings.dart';
import '../../widgets/app_theme.dart';
import 'settings_widgets.dart';

/// "Storage" leaf page: media retention, disk usage and backups.
class StorageSettingsScreen extends StatelessWidget {
  const StorageSettingsScreen({super.key});

  void _openViewStorage() {
    // TODO: navigate to storage usage details.
  }

  void _openBackup() {
    // TODO: navigate to the backup flow.
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
          icon: Icons.storage_outlined,
          title: 'Storage',
          children: [
            SettingsNavRow(
              theme: theme,
              icon: Icons.storage_outlined,
              title: 'View Storage',
              subtitle: 'Check your data usage and cache.',
              onTap: _openViewStorage,
            ),
            SettingsToggleRow(
              theme: theme,
              icon: Icons.timer_outlined,
              title: 'Ephemeral Updates',
              subtitle: 'Auto-delete temporary media files.',
              value: settings.ephemeralUpdates,
              onChanged: (v) => settings.setEphemeralUpdates(v),
            ),
            SettingsNavRow(
              theme: theme,
              icon: Icons.cloud_upload_outlined,
              title: 'Backup',
              subtitle: 'Secure your messages in the cloud.',
              onTap: _openBackup,
            ),
          ],
        );
      },
    );
  }
}