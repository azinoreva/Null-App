import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/display/updates_card.dart';
import '../widgets/display/navigation.dart';
import 'chat_screen.dart';

/// Data needed to render one post via [UpdateComponent].
class PostData {
  final String avatarUrl;
  final String nickname;
  final String timeText;
  final String text;
  final String? mediaUrl;
  final bool isLiked;
  final bool isDisliked;
  final bool isShared;
  final bool isSubscribed;

  const PostData({
    required this.avatarUrl,
    required this.nickname,
    required this.timeText,
    required this.text,
    this.mediaUrl,
    this.isLiked = false,
    this.isDisliked = false,
    this.isShared = false,
    this.isSubscribed = false,
  });
}

/// Called to fetch the next page of posts. Return an empty list once
/// there's nothing left to paginate.
typedef PostPageLoader = Future<List<PostData>> Function(int nextPage);

/// Updates feed screen: header, an infinite-scrolling list of posts built
/// from [initialPosts] (auto-paginated via [onLoadMore] as the user
/// scrolls), and a floating "+" button for creating a new post.
class UpdatesScreen extends StatefulWidget {
  final List<PostData> initialPosts;
  final PostPageLoader onLoadMore;
  final VoidCallback? onCreatePost;

  const UpdatesScreen({
    super.key,
    required this.initialPosts,
    required this.onLoadMore,
    this.onCreatePost,
  });

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
  late List<PostData> _posts;
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _posts = List<PostData>.from(widget.initialPosts);
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    const threshold = 300.0;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    final nextPage = _page + 1;
    try {
      final newPosts = await widget.onLoadMore(nextPage);
      if (!mounted) return;
      setState(() {
        if (newPosts.isEmpty) {
          _hasMore = false;
        } else {
          _posts.addAll(newPosts);
          _page = nextPage;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
      // TODO: surface a retry / error state if loading a page fails.
    }
  }

  // ---- Stub function to be implemented later ----
  void _createPost() {
    // TODO: open the create-post flow.
  }
  // -------------------------------------------------

  void _handleCreatePost() {
    _createPost();
    widget.onCreatePost?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavigationShell(
      currentTab: NavigationTab.updates,
      onTabSelected: (tab) {
        if (tab == NavigationTab.chats) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        }
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

    return Container(
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
                    Icon(Icons.campaign_outlined, color: theme.textInputColor),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        'Updates',
                        style: AppTypography.getTextStyle(
                          context,
                          AppTextType.title,
                          color: theme.textInputColor,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(Icons.compare_arrows, color: theme.textInputColor),
                  ],
                ),
              ),

              // Feed
              Expanded(
                child: _posts.isEmpty
                    ? Center(
                        child: Text(
                          'No updates yet',
                          style: AppTypography.getTextStyle(
                            context,
                            AppTextType.body,
                            color: AppColors.mutedSlate,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 100.0),
                        itemCount: _posts.length + 1,
                        itemBuilder: (context, index) {
                          if (index < _posts.length) {
                            final post = _posts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: UpdateComponent(
                                avatarUrl: post.avatarUrl,
                                nickname: post.nickname,
                                timeText: post.timeText,
                                text: post.text,
                                mediaUrl: post.mediaUrl,
                                isLiked: post.isLiked,
                                isDisliked: post.isDisliked,
                                isShared: post.isShared,
                                isSubscribed: post.isSubscribed,
                              ),
                            );
                          }

                          // Footer: loading spinner, "caught up" message, or nothing.
                          if (_isLoadingMore) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24.0),
                              child: Center(
                                child: SizedBox(
                                  width: 24.0,
                                  height: 24.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: theme.primaryGreen,
                                  ),
                                ),
                              ),
                            );
                          }
                          if (!_hasMore) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24.0),
                              child: Center(
                                child: Text(
                                  "YOU'RE ALL CAUGHT UP",
                                  style: AppTypography.getTextStyle(
                                    context,
                                    AppTextType.tiny,
                                    color: AppColors.mutedSlate,
                                  ).copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
              ),
            ],
          ),

          // Floating create-post button
          Positioned(
            right: 16.0,
            bottom: 16.0,
            child: FloatingActionButton(
              onPressed: _handleCreatePost,
              backgroundColor: theme.primaryGreen,
              child: Icon(Icons.add, color: theme.buttonContentColor),
            ),
          ),
        ],
      ),
    );
  }
}