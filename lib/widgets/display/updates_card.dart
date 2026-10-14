import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Compact update preview that opens the full post in a centered dialog.
class UpdateComponent extends StatefulWidget {
  final String avatarUrl;
  final String nickname;
  final String timeText;
  final String text;
  final String? mediaUrl;
  final bool isLiked;
  final bool isDisliked;
  final bool isReposted;
  final void Function(bool liked, bool disliked)? onReactionChanged;
  final VoidCallback? onHidePost;

  const UpdateComponent({
    super.key,
    required this.avatarUrl,
    required this.nickname,
    required this.timeText,
    required this.text,
    this.mediaUrl,
    this.isLiked = false,
    this.isDisliked = false,
    this.isReposted = false,
    this.onReactionChanged,
    this.onHidePost,
  });

  @override
  State<UpdateComponent> createState() => _UpdateComponentState();
}

class _UpdateComponentState extends State<UpdateComponent> {
  late bool _liked;
  late bool _disliked;
  late bool _reposted;
  bool _flagged = false;

  @override
  void initState() {
    super.initState();
    _liked = widget.isLiked;
    _disliked = widget.isDisliked && !widget.isLiked;
    _reposted = widget.isReposted;
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      if (_liked) _disliked = false;
    });
    widget.onReactionChanged?.call(_liked, _disliked);
  }

  void _toggleDislike() {
    setState(() {
      _disliked = !_disliked;
      if (_disliked) _liked = false;
    });
    widget.onReactionChanged?.call(_liked, _disliked);
  }

  void _openPost() {
    final theme =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: theme.background,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: theme.border),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: MediaQuery.sizeOf(dialogContext).height * .84,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _fullPost(context, theme),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AppColorScheme theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.neutralGray,
          backgroundImage: NetworkImage(widget.avatarUrl),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.nickname,
                style: AppTypography.getTextStyle(
                  context,
                  AppTextType.body,
                  color: theme.textInputColor,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              if (widget.timeText.isNotEmpty)
                Text(
                  widget.timeText,
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.tiny,
                    color: AppColors.activeGreen,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz, color: AppColors.mutedSlate),
          color: theme.background,
          onSelected: (value) {
            if (value == 'hide') widget.onHidePost?.call();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'hide', child: Text('Hide')),
          ],
        ),
      ],
    );
  }

  Widget _bodyText(BuildContext context, AppColorScheme theme, {int? maxLines}) {
    return Text(
      widget.text,
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.visible : TextOverflow.ellipsis,
      style: AppTypography.getTextStyle(
        context,
        AppTextType.body,
        color: theme.textInputColor,
      ),
    );
  }

  Widget _media() {
    if (widget.mediaUrl == null || widget.mediaUrl!.isEmpty) {
      return const SizedBox.shrink();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(widget.mediaUrl!, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _fullPost(BuildContext context, AppColorScheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _header(context, theme),
        const SizedBox(height: 14),
        if (widget.mediaUrl != null) ...[
          _media(),
          const SizedBox(height: 14),
        ],
        _bodyText(context, theme),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;
    final hasMedia = widget.mediaUrl != null && widget.mediaUrl!.isNotEmpty;

    return Material(
      color: theme.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _openPost,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 164, maxHeight: 420),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _header(context, theme),
                const SizedBox(height: 12),
                if (hasMedia) ...[
                  _media(),
                  const SizedBox(height: 10),
                  _bodyText(context, theme, maxLines: 2),
                ] else
                  _bodyText(context, theme, maxLines: 5),
                const SizedBox(height: 6),
                Text(
                  'Tap to read full post',
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.tiny,
                    color: AppColors.mutedSlate,
                  ),
                ),
                const SizedBox(height: 14),
                Divider(color: theme.border, height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ActionIcon(
                      icon: Icons.outlined_flag,
                      tooltip: 'Flag',
                      isActive: _flagged,
                      onTap: () => setState(() => _flagged = !_flagged),
                    ),
                    _ActionIcon(
                      icon: Icons.thumb_up_alt_outlined,
                      tooltip: 'Like',
                      isActive: _liked,
                      onTap: _toggleLike,
                    ),
                    _ActionIcon(
                      icon: Icons.thumb_down_alt_outlined,
                      tooltip: 'Dislike',
                      isActive: _disliked,
                      onTap: _toggleDislike,
                    ),
                    _ActionIcon(
                      icon: Icons.repeat_rounded,
                      tooltip: 'Repost',
                      isActive: _reposted,
                      onTap: () => setState(() => _reposted = !_reposted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 22,
            color: isActive ? AppColors.activeGreen : AppColors.mutedSlate,
          ),
        ),
      ),
    );
  }
}
