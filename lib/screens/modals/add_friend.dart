import 'package:flutter/material.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/buttons/send_button.dart';

const int _kMaxWords = 150;

/// "Write an introduction" modal.
///
/// [onCancel] is called when the user taps Cancel or the close icon; if not
/// provided it just pops the current route.
class IntroductionModal extends StatefulWidget {
  final VoidCallback? onCancel;

  const IntroductionModal({
    super.key,
    this.onCancel,
  });

  @override
  State<IntroductionModal> createState() => _IntroductionModalState();
}

class _IntroductionModalState extends State<IntroductionModal> {
  final TextEditingController _messageController = TextEditingController();
  bool _addToContacts = false;
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_handleMessageChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_handleMessageChanged);
    _messageController.dispose();
    super.dispose();
  }

  void _handleMessageChanged() {
    final text = _messageController.text.trim();
    final count = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    if (count != _wordCount) {
      setState(() {
        _wordCount = count;
      });
    }
  }

  // ---- Stub function to be implemented later ----
  void _saveMessage(String message) {
    // TODO: persist / send the introduction message.
  }
  // -------------------------------------------------

  void _handleCancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _handleSend() {
    _saveMessage(_messageController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;
    final isOverLimit = _wordCount > _kMaxWords;
    final counterColor = isOverLimit ? AppColors.alertRed : theme.primaryGreen;
    final fillColor = theme.border.withAlpha(90);
    final isMessageEmpty = _messageController.text.trim().isEmpty;

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
              Icon(Icons.chat_bubble_outline, color: theme.primaryGreen),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  'Write an introduction',
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.title,
                    color: theme.textInputColor,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              InkWell(
                onTap: _handleCancel,
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: theme.border,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 18.0, color: theme.textInputColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Divider(color: theme.border, height: 1.0),
          const SizedBox(height: 16.0),

          // Message label + counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Message',
                style: AppTypography.getTextStyle(
                  context,
                  AppTextType.body,
                  color: AppColors.mutedSlate,
                ),
              ),
              Text(
                '$_wordCount / $_kMaxWords words',
                style: AppTypography.getTextStyle(
                  context,
                  AppTextType.tiny,
                  color: counterColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),

          // Message text area
          Container(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: TextField(
              controller: _messageController,
              maxLines: 5,
              minLines: 5,
              cursorColor: theme.primaryGreen,
              style: AppTypography.getTextStyle(
                context,
                AppTextType.body,
                color: theme.textInputColor,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(14.0),
                border: InputBorder.none,
                hintText: "Hi, I'm... (Start typing or pick a template below)",
                hintStyle: AppTypography.getTextStyle(
                  context,
                  AppTextType.body,
                  color: AppColors.mutedSlate,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Checkbox
          Row(
            children: [
              SizedBox(
                width: 22.0,
                height: 22.0,
                child: Checkbox(
                  value: _addToContacts,
                  activeColor: theme.primaryGreen,
                  checkColor: AppColors.pureBlack,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                  onChanged: (value) {
                    setState(() {
                      _addToContacts = value ?? false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Also add to my contacts list',
                style: AppTypography.getTextStyle(
                  context,
                  AppTextType.body,
                  color: theme.textInputColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Divider(color: theme.border, height: 1.0),
          const SizedBox(height: 16.0),

          // Footer buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleCancel,
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all(0),
                    backgroundColor: WidgetStateProperty.all(theme.border),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    ),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 14.0),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTypography.getTextStyle(
                      context,
                      AppTextType.body,
                      color: AppColors.pureWhite,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: SendButton(
                  text: 'Send Request',
                  icon: Icons.check_circle_outline,
                  iconPosition: IconPosition.right,
                  isLocked: isMessageEmpty,
                  onPressed: _handleSend,
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