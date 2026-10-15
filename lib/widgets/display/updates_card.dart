import 'dart:async';

import 'package:flutter/material.dart';

import '../../engine/functions/settings/settings.dart';
import '../../engine/network/updates/comments.dart';
import '../../engine/network/updates/updates_cache.dart';
import '../app_theme.dart';

/// Compact update preview that opens the full post and its comments.
class UpdateComponent extends StatefulWidget {
  final String updateId;
  final String serverId;
  final Future<void> Function(String serverId)? ensureServerRegistered;
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
    required this.updateId,
    required this.serverId,
    this.ensureServerRegistered,
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

  @override
  void initState() {
    super.initState();
    _syncState();
  }

  @override
  void didUpdateWidget(covariant UpdateComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked ||
        oldWidget.isDisliked != widget.isDisliked ||
        oldWidget.isReposted != widget.isReposted) {
      _syncState();
    }
  }

  void _syncState() {
    _liked = widget.isLiked;
    _disliked = widget.isDisliked && !widget.isLiked;
    _reposted = widget.isReposted;
  }

  void _setReaction({required bool liked, required bool disliked}) {
    setState(() {
      _liked = liked;
      _disliked = disliked && !liked;
    });
    widget.onReactionChanged?.call(_liked, _disliked);
  }

  void _openPost({bool openComposer = false}) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => UpdatePostDialog(
        updateId: widget.updateId,
        serverId: widget.serverId,
        initialComments: _cachedComments(),
        ensureServerRegistered: widget.ensureServerRegistered,
        avatarUrl: widget.avatarUrl,
        nickname: widget.nickname,
        timeText: widget.timeText,
        text: widget.text,
        mediaUrl: widget.mediaUrl,
        isLiked: _liked,
        isDisliked: _disliked,
        isReposted: _reposted,
        openComposerOnOpen: openComposer,
        onReactionChanged: (liked, disliked) =>
            _setReaction(liked: liked, disliked: disliked),
        onRepostChanged: (reposted) =>
            setState(() => _reposted = reposted),
      ),
    );
  }

  List<Comment>? _cachedComments() {
    try {
      return UpdatesCacheService.instance.loadComments(widget.updateId);
    } catch (_) {
      return null;
    }
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
        onTap: () => _openPost(),
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
                  _media(widget.mediaUrl!),
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
                _actionBar(),
              ],
            ),
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

  Widget _media(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(url, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _actionBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionIcon(
            icon: Icons.thumb_up_alt_outlined,
            tooltip: 'Like',
            isActive: _liked,
            onTap: () => _setReaction(liked: !_liked, disliked: false),
          ),
          _ActionIcon(
            icon: Icons.thumb_down_alt_outlined,
            tooltip: 'Dislike',
            isActive: _disliked,
            onTap: () => _setReaction(liked: false, disliked: !_disliked),
          ),
          _ActionIcon(
            icon: Icons.repeat_rounded,
            tooltip: 'Repost',
            isActive: _reposted,
            onTap: () => setState(() => _reposted = !_reposted),
          ),
          _ActionIcon(
            icon: Icons.mode_comment_outlined,
            tooltip: 'Comment',
            isActive: false,
            onTap: () => _openPost(openComposer: true),
          ),
        ],
      ),
    );
  }
}

/// Scrollable post and comment thread with a fixed four-action footer.
class UpdatePostDialog extends StatefulWidget {
  final String updateId;
  final String serverId;
  final List<Comment>? initialComments;
  final Future<void> Function(String serverId)? ensureServerRegistered;
  final String avatarUrl;
  final String nickname;
  final String timeText;
  final String text;
  final String? mediaUrl;
  final bool isLiked;
  final bool isDisliked;
  final bool isReposted;
  final bool openComposerOnOpen;
  final void Function(bool liked, bool disliked)? onReactionChanged;
  final ValueChanged<bool>? onRepostChanged;

  const UpdatePostDialog({
    super.key,
    required this.updateId,
    required this.serverId,
    this.initialComments,
    this.ensureServerRegistered,
    required this.avatarUrl,
    required this.nickname,
    required this.timeText,
    required this.text,
    this.mediaUrl,
    this.isLiked = false,
    this.isDisliked = false,
    this.isReposted = false,
    this.openComposerOnOpen = false,
    this.onReactionChanged,
    this.onRepostChanged,
  });

  @override
  State<UpdatePostDialog> createState() => _UpdatePostDialogState();
}

