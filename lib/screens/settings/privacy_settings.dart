import 'package:flutter/material.dart';

import '../../engine/functions/settings/settings.dart';
import '../../widgets/app_theme.dart';
import '../modals/choose_interests.dart';
import 'settings_widgets.dart';

/// "Privacy & Appearance" leaf page: what you broadcast to others, plus how
/// the app looks.
class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  void _openUpdatesPreferences(BuildContext context, AppSettings settings) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InterestSelectionModal(
        initialSelected: settings.feedControl,
        onDone: settings.setFeedControl,
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
          icon: Icons.tune,
          title: 'Privacy & Appearance',
          children: [
            SettingsSectionHeader(title: 'Visibility', theme: theme),
            SettingsToggleRow(
              theme: theme,
              icon: Icons.keyboard_alt_outlined,
              title: 'Typing Indicator',
              subtitle: 'Show others when you are composing.',
              value: settings.typingIndicator,
              onChanged: (v) => settings.setTypingIndicator(v),
            ),
            SettingsToggleRow(
              theme: theme,
              icon: Icons.person_add_alt,
              title: 'Allow Friend Requests',
              subtitle: 'Let others send you connection requests from groups.',
              value: settings.allowFriendRequests,
              onChanged: (v) => settings.setAllowFriendRequests(v),
            ),
            SettingsNavRow(
              theme: theme,
              icon: Icons.dynamic_feed_outlined,
              title: 'Updates Preferences',
              subtitle: 'Control what you see in your feeds.',
              onTap: () => _openUpdatesPreferences(context, settings),
            ),
            SettingsToggleRow(
              theme: theme,
              icon: Icons.sync,
              title: 'Auto Sync',
              subtitle: 'Synchronize chats across your contacts automatically.',
              value: settings.autoSync,
              onChanged: (v) => settings.setAutoSync(v),
            ),

            const SettingsSectionGap(),
            SettingsSectionHeader(title: 'Appearance', theme: theme),
            SettingsThemeToggleRow(
              theme: theme,
              isDark: settings.isDarkMode,
              onChanged: (v) => settings.setIsDarkMode(v),
            ),
          ],
        );
      },
    );
  }
}