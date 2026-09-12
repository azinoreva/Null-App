import 'package:flutter/material.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/buttons/send_button.dart';

/// "Friend Request" modal.
///
/// Decoupled like the other modals: [onAccept] / [onDecline] are required
/// callbacks the caller implements (e.g. hitting an API) - this widget
/// just shows a loading state on whichever button was tapped while it
/// awaits, then closes itself.
class FriendRequestModal extends StatefulWidget {
  final String avatarUrl;
  final String name;
  final String username;
  final String message;
  final String timeText;
  final Future<void> Function() onAccept;
  final Future<void> Function() onDecline;
  final VoidCallback? onClose;

  const FriendRequestModal({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.username,
    required this.message,
    required this.timeText,
    required this.onAccept,
    required this.onDecline,
    this.onClose,
  });

  @override
  State<FriendRequestModal> createState() => _FriendRequestModalState();
}

enum _Pending { none, accept, decline }

class _FriendRequestModalState extends State<FriendRequestModal> {
  _Pending _pending = _Pending.none;

  void _handleClose() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _handleAccept() async {
    if (_pending != _Pending.none) return;
    setState(() => _pending = _Pending.accept);
    await widget.onAccept();
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  Future<void> _handleDecline() async {
    if (_pending != _Pending.none) return;
    setState(() => _pending = _Pending.decline);
    await widget.onDecline();
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

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
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Friend Request',
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.title,
                    color: theme.textInputColor,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              InkWell(
                onTap: _handleClose,
                customBorder: const CircleBorder(),
                child: Icon(Icons.close, color: AppColors.mutedSlate),
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          // Avatar + name + handle
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.primaryGreen, width: 2.0),
                  ),
                  child: CircleAvatar(
                    radius: 36.0,
                    backgroundColor: AppColors.neutralGray,
                    backgroundImage: NetworkImage(widget.avatarUrl),
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  widget.name,
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.title,
                    color: theme.textInputColor,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2.0),
                Text(
                  '@${widget.username}',
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.body,
                    color: AppColors.mutedSlate,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: theme.border.withAlpha(70),
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${widget.message}"',
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.body,
                    color: theme.textInputColor,
                  ).copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 10.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    widget.timeText,
                    style: AppTypography.getTextStyle(
                      context,
                      AppTextType.tiny,
                      color: AppColors.mutedSlate,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Accept / Decline
          SizedBox(
            width: double.infinity,
            child: SendButton(
              text: 'Accept Request',
              isLocked: _pending != _Pending.none,
              onPressed: _handleAccept,
              textType: AppTextType.body,
            ),
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _pending != _Pending.none ? null : _handleDecline,
              style: ButtonStyle(
                side: WidgetStateProperty.all(BorderSide(color: theme.border)),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                ),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 14.0)),
              ),
              child: Text(
                'Decline',
                style: AppTypography.getTextStyle(
                  context,
                  AppTextType.body,
                  color: AppColors.mutedSlate,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}