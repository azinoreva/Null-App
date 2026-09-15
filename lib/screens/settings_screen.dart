import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/app_theme.dart';
import '../engine/functions/settings/settings.dart';
import '../engine/database/queries/identity_queries.dart';
import '../engine/media_handling/dicebear.dart';
import '../engine/media_handling/media_storage.dart';
import '../engine/network/auth_failure_handler.dart';
import '../state/providers.dart';
import 'modals/automatic_messages.dart';
import 'modals/change_password.dart';
import 'modals/choose_interests.dart';

/// Settings screen, driven entirely by [AppSettings].
///
/// Every toggle/slider reads from and writes straight through to
/// `AppSettings.instance` (which already persists to SharedPreferences and
/// calls `notifyListeners()` for you) - the screen just needs to rebuild
/// when it changes, which is what the [ListenableBuilder] below does.
///
/// Nickname / Title / Bio are the exception: they're edited locally and
/// only written back to [AppSettings] when the bottom "Save" button is
/// tapped, since you don't want to persist on every keystroke.
///
/// Rows that don't correspond to anything in [AppSettings] (Change
/// Password, Blocked Users, Migrate Account, Recovery Contacts, Recovery
/// Management, Delete All Data, Connected Servers, Add a Server, View
/// Storage, Backup, Set Automatic Message, Updates Preferences) are wired
/// to empty stub functions with `// TODO` markers so you can hook up
/// navigation later.
class SettingsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const SettingsScreen({super.key, this.onBack});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final AppSettings _settings;
  late final TextEditingController _nicknameController;
  late final TextEditingController _titleController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _settings = AppSettings.instance;
    _nicknameController = TextEditingController(text: _settings.nickname);
    _titleController = TextEditingController(text: _settings.title ?? '');
    _bioController = TextEditingController(text: _settings.bio ?? '');
    unawaited(_ensureProfilePicture());
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _titleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // ---- Stub functions for rows with no backing AppSettings field ----
  void _openChangePassword() {
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

  void _openAutomaticMessageEditor() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AutomaticMessageModal(
        initialMessage: _settings.automaticMessage,
        initialMedia: _settings.automaticMedia,
        onSave: (message, media) async {
          await _settings.setAutomaticMessage(message);
          await _settings.setAutomaticMedia(media);
        },
      ),
    );
  }

  void _openUpdatesPreferences() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InterestSelectionModal(
        initialSelected: _settings.feedControl,
        onDone: _settings.setFeedControl,
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
    // TODO: show a confirmation dialog, then call `_settings.resetAll()`
    // plus whatever wipes the rest of the app's data.
  }

  void _openConnectedServers() {
    // TODO: navigate to the connected servers list.
  }

  void _openAddServer() {
    // TODO: navigate to the add-a-server flow.
  }

  void _openViewStorage() {
    // TODO: navigate to storage usage details.
  }

  void _openBackup() {
    // TODO: navigate to the backup flow.
  }

  Future<void> _pickProfilePicture() async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.image);
      final identityDao = ref.read(appDatabaseProvider).identityDao;
      final identity = await identityDao.getCurrentIdentityOrNull();
      if (identity == null) return;

      if (result.isEmpty || result.single.path == null) {
        await _ensureProfilePicture();
        return;
      }

      final avatarPath = await MediaStorageService.copyMediaToInternalStorage(
        result.single.path!,
      );
      await _persistProfilePicture(identityDao, avatarPath);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save profile picture: $error')),
      );
    }
  }

  Future<void> _ensureProfilePicture() async {
    try {
      final identityDao = ref.read(appDatabaseProvider).identityDao;
      final identity = await identityDao.getCurrentIdentityOrNull();
      if (identity == null) return;

      final existing = _settings.profilePicture ?? identity.avatar;
      if (existing != null && existing.isNotEmpty) {
        if (_settings.profilePicture != existing) {
          await _settings.setProfilePicture(existing);
        }
        return;
      }

      final avatar = await DicebearService().getAvatarData(identity.identityId);
      final avatarPath = await MediaStorageService.saveBytesToInternalStorage(
        avatar.bytes,
        extension: '.png',
      );
      await _persistProfilePicture(identityDao, avatarPath);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create profile picture: $error')),
      );
    }
  }

  Future<void> _persistProfilePicture(
    IdentityDao identityDao,
    String avatarPath,
  ) async {
    await identityDao.setAvatar(avatarPath);
    await _settings.setProfilePicture(avatarPath);
  }
  // ---------------------------------------------------------------------

  Future<void> _handleLogout() async {
    await redirectToLogin();
  }

  Future<void> _handleSaveProfile() async {
    await Future.wait([
      _settings.setNickname(_nicknameController.text),
      _settings.setTitle(_titleController.text),
      _settings.setBio(_bioController.text),
    ]);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        return Material(
          color: theme.background,
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: widget.onBack ?? () => Navigator.of(context).maybePop(),
                          child: Icon(Icons.arrow_back, color: theme.textInputColor),
                        ),
                        const SizedBox(width: 8.0),
                        Icon(Icons.settings_outlined, color: theme.textInputColor),
                        const SizedBox(width: 8.0),
                        Text(
                          'Settings',
                          style: AppTypography.getTextStyle(
                            context,
                            AppTextType.title,
                            color: theme.textInputColor,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: theme.border, height: 1.0),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 100.0),
                      children: [
                        _SectionHeader(title: 'Account Preferences', theme: theme),
                        _ToggleRow(
                          theme: theme,
                          icon: Icons.sync,
                          title: 'Auto Sync',
                          subtitle: 'Synchronize chats across your contacts automatically.',
                          value: _settings.autoSync,
                          onChanged: (v) => _settings.setAutoSync(v),
                        ),
                        _ToggleRow(
                          theme: theme,
                          icon: Icons.keyboard_alt_outlined,
                          title: 'Typing Indicator',
                          subtitle: 'Show others when you are composing.',
                          value: _settings.typingIndicator,
                          onChanged: (v) => _settings.setTypingIndicator(v),
                        ),
                        _ToggleRow(
                          theme: theme,
                          icon: Icons.notifications_none,
                          title: 'Push Notifications',
                          subtitle: 'Receive alerts for new messages.',
                          value: _settings.pushNotifications,
                          onChanged: (v) => _settings.setPushNotifications(v),
                        ),
                        _ToggleRow(
                          theme: theme,
                          icon: Icons.volume_up_outlined,
                          title: 'Message Sound',
                          subtitle: 'Play a sound for incoming texts.',
                          value: _settings.messageSound,
                          onChanged: (v) => _settings.setMessageSound(v),
                        ),
                        _ToggleRow(
                          theme: theme,
                          icon: Icons.vibration,
                          title: 'Vibration',
                          subtitle: 'Haptic feedback for notifications.',
                          value: _settings.vibration,
                          onChanged: (v) => _settings.setVibration(v),
                        ),
                        _NavRow(
                          theme: theme,
                          icon: Icons.chat_bubble_outline,
                          title: 'Set Automatic Message',
                          subtitle: 'Send auto-replies when busy.',
                          onTap: _openAutomaticMessageEditor,
                        ),
                        _ToggleRow(
                          theme: theme,
                          icon: Icons.person_add_alt,
                          title: 'Allow Friend Requests',
                          subtitle: 'Let others send you connection requests from groups.',
                          value: _settings.allowFriendRequests,
                          onChanged: (v) => _settings.setAllowFriendRequests(v),
                        ),
                        _NavRow(
                          theme: theme,
                          icon: Icons.dynamic_feed_outlined,
                          title: 'Updates Preferences',
                          subtitle: 'Control what you see in your feeds.',
                          onTap: _openUpdatesPreferences,
                        ),
                        _ThemeToggleRow(
                          theme: theme,
                          isDark: _settings.isDarkMode,
                          onChanged: (v) => _settings.setIsDarkMode(v),
                        ),

                        const SizedBox(height: 20.0),
                        _SectionHeader(title: 'Edit Profile', theme: theme),
                        _ProfileEditor(
                          theme: theme,
                          profilePicture: _settings.profilePicture,
                          onPickPicture: _pickProfilePicture,
                          nicknameController: _nicknameController,
                          titleController: _titleController,
                          bioController: _bioController,
                        ),

                        const SizedBox(height: 20.0),
                        _SectionHeader(title: 'Security', theme: theme),
                        _NavRow(
                          theme: theme,
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          subtitle: 'Update your login credentials.',
                          onTap: _openChangePassword,
                        ),
                        _ToggleRow(
                          theme: theme,
                          icon: Icons.fingerprint,
                          title: 'Biometric Toggle',
                          subtitle: 'Use fingerprint or face ID for login.',
                          value: _settings.useBiometrics,
                          onChanged: (v) => _settings.setUseBiometrics(v),
                        ),
                        _NavRow(
                          theme: theme,
                          icon: Icons.block_outlined,
                          title: 'Blocked Users',
                          subtitle: 'Manage people you have restricted.',
                          onTap: _openBlockedUsers,
                        ),
                        _NavRow(
                          theme: theme,
                          icon: Icons.phone_iphone_outlined,
                          title: 'Migrate Account to New Device',
                          subtitle: 'Transfer your data to another device.',
                          onTap: _openMigrateAccount,
                        ),
                        _NavRow(
                          theme: theme,
                          icon: Icons.people_outline,
                          title: 'Recovery Contacts',
                          subtitle: 'Trusted contacts to help you unlock.',
                          onTap: _openRecoveryContacts,
                        ),
                        _NavRow(
                          theme: theme,
                          icon: Icons.settings_backup_restore,
                          title: 'Recovery Management',
                          subtitle: 'Configure secondary access methods.',
                          onTap: _openRecoveryManagement,
                        ),
                        _NavRow(
                          theme: theme,
                          icon: Icons.delete_outline,
                          title: 'Delete All Data',
                          subtitle: 'Permanently erase your account info.',
                          onTap: _confirmDeleteAllData,
                          isDestructive: true,
                        ),
                        _ToggleRow(
                          theme: theme,
                          icon: Icons.shield_outlined,
                          title: 'Require Password Immediately',
                          subtitle: "Lock app as soon as it's closed.",
                          value: _settings.appLock,
                          onChanged: (v) => _settings.setAppLock(v),
                        ),
                        _LockoutTimeoutSlider(
                          theme: theme,
                          lockTimerSeconds: _settings.lockTimer,
                          onChanged: (seconds) => _settings.setLockTimer(seconds),
                        ),

                        const SizedBox(height: 20.0),
                        _SectionHeader(title: 'Servers', theme: theme),
                        _NavRow(
                          theme: theme,
                          icon: Icons.dns_outlined,
                          title: 'Connected Servers',
                          subtitle: 'View your active server connections.',
                          onTap: _openConnectedServers,
                        ),
                        _NavRow(
                          theme: theme,
                          icon: Icons.add_circle_outline,
                          title: 'Add a Server',
                          subtitle: 'Join a new network or group.',
                          onTap: _openAddServer,
                          isAccent: true,
                        ),

                        const SizedBox(height: 20.0),
                        _SectionHeader(title: 'Storage', theme: theme),
                        _NavRow(
                          theme: theme,
                          icon: Icons.storage_outlined,
                          title: 'View Storage',
                          subtitle: 'Check your data usage and cache.',
                          onTap: _openViewStorage,
                        ),
                        _ToggleRow(
                          theme: theme,
                          icon: Icons.timer_outlined,
                          title: 'Ephemeral Updates',
                          subtitle: 'Auto-delete temporary media files.',
                          value: _settings.ephemeralUpdates,
                          onChanged: (v) => _settings.setEphemeralUpdates(v),
                        ),
                        _NavRow(
                          theme: theme,
                          icon: Icons.cloud_upload_outlined,
                          title: 'Backup',
                          subtitle: 'Secure your messages in the cloud.',
                          onTap: _openBackup,
                        ),

                        const SizedBox(height: 24.0),
                        _LogoutButton(
                          theme: theme,
                          onTap: _handleLogout,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Floating Save button (saves nickname / title / bio)
              Positioned(
                right: 16.0,
                bottom: 16.0,
                child: FloatingActionButton.extended(
                  onPressed: _handleSaveProfile,
                  backgroundColor: theme.primaryGreen,
                  icon: Icon(Icons.save_outlined, color: theme.buttonContentColor),
                  label: Text(
                    'Save',
                    style: AppTypography.getTextStyle(
                      context,
                      AppTextType.body,
                      color: theme.buttonContentColor,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final AppColorScheme theme;

  const _SectionHeader({required this.title, required this.theme});

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

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final AppColorScheme theme;
  final bool isDestructive;

  const _IconBadge({
    required this.icon,
    required this.theme,
    this.isDestructive = false,
  });

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

class _ToggleRow extends StatelessWidget {
  final AppColorScheme theme;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBadge(icon: icon, theme: theme),
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
            activeColor: theme.primaryGreen,
          ),
        ],
      ),
    );
  }
}

class _ThemeToggleRow extends StatelessWidget {
  final AppColorScheme theme;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ThemeToggleRow({
    required this.theme,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBadge(
            icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
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
  final AppColorScheme theme;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ThemeSegmentedToggle({
    required this.theme,
    required this.isDark,
    required this.onChanged,
  });

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
  final String label;
  final IconData icon;
  final bool active;
  final AppColorScheme theme;
  final VoidCallback onTap;

  const _ThemeSegment({
    required this.label,
    required this.icon,
    required this.active,
    required this.theme,
    required this.onTap,
  });

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

class _NavRow extends StatelessWidget {
  final AppColorScheme theme;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isAccent;

  const _NavRow({
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.isAccent = false,
  });

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
            _IconBadge(icon: icon, theme: theme, isDestructive: isDestructive),
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

class _LockoutTimeoutSlider extends StatelessWidget {
  final AppColorScheme theme;
  final int? lockTimerSeconds;
  final ValueChanged<int?> onChanged;

  const _LockoutTimeoutSlider({
    required this.theme,
    required this.lockTimerSeconds,
    required this.onChanged,
  });

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

class _ProfileEditor extends StatelessWidget {
  final AppColorScheme theme;
  final String? profilePicture;
  final VoidCallback onPickPicture;
  final TextEditingController nicknameController;
  final TextEditingController titleController;
  final TextEditingController bioController;

  const _ProfileEditor({
    required this.theme,
    required this.profilePicture,
    required this.onPickPicture,
    required this.nicknameController,
    required this.titleController,
    required this.bioController,
  });

  InputDecoration _decoration(BuildContext context) {
    return InputDecoration(
      filled: true,
      fillColor: theme.border.withAlpha(90),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.border.withAlpha(50),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 44.0,
                  backgroundColor: AppColors.neutralGray,
                  backgroundImage: profilePicture == null || profilePicture!.isEmpty
                    ? null
                    : (profilePicture!.startsWith('http://') ||
                        profilePicture!.startsWith('https://')
                      ? NetworkImage(profilePicture!)
                      : FileImage(File(profilePicture!)) as ImageProvider),
                  child: (profilePicture == null || profilePicture!.isEmpty)
                      ? const Icon(Icons.person, size: 40.0, color: AppColors.pureWhite)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: onPickPicture,
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: theme.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.background, width: 2.0),
                      ),
                      child: Icon(Icons.camera_alt, size: 16.0, color: theme.buttonContentColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            'Profile Picture',
            style: AppTypography.getTextStyle(
              context,
              AppTextType.body,
              color: theme.textInputColor,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Click to upload or take a new photo',
            style: AppTypography.getTextStyle(
              context,
              AppTextType.tiny,
              color: AppColors.mutedSlate,
            ),
          ),
          const SizedBox(height: 20.0),

          _FieldLabel(icon: Icons.person_outline, label: 'Nickname', theme: theme),
          const SizedBox(height: 6.0),
          TextField(
            controller: nicknameController,
            style: AppTypography.getTextStyle(context, AppTextType.body, color: theme.textInputColor),
            decoration: _decoration(context),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Visible to only users in groups and updates.',
            style: AppTypography.getTextStyle(context, AppTextType.tiny, color: AppColors.mutedSlate),
          ),
          const SizedBox(height: 16.0),

          _FieldLabel(icon: Icons.badge_outlined, label: 'Title', theme: theme),
          const SizedBox(height: 6.0),
          TextField(
            controller: titleController,
            style: AppTypography.getTextStyle(context, AppTextType.body, color: theme.textInputColor),
            decoration: _decoration(context),
          ),
          const SizedBox(height: 16.0),

          _FieldLabel(icon: Icons.description_outlined, label: 'Bio', theme: theme),
          const SizedBox(height: 6.0),
          TextField(
            controller: bioController,
            maxLines: 3,
            style: AppTypography.getTextStyle(context, AppTextType.body, color: theme.textInputColor),
            decoration: _decoration(context),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppColorScheme theme;

  const _FieldLabel({required this.icon, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.0, color: theme.primaryGreen),
        const SizedBox(width: 6.0),
        Text(
          label,
          style: AppTypography.getTextStyle(
            context,
            AppTextType.body,
            color: theme.textInputColor,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final AppColorScheme theme;
  final VoidCallback onTap;

  const _LogoutButton({required this.theme, required this.onTap});

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