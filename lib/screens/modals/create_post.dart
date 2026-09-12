import 'package:flutter/material.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/buttons/send_button.dart';

const int _kMaxChars = 1000;

enum PostVisibility { anyone, myContacts, specificPeople }

/// "New Post" screen.
///
/// Visually this is a full page (status bar, back arrow, no rounded card)
/// rather than a popup-style modal, so it's built like the other full
/// screens (ContactsListScreen, UpdatesScreen) - no bottom navbar, meant
/// to be pushed as its own route.
///
/// Decoupled from any settings/data module: [onPost] is called with the
/// final text + chosen visibility (+ specific people ids, if that mode is
/// picked) when "Post" is tapped, and it's up to the caller to actually
/// submit it.
class CreatePostScreen extends StatefulWidget {
  final String authorAvatarUrl;
  final String authorName;
  final String? authorRoleLabel;
  final Future<void> Function(
    String text,
    PostVisibility visibility,
    List<String>? specificPeopleIds,
  ) onPost;
  final VoidCallback? onBack;
  final VoidCallback? onDiscardDraft;

  const CreatePostScreen({
    super.key,
    required this.authorAvatarUrl,
    required this.authorName,
    this.authorRoleLabel = 'Author',
    required this.onPost,
    this.onBack,
    this.onDiscardDraft,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  PostVisibility _visibility = PostVisibility.anyone;
  List<String>? _specificPeopleIds;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  // ---- Stubs to be implemented later ----
  void _handleAttachImage() {
    // TODO: open an image picker and insert/attach the result.
  }

  void _handleAttachLink() {
    // TODO: open a "add link" dialog and insert the result.
  }

  Future<void> _openSpecificPeoplePicker() async {
    // TODO: open a people picker, then set `_specificPeopleIds`.
  }
  // ------------------------------------------

  void _insertAtCursor(String token) {
    final text = _textController.text;
    final selection = _textController.selection;
    final cursor = selection.start >= 0 ? selection.start : text.length;
    final newText = text.replaceRange(cursor, cursor, token);
    _textController.value = _textController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor + token.length),
    );
    _textFocusNode.requestFocus();
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _handleDiscardDraft() {
    _textController.clear();
    widget.onDiscardDraft?.call();
  }

  Future<void> _handlePost() async {
    final text = _textController.text.trim();
    if (text.isEmpty || text.length > _kMaxChars || _isPosting) return;

    setState(() => _isPosting = true);
    await widget.onPost(
      text,
      _visibility,
      _visibility == PostVisibility.specificPeople ? _specificPeopleIds : null,
    );
    if (!mounted) return;
    setState(() => _isPosting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;
    final charCount = _textController.text.length;
    final isOverLimit = charCount > _kMaxChars;
    final canPost = charCount > 0 && !isOverLimit && !_isPosting;

    return Container(
      color: theme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: _handleBack,
                    child: Icon(Icons.arrow_back, color: theme.textInputColor),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      'New Post',
                      style: AppTypography.getTextStyle(
                        context,
                        AppTextType.title,
                        color: theme.textInputColor,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SendButton(
                    text: 'Post',
                    icon: Icons.send,
                    iconPosition: IconPosition.left,
                    isLocked: !canPost,
                    onPressed: _handlePost,
                    textType: AppTextType.body,
                  ),
                ],
              ),
            ),
            Divider(color: theme.border, height: 1.0),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20.0,
                          backgroundColor: AppColors.neutralGray,
                          backgroundImage: NetworkImage(widget.authorAvatarUrl),
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          widget.authorName,
                          style: AppTypography.getTextStyle(
                            context,
                            AppTextType.body,
                            color: theme.textInputColor,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (widget.authorRoleLabel != null) ...[
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                            decoration: BoxDecoration(
                              color: theme.primaryGreen.withAlpha(35),
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(color: theme.primaryGreen),
                            ),
                            child: Text(
                              widget.authorRoleLabel!,
                              style: AppTypography.getTextStyle(
                                context,
                                AppTextType.tiny,
                                color: theme.primaryGreen,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Text area
                    Container(
                      decoration: BoxDecoration(
                        color: theme.border.withAlpha(70),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: TextField(
                        controller: _textController,
                        focusNode: _textFocusNode,
                        maxLines: 8,
                        minLines: 8,
                        maxLength: _kMaxChars + 50, // soft overshoot allowed; hard-blocked at post time
                        buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                        cursorColor: theme.primaryGreen,
                        style: AppTypography.getTextStyle(
                          context,
                          AppTextType.body,
                          color: theme.textInputColor,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(14.0),
                          border: InputBorder.none,
                          hintText: "What's happening?",
                          hintStyle: AppTypography.getTextStyle(
                            context,
                            AppTextType.body,
                            color: AppColors.mutedSlate,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '$charCount / $_kMaxChars',
                        style: AppTypography.getTextStyle(
                          context,
                          AppTextType.tiny,
                          color: isOverLimit ? AppColors.alertRed : AppColors.mutedSlate,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    // Attachment icons
                    Row(
                      children: [
                        IconButton(
                          onPressed: _handleAttachImage,
                          icon: Icon(Icons.image_outlined, color: theme.primaryGreen),
                          tooltip: 'Add image',
                        ),
                        IconButton(
                          onPressed: () => _insertAtCursor('@'),
                          icon: Icon(Icons.alternate_email, color: theme.primaryGreen),
                          tooltip: 'Mention someone',
                        ),
                        IconButton(
                          onPressed: () => _insertAtCursor('#'),
                          icon: Icon(Icons.tag, color: theme.primaryGreen),
                          tooltip: 'Add a hashtag',
                        ),
                        IconButton(
                          onPressed: _handleAttachLink,
                          icon: Icon(Icons.link, color: theme.primaryGreen),
                          tooltip: 'Add a link',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),

                    // Post visibility
                    Row(
                      children: [
                        Text(
                          'POST VISIBILITY',
                          style: AppTypography.getTextStyle(
                            context,
                            AppTextType.tiny,
                            color: theme.textInputColor,
                          ).copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        const SizedBox(width: 6.0),
                        Tooltip(
                          message: 'Controls who can see this post.',
                          child: Icon(Icons.info_outline, size: 14.0, color: AppColors.mutedSlate),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),

                    _VisibilityOption(
                      theme: theme,
                      icon: Icons.public,
                      title: 'Anyone',
                      subtitle: 'Visible to everyone in the your network',
                      selected: _visibility == PostVisibility.anyone,
                      onTap: () => setState(() => _visibility = PostVisibility.anyone),
                    ),
                    _VisibilityOption(
                      theme: theme,
                      icon: Icons.people_outline,
                      title: 'My Contacts',
                      subtitle: 'Select those you want to see your update',
                      selected: _visibility == PostVisibility.myContacts,
                      onTap: () => setState(() => _visibility = PostVisibility.myContacts),
                    ),
                    _VisibilityOption(
                      theme: theme,
                      icon: Icons.people_outline,
                      title: 'Specific People',
                      subtitle: 'Select those you want to see your update',
                      selected: _visibility == PostVisibility.specificPeople,
                      onTap: () {
                        setState(() => _visibility = PostVisibility.specificPeople);
                        _openSpecificPeoplePicker();
                      },
                    ),
                    const SizedBox(height: 16.0),

                    Text(
                      'By posting, you agree to our Community Guidelines. '
                      'Posts with links may be reviewed for safety.',
                      textAlign: TextAlign.center,
                      style: AppTypography.getTextStyle(
                        context,
                        AppTextType.tiny,
                        color: AppColors.mutedSlate,
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    Center(
                      child: TextButton(
                        onPressed: _handleDiscardDraft,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(theme.border),
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                          ),
                        ),
                        child: Text(
                          'Discard Draft',
                          style: AppTypography.getTextStyle(
                            context,
                            AppTextType.body,
                            color: theme.textInputColor,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisibilityOption extends StatelessWidget {
  final AppColorScheme theme;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _VisibilityOption({
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: selected ? theme.primaryGreen.withAlpha(35) : theme.border.withAlpha(70),
          borderRadius: BorderRadius.circular(14.0),
          border: selected ? Border.all(color: theme.primaryGreen) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36.0,
              height: 36.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? theme.primaryGreen : AppColors.mutedSlate.withAlpha(60),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(
                icon,
                size: 18.0,
                color: selected ? theme.buttonContentColor : theme.textInputColor,
              ),
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
                      color: theme.textInputColor,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
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
            Radio<bool>(
              value: true,
              groupValue: selected,
              onChanged: (_) => onTap(),
              activeColor: theme.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}