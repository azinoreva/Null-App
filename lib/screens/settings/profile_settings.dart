import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/database/queries/identity_queries.dart';
import '../../engine/functions/settings/settings.dart';
import '../../engine/media_handling/dicebear.dart';
import '../../engine/media_handling/media_storage.dart';
import '../../state/providers.dart';
import '../../widgets/app_theme.dart';
import 'settings_widgets.dart';

/// "Edit Profile" leaf page: photo, nickname, title and bio.
///
/// Nickname / Title / Bio are edited locally and only written back to
/// [AppSettings] when the floating "Save" button is tapped, since you don't
/// want to persist on every keystroke.
class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
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

  Future<void> _handleSaveProfile() async {
    final nickname = _nicknameController.text.trim();
    final title = _titleController.text.trim();
    final bio = _bioController.text.trim();

    await Future.wait([
      _settings.setNickname(nickname),
      _settings.setTitle(title),
      _settings.setBio(bio),
    ]);

    final identityDao = ref.read(appDatabaseProvider).identityDao;
    final displayName = title.isEmpty ? nickname : '$nickname - $title';
    await identityDao.setDisplayName(displayName);
    await identityDao.setBio(bio.isEmpty ? null : bio);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        return SettingsScaffold(
          icon: Icons.person_outline,
          title: 'Edit Profile',
          floatingActionButton: FloatingActionButton.extended(
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
          children: [
            _ProfileEditor(
              theme: theme,
              profilePicture: _settings.profilePicture,
              onPickPicture: _pickProfilePicture,
              nicknameController: _nicknameController,
              titleController: _titleController,
              bioController: _bioController,
            ),
          ],
        );
      },
    );
  }
}

class _ProfileEditor extends StatelessWidget {
  const _ProfileEditor({
    required this.theme,
    required this.profilePicture,
    required this.onPickPicture,
    required this.nicknameController,
    required this.titleController,
    required this.bioController,
  });

  final AppColorScheme theme;
  final String? profilePicture;
  final VoidCallback onPickPicture;
  final TextEditingController nicknameController;
  final TextEditingController titleController;
  final TextEditingController bioController;

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
  const _FieldLabel({required this.icon, required this.label, required this.theme});

  final IconData icon;
  final String label;
  final AppColorScheme theme;

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