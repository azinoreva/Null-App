import 'package:flutter/material.dart';
import '../app_theme.dart';

/// A social-style "update" / post card.
///
///  - [avatarUrl], [nickname], [timeText] : header info (timeText is shown
///    as-is, e.g. "JUST NOW", "5H AGO" - pass whatever string you want).
///  - [text]      : the post body.
///  - [mediaUrl]  : optional image shown under the text. Pass null / leave
///                  out if the post has no media.
///  - [isLiked] / [isDisliked] / [isShared] / [isSubscribed] : initial
///    state for the corresponding action icon - true turns that icon
///    green. Like and dislike are mutually exclusive once the user starts
///    tapping (even if you happened to pass both true).
///  - [onHidePost] : called when the user picks "Hide" from the "..." menu.
class UpdateComponent extends StatefulWidget {
  final String avatarUrl;
  final String nickname;
  final String timeText;
  final String text;
  final String? mediaUrl;
  final bool isLiked;
  final bool isDisliked;
  final bool isShared;
  final bool isSubscribed;
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
    this.isShared = false,
    this.isSubscribed = false,
    this.onHidePost,
  });

  @override
  State<UpdateComponent> createState() => _UpdateComponentState();
}

class _UpdateComponentState extends State<UpdateComponent> {
  late bool _liked;
  late bool _disliked;
  late bool _shared;
  late bool _subscribed;
  bool _flagged = false; // first icon - no external prop was specified for this one

  @override
  void initState() {
    super.initState();
    _liked = widget.isLiked;
    _disliked = widget.isDisliked && !widget.isLiked; // enforce mutual exclusion up front
    _shared = widget.isShared;
    _subscribed = widget.isSubscribed;
  }

  // ---- Stub function to be implemented later ----
  void _hidePost() {
    // TODO: hide/remove this post from the feed.
  }
  // -------------------------------------------------

  void _handleHideSelected() {
    _hidePost();
    widget.onHidePost?.call();
  }

  void _toggleFlag() {
    setState(() => _flagged = !_flagged);
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      if (_liked) _disliked = false;
    });
  }

  void _toggleDislike() {
    setState(() {
      _disliked = !_disliked;
      if (_disliked) _liked = false;
    });
  }

  void _toggleShare() {
    setState(() => _shared = !_shared);
  }

  void _toggleSubscribe() {
    setState(() => _subscribed = !_subscribed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20.0,
                backgroundColor: AppColors.neutralGray,
                backgroundImage: NetworkImage(widget.avatarUrl),
              ),
              const SizedBox(width: 10.0),
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
                icon: Icon(Icons.more_horiz, color: AppColors.mutedSlate),
                color: theme.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: theme.border),
                ),
                onSelected: (value) {
                  if (value == 'hide') _handleHideSelected();
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'hide',
                    child: Text(
                      'Hide',
                      style: AppTypography.getTextStyle(
                        context,
                        AppTextType.body,
                        color: theme.textInputColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Body text
          Text(
            widget.text,
            style: AppTypography.getTextStyle(
              context,
              AppTextType.body,
              color: theme.textInputColor,
            ),
          ),

          // Media
          if (widget.mediaUrl != null) ...[
            const SizedBox(height: 12.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(widget.mediaUrl!, fit: BoxFit.cover),
              ),
            ),
          ],

          const SizedBox(height: 14.0),
          Divider(color: theme.border, height: 1.0),
          const SizedBox(height: 8.0),

          // Action icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ActionIcon(
                icon: Icons.outlined_flag,
                isActive: _flagged,
                onTap: _toggleFlag,
              ),
              _ActionIcon(
                icon: Icons.thumb_up_alt_outlined,
                isActive: _liked,
                onTap: _toggleLike,
              ),
              _ActionIcon(
                icon: Icons.thumb_down_alt_outlined,
                isActive: _disliked,
                onTap: _toggleDislike,
              ),
              _ActionIcon(
                icon: Icons.share_outlined,
                isActive: _shared,
                onTap: _toggleShare,
              ),
              _ActionIcon(
                icon: Icons.person_add_alt_1_outlined,
                isActive: _subscribed,
                onTap: _toggleSubscribe,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(
          icon,
          size: 22.0,
          color: isActive ? AppColors.activeGreen : AppColors.mutedSlate,
        ),
      ),
    );
  }
}