import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../widgets/app_theme.dart';
import '../widgets/display/updates_card.dart';
import '../widgets/display/navigation.dart';
import 'chat_screen.dart';
import 'contacts_screen.dart';
import 'settings_screen.dart';

/// Updates feed screen: header, an infinite-scrolling list of posts built
/// from [updatesFeedProvider] (auto-paginated as the user scrolls), and a
/// floating "+" button for creating a new post.
///
/// The feed's state (posts + pagination) is owned by Riverpod and kept alive,
/// so leaving the screen and returning renders the cached feed instantly.
class UpdatesScreen extends ConsumerStatefulWidget {
  const UpdatesScreen({super.key});

  @override
  ConsumerState<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends ConsumerState<UpdatesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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
      ref.read(updatesFeedProvider.notifier).loadMore();
    }
  }

  // ---- Stub function to be implemented later ----
  void _createPost() {
    // TODO: open the create-post flow.
  }
  // -------------------------------------------------

  void _handleCreatePost() {
    _createPost();
  }

  void _openTab(NavigationTab tab) {
    if (tab == NavigationTab.updates) return;

    final Widget screen = switch (tab) {
      NavigationTab.chats => const ChatScreen(),
      NavigationTab.contacts => const ContactsScreen(),
      NavigationTab.settings => const SettingsScreen(),
      _ => const ChatScreen(),
    };

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(updatesFeedProvider);

    return AdaptiveNavigationShell(
      currentTab: NavigationTab.updates,
      onTabSelected: _openTab,
      child: _buildContent(context, feed),
    );
  }

  Widget _buildContent(BuildContext context, AsyncValue<UpdatesFeedState> feed) {
    final theme = Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;
    // Feed content is always rendered; while the first page is still being
    // fetched (or failed), empty state + an inline banner carry the UI.
    final state = feed.value ?? const UpdatesFeedState();

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

              // Inline error banner (only when there's nothing else to show).
              if (feed.hasError && state.posts.isEmpty)
                _buildErrorBanner(context, theme),

              // Feed
              Expanded(
                child: state.posts.isEmpty
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
                        itemCount: state.posts.length + 1,
                        itemBuilder: (context, index) {
                          if (index < state.posts.length) {
                            final post = state.posts[index];
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
                          if (state.isLoadingMore) {
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
                          if (!state.hasMore) {
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

  Widget _buildErrorBanner(BuildContext context, AppColorScheme theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: theme.border.withAlpha(90),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: AppColors.mutedSlate, size: 18.0),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              "Couldn't load updates.",
              style: AppTypography.getTextStyle(
                context,
                AppTextType.tiny,
                color: AppColors.mutedSlate,
              ),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(updatesFeedProvider.notifier).refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}