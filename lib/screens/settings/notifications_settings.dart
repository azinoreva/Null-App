import 'package:flutter/material.dart';

import '../../engine/functions/settings/settings.dart';
import '../../widgets/app_theme.dart';
import '../modals/automatic_messages.dart';
import 'settings_widgets.dart';

/// "Notifications" leaf page: what the app is allowed to interrupt you with.
class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({super.key});

  void _openAutomaticMessageEditor(
    BuildContext context,
    AppSettings settings,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AutomaticMessageModal(
        initialMessage: settings.automaticMessage,
        initialMedia: settings.automaticMedia,
        onSave: (message, media) async {
          await settings.setAutomaticMessage(message);
          await settings.setAutomaticMedia(media);
        },
      ),
    );
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
          icon: Icons.notifications_none,
          title: 'Notifications',
          children: [
            SettingsSectionHeader(title: 'Alerts', theme: theme),
            SettingsToggleRow(
              theme: theme,
              icon: Icons.notifications_none,
              title: 'Push Notifications',
              subtitle: 'Receive alerts for new messages.',
              value: settings.pushNotifications,
              onChanged: (v) => settings.setPushNotifications(v),
            ),
            SettingsToggleRow(
              theme: theme,
              icon: Icons.volume_up_outlined,
              title: 'Message Sound',
              subtitle: 'Play a sound for incoming texts.',
              value: settings.messageSound,
              onChanged: (v) => settings.setMessageSound(v),
            ),
            SettingsToggleRow(
              theme: theme,
              icon: Icons.vibration,
              title: 'Vibration',
              subtitle: 'Haptic feedback for notifications.',
              value: settings.vibration,
              onChanged: (v) => settings.setVibration(v),
            ),

            const SettingsSectionGap(),
            SettingsSectionHeader(title: 'When Away', theme: theme),
            SettingsNavRow(
              theme: theme,
              icon: Icons.chat_bubble_outline,
              title: 'Set Automatic Message',
              subtitle: 'Send auto-replies when busy.',
              onTap: () => _openAutomaticMessageEditor(context, settings),
            ),
          ],
        );
      },
    );
  }
}