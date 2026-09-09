import 'package:flutter/material.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/buttons/send_button.dart';

/// Profile modal shown when tapping on a user (avatar, bio, server, etc).
///
/// Everything the modal needs is passed in from the outside:
///  - [avatarUrl]        : network image url for the user's avatar
///  - [isOnline]         : 0 = offline (grey dot), 1 = online (green dot)
///  - [nickname]         : the user's display name (editable)
///  - [bio]              : the user's bio text
///  - [server]           : the server / origin text shown under bio
///  - [connectionStatus] : 2 = not blocked -> button reads "Block"
///                         1 = blocked     -> button reads "Unblock" 

class ProfileModal extends StatefulWidget {
  final String avatarUrl;
  final int isOnline;
  final String nickname;
  final String bio;
  final String server;
  final int connectionStatus;

  const ProfileModal({
    super.key,
    required this.avatarUrl,
    required this.isOnline,
    required this.nickname,
    required this.bio,
    required this.server,
    required this.connectionStatus,
  });

  @override
  State<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends State<ProfileModal> {
  late TextEditingController _nameController;
  late FocusNode _nameFocusNode;
  late bool _isBlocked;
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.nickname);
    _nameFocusNode = FocusNode();
    _isBlocked = widget.connectionStatus == 1;

    _nameFocusNode.addListener(() {
      // User "removed their hand" -> focus was lost -> trigger save.
      if (!_nameFocusNode.hasFocus && _isEditingName) {
        _saveName(_nameController.text);
        setState(() {
          _isEditingName = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  // ---- Stub functions to be implemented later ----

  void _saveName(String newName) {
    // TODO: persist the updated nickname.
  }

  void _toggleMuteNotifications() {
    // TODO: mute/unmute notifications for this user.
  }

  void _toggleBlock() {
    // TODO: call block/unblock API, then update `_isBlocked` on success.
  }

  void _onPing() {
    // TODO: trigger ping action.
  }

  // --------------------------------------------------

  void _enterEditMode() {
    setState(() {
      _isEditingName = true;
    });
    // Request focus on the next frame so the field is built first.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;
    final isOnline = widget.isOnline == 1;
    final statusColor = isOnline ? AppColors.activeGreen : AppColors.mutedSlate;
    final statusText = isOnline ? 'ACTIVE NOW' : 'OFFLINE';

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Close + Mute icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                child: Row(
                  children: [
                    Icon(Icons.chevron_left, color: theme.textInputColor),
                    Text(
                      'Close',
                      style: AppTypography.getTextStyle(
                        context,
                        AppTextType.body,
                        color: theme.textInputColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _toggleMuteNotifications,
                icon: Icon(Icons.notifications_off_outlined, color: AppColors.mutedSlate),
                tooltip: 'Mute notifications',
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Avatar + status dot
          Stack(
            children: [
              CircleAvatar(
                radius: 32.0,
                backgroundColor: AppColors.neutralGray,
                backgroundImage: NetworkImage(widget.avatarUrl),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16.0,
                  height: 16.0,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.background, width: 2.0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Name row (editable) + edit icon
          Row(
            children: [
              Expanded(
                child: _isEditingName
                    ? TextField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        autofocus: true,
                        onSubmitted: (value) {
                          _saveName(value);
                          setState(() {
                            _isEditingName = false;
                          });
                        },
                        style: AppTypography.getTextStyle(
                          context,
                          AppTextType.title,
                          color: theme.textInputColor,
                        ),
                        cursorColor: theme.primaryGreen,
                        decoration: InputDecoration(
                          isDense: true,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: theme.border),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: theme.primaryGreen, width: 2.0),
                          ),
                        ),
                      )
                    : Text(
                        _nameController.text,
                        style: AppTypography.getTextStyle(
                          context,
                          AppTextType.title,
                          color: theme.textInputColor,
                        ),
                      ),
              ),
              if (!_isEditingName)
                IconButton(
                  onPressed: _enterEditMode,
                  icon: Icon(Icons.edit_outlined, color: theme.primaryGreen),
                  tooltip: 'Edit name',
                ),
            ],
          ),
          Text(
            statusText,
            style: AppTypography.getTextStyle(
              context,
              AppTextType.tiny,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 16.0),

          // Bio
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Bio: ',
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.body,
                    color: theme.textInputColor,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: widget.bio,
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.body,
                    color: theme.textInputColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),

          // Server
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Server: ',
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.body,
                    color: theme.textInputColor,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: widget.server,
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.body,
                    color: theme.textInputColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Block / Unblock + Ping buttons
          Row(
            children: [
              Expanded(
                child: SendButton(
                  text: _isBlocked ? 'Unblock' : 'Block',
                  onPressed: _toggleBlock,
                  textType: AppTextType.body,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: SendButton(
                  text: 'Ping',
                  icon: Icons.bolt,
                  iconPosition: IconPosition.left,
                  onPressed: _onPing,
                  textType: AppTextType.body,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}