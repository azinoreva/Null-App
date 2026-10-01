import 'package:flutter/material.dart';

import '../../widgets/app_theme.dart';

/// Chrome and row widgets shared by every settings page.
///
/// [SettingsScaffold] gives a page the back/header bar, divider and scrollable
/// body. The main `SettingsScreen` is just one of these with area rows in it,
/// so the header looks identical on the hub and on every leaf page.
class SettingsScaffold extends StatelessWidget {
  const SettingsScaffold({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
    this.onBack,
    this.floatingActionButton,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onBack;
  final Widget? floatingActionButton;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

    return Material(
      color: theme.background,
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: onBack ?? () => Navigator.of(context).maybePop(),
                      child: Icon(Icons.arrow_back, color: theme.textInputColor),
                    ),
                    const SizedBox(width: 8.0),
                    Icon(icon, color: theme.textInputColor),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.getTextStyle(
                          context,
                          AppTextType.title,
                          color: theme.textInputColor,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: theme.border, height: 1.0),
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 100.0),
                  children: children,
                ),
              ),
            ],
          ),
          if (floatingActionButton != null)
            Positioned(
              right: 16.0,
              bottom: 16.0,
              child: floatingActionButton!,
            ),
        ],
      ),
    );
  }
}

/// Uppercased label that introduces a group of rows on a leaf page.
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({
    super.key,
    required this.title,
    required this.theme,
  });

  final String title;
  final AppColorScheme theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 4.0),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.getTextStyle(
          context,
          AppTextType.tiny,
          color: AppColors.mutedSlate,
        ).copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}

/// Vertical gap between two groups of rows.
class SettingsSectionGap extends StatelessWidget {
  const SettingsSectionGap({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(height: 20.0);
}

class SettingsIconBadge extends StatelessWidget {
  const SettingsIconBadge({
    super.key,
    required this.icon,
    required this.theme,
    this.isDestructive = false,
  });

  final IconData icon;
  final AppColorScheme theme;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final tint = isDestructive ? AppColors.alertRed : theme.primaryGreen;
    return Container(
      width: 36.0,
      height: 36.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.withAlpha(35),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Icon(icon, size: 18.0, color: tint),
    );
  }
}

/// Icon + title + subtitle with a switch on the trailing edge.
class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    super.key,
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final AppColorScheme theme;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsIconBadge(icon: icon, theme: theme),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.body,
                    color: theme.textInputColor,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.tiny,
                    color: AppColors.mutedSlate,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: theme.primaryGreen,
          ),
        ],
      ),
    );
  }
}

/// Icon + title + subtitle with a chevron that opens something.
class SettingsNavRow extends StatelessWidget {
  const SettingsNavRow({
    super.key,
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.isAccent = false,
  });

  final AppColorScheme theme;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    final titleColor = isDestructive
        ? AppColors.alertRed
        : isAccent
            ? theme.primaryGreen
            : theme.textInputColor;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsIconBadge(
              icon: icon,
              theme: theme,
              isDestructive: isDestructive,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.getTextStyle(
                      context,
                      AppTextType.body,
                      color: titleColor,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    style: AppTypography.getTextStyle(
                      context,
                      AppTextType.tiny,
                      color: AppColors.mutedSlate,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.mutedSlate),
          ],
        ),
      ),
    );
  }
}

/// Icon + title + subtitle with a Light/Dark segmented control on the end.
class SettingsThemeToggleRow extends StatelessWidget {
  const SettingsThemeToggleRow({
    super.key,
    required this.theme,
    required this.isDark,
    required this.onChanged,
  });

  final AppColorScheme theme;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsIconBadge(
            icon: isDark
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined,
            theme: theme,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App theme',
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.body,
                    color: theme.textInputColor,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Switch between light and dark mode.',
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.tiny,
                    color: AppColors.mutedSlate,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          _ThemeSegmentedToggle(
            theme: theme,
            isDark: isDark,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ThemeSegmentedToggle extends StatelessWidget {
  const _ThemeSegmentedToggle({
    required this.theme,
    required this.isDark,
    required this.onChanged,
  });

  final AppColorScheme theme;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: theme.border,
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeSegment(
            label: 'Light',
            icon: Icons.light_mode_outlined,
            active: !isDark,
            theme: theme,
            onTap: () => onChanged(false),
          ),
          const SizedBox(width: 3.0),
          _ThemeSegment(
            label: 'Dark',
            icon: Icons.dark_mode_outlined,
            active: isDark,
            theme: theme,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ThemeSegment extends StatelessWidget {
  const _ThemeSegment({
    required this.label,
    required this.icon,
    required this.active,
    required this.theme,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final AppColorScheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = active ? theme.background : AppColors.mutedSlate;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: active ? theme.textInputColor : Colors.transparent,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.0, color: foreground),
            const SizedBox(width: 4.0),
            Text(
              label,
              style: AppTypography.getTextStyle(
                context,
                AppTextType.tiny,
                color: foreground,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slider for how long the app stays unlocked (null = never re-lock).
class SettingsLockoutTimeoutSlider extends StatelessWidget {
  const SettingsLockoutTimeoutSlider({
    super.key,
    required this.theme,
    required this.lockTimerSeconds,
    required this.onChanged,
  });

  final AppColorScheme theme;
  final int? lockTimerSeconds;
  final ValueChanged<int?> onChanged;

  static const int _maxMinutes = 60;

  @override
  Widget build(BuildContext context) {
    final minutes = ((lockTimerSeconds ?? 0) / 60).round().clamp(0, _maxMinutes);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lockout Timeout',
                style: AppTypography.getTextStyle(
                  context,
                  AppTextType.body,
                  color: theme.textInputColor,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                minutes == 0 ? 'Off' : '$minutes mins',
                style: AppTypography.getTextStyle(
                  context,
                  AppTextType.tiny,
                  color: AppColors.mutedSlate,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: theme.primaryGreen,
              inactiveTrackColor: theme.border,
              thumbColor: theme.primaryGreen,
              overlayColor: theme.primaryGreen.withAlpha(40),
            ),
            child: Slider(
              value: minutes.toDouble(),
              min: 0,
              max: _maxMinutes.toDouble(),
              divisions: 12,
              onChanged: (value) {
                final newMinutes = value.round();
                onChanged(newMinutes == 0 ? null : newMinutes * 60);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width red sign-out button. Lives on the hub rather than a leaf page.
class SettingsLogoutButton extends StatelessWidget {
  const SettingsLogoutButton({
    super.key,
    required this.theme,
    required this.onTap,
  });

  final AppColorScheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        decoration: BoxDecoration(
          color: AppColors.alertRed.withAlpha(30),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: AppColors.alertRed.withAlpha(80)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 18.0, color: AppColors.alertRed),
            const SizedBox(width: 8.0),
            Text(
              'Log Out',
              style: AppTypography.getTextStyle(
                context,
                AppTextType.body,
                color: AppColors.alertRed,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}