class _UpdatePostDialogState extends State<UpdatePostDialog> {
  final _scrollController = ScrollController();
  final _commentController = TextEditingController();
  final _commentFocus = FocusNode();
  late bool _liked;
  late bool _disliked;
  late bool _reposted;
  List<Comment> _comments = const [];
  Comment? _replyTo;
  bool _loading = true;
  bool _posting = false;
  bool _composerOpen = false;
  String? _loadError;
  String? _submitError;

  CommentsService get _commentsService =>
      CommentsService(serverId: widget.serverId);

  @override
  void initState() {
    super.initState();
    _liked = widget.isLiked;
    _disliked = widget.isDisliked && !widget.isLiked;
    _reposted = widget.isReposted;
    _composerOpen = widget.openComposerOnOpen;
    _comments = widget.initialComments ?? const [];
    _loading = widget.initialComments == null;
    unawaited(_loadComments());
    if (_composerOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToComposer());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      await widget.ensureServerRegistered?.call(widget.serverId);
      final response = await _commentsService.checkComments(
        updateId: widget.updateId,
      );
      await _cacheComments(response.comments);
      if (!mounted) return;
      setState(() {
        _comments = response.comments;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Could not load comments.';
      });
    }
  }

  Future<void> _cacheComments(List<Comment> comments) async {
    try {
      await UpdatesCacheService.instance.saveComments(widget.updateId, comments);
    } catch (_) {
      // Comments still render from the network if Hive is unavailable.
    }
  }

  void _setReaction({required bool liked, required bool disliked}) {
    setState(() {
      _liked = liked;
      _disliked = disliked && !liked;
    });
    widget.onReactionChanged?.call(_liked, _disliked);
  }

  void _openComposer({Comment? replyTo}) {
    setState(() {
      _composerOpen = true;
      _replyTo = replyTo;
      _submitError = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToComposer();
    });
  }

  void _scrollToComposer() {
    if (!_scrollController.hasClients) {
      if (mounted) _commentFocus.requestFocus();
      return;
    }
    _scrollController
        .animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        )
        .then((_) {
          if (mounted) _commentFocus.requestFocus();
        });
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _posting) return;

    setState(() {
      _posting = true;
      _submitError = null;
    });
    try {
      final nickname = AppSettings.instance.nickname;
      final replyTo = _replyTo;
      final comment = replyTo == null
          ? await _commentsService.commentToPost(
              updateId: widget.updateId,
              nickname: nickname,
              text: text,
            )
          : await _commentsService.commentToComment(
              updateId: widget.updateId,
              replyTo: replyTo.commentId,
              atUser: '@${replyTo.nickname ?? 'User'}',
              nickname: nickname,
              text: text,
            );
      if (!mounted) return;
      setState(() {
        _comments = [..._comments, comment];
        _commentController.clear();
        _commentFocus.unfocus();
        _replyTo = null;
        _composerOpen = false;
        _posting = false;
      });
      await _cacheComments(_comments);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _posting = false;
        _submitError = 'Could not post comment. Please try again.';
      });
    }
  }

  Map<String, List<Comment>> _childrenByParent() {
    final ids = _comments.map((comment) => comment.commentId).toSet();
    final children = <String, List<Comment>>{};
    for (final comment in _comments) {
      final parent = comment.replyTo;
      if (parent != null && ids.contains(parent)) {
        children.putIfAbsent(parent, () => <Comment>[]).add(comment);
      }
    }
    return children;
  }

  Widget _commentThread(
    Comment comment,
    Map<String, List<Comment>> children,
    AppColorScheme theme, {
    int depth = 0,
  }) {
    final nested = children[comment.commentId] ?? const <Comment>[];
    final indent = (depth * 14).clamp(0, 56).toDouble();
    final displayName = comment.nickname?.trim().isNotEmpty == true
        ? comment.nickname!.trim()
        : 'User';
    return Padding(
      padding: EdgeInsets.only(left: indent, bottom: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: depth == 0
              ? null
              : Border(left: BorderSide(color: theme.border, width: 2)),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: depth == 0 ? 0 : 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.border,
                    child: Text(
                      displayName.substring(0, 1).toUpperCase(),
                      style: AppTypography.getTextStyle(
                        context,
                        AppTextType.tiny,
                        color: theme.textInputColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      displayName,
                      style: AppTypography.getTextStyle(
                        context,
                        AppTextType.tiny,
                        color: theme.textInputColor,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openComposer(replyTo: comment),
                    child: const Text('Reply'),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 36, right: 8),
                child: Text(
                  comment.text,
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.body,
                    color: theme.textInputColor,
                  ),
                ),
              ),
              for (final child in nested)
                _commentThread(child, children, theme, depth: depth + 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _comments(AppColorScheme theme) {
    final children = _childrenByParent();
    final ids = _comments.map((comment) => comment.commentId).toSet();
    final roots = _comments
        .where((comment) =>
            comment.replyTo == null || !ids.contains(comment.replyTo))
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Comments (${_comments.length})',
                style: AppTypography.getTextStyle(
                  context,
                  AppTextType.body,
                  color: theme.textInputColor,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              tooltip: 'Refresh comments',
              onPressed: _loading ? null : _loadComments,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        if (_loading && _comments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_comments.isEmpty && _loadError != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _loadError!,
                    style: AppTypography.getTextStyle(
                      context,
                      AppTextType.tiny,
                      color: AppColors.mutedSlate,
                    ),
                  ),
                ),
                TextButton(onPressed: _loadComments, child: const Text('Retry')),
              ],
            ),
          )
        else if (_comments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              'No comments yet. Start the conversation.',
              style: AppTypography.getTextStyle(
                context,
                AppTextType.tiny,
                color: AppColors.mutedSlate,
              ),
            ),
          )
        else ...[
          for (final comment in roots)
            _commentThread(comment, children, theme),
        ],
        if (_composerOpen) _composer(theme),
      ],
    );
  }

  Widget _composer(AppColorScheme theme) {
    final replyingTo = _replyTo?.nickname;
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.border.withAlpha(35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_replyTo != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Replying to ${replyingTo ?? 'User'}',
                    style: AppTypography.getTextStyle(
                      context,
                      AppTextType.tiny,
                      color: AppColors.mutedSlate,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Cancel reply',
                  onPressed: () => setState(() => _replyTo = null),
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
          TextField(
            controller: _commentController,
            focusNode: _commentFocus,
            minLines: 1,
            maxLines: 4,
            enabled: !_posting,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) {
              if (_submitError != null) setState(() => _submitError = null);
            },
            decoration: InputDecoration(
              hintText: _replyTo == null ? 'Write a comment…' : 'Write a reply…',
              border: InputBorder.none,
            ),
          ),
          if (_submitError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _submitError!,
                style: AppTypography.getTextStyle(
                  context,
                  AppTextType.tiny,
                  color: Colors.redAccent,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _posting
                    ? null
                    : () {
                        _commentController.clear();
                        _commentFocus.unfocus();
                        setState(() {
                          _composerOpen = false;
                          _replyTo = null;
                          _submitError = null;
                        });
                      },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _posting ? null : _submitComment,
                icon: _posting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, size: 16),
                label: Text(_posting ? 'Posting…' : 'Post'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fullPost(AppColorScheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Close post',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (widget.mediaUrl != null && widget.mediaUrl!.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.mediaUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Container(
                height: 180,
                alignment: Alignment.center,
                color: theme.border.withAlpha(35),
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        Text(
          widget.text,
          style: AppTypography.getTextStyle(
            context,
            AppTextType.body,
            color: theme.textInputColor,
          ),
        ),
        const SizedBox(height: 18),
        Divider(color: theme.border),
        _comments(theme),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;
    final maxHeight = MediaQuery.sizeOf(context).height * .84;
    return Dialog(
      backgroundColor: theme.background,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.border),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: maxHeight),
        child: SizedBox.expand(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  children: [_fullPost(theme)],
                ),
              ),
              Divider(height: 1, color: theme.border),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ActionIcon(
                        icon: Icons.thumb_up_alt_outlined,
                        tooltip: 'Like',
                        isActive: _liked,
                        onTap: () => _setReaction(
                          liked: !_liked,
                          disliked: false,
                        ),
                      ),
                      _ActionIcon(
                        icon: Icons.thumb_down_alt_outlined,
                        tooltip: 'Dislike',
                        isActive: _disliked,
                        onTap: () => _setReaction(
                          liked: false,
                          disliked: !_disliked,
                        ),
                      ),
                      _ActionIcon(
                        icon: Icons.repeat_rounded,
                        tooltip: 'Repost',
                        isActive: _reposted,
                        onTap: () {
                          setState(() => _reposted = !_reposted);
                          widget.onRepostChanged?.call(_reposted);
                        },
                      ),
                      _ActionIcon(
                        icon: Icons.mode_comment_outlined,
                        tooltip: 'Comment',
                        isActive: _composerOpen,
                        onTap: () => _openComposer(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
          padding: const EdgeInsets.all(8),
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
