import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//  AppColorScheme, AppTypography, AppColors, and ConversationListItem 
import '../widgets/app_theme.dart';
import '../widgets/display/conversation_card.dart';
import '../widgets/display/navigation.dart';
import '../state/providers.dart';
import '../utils/formatting.dart';
import 'chatting.dart';
import 'contacts_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  NavigationTab _currentTab = NavigationTab.chats;

  @override
  Widget build(BuildContext context) {
    final themeExtension =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

    return AdaptiveNavigationShell(
      currentTab: _currentTab,
      onTabSelected: (tab) {
        if (tab == NavigationTab.contacts) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ContactsScreen()),
          );
          return;
        }

        setState(() => _currentTab = tab);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 600 ||
              MediaQuery.of(context).orientation == Orientation.landscape;

          if (isDesktop) {
            return Row(
              children: [
                // Left Panel - Chat List
                Container(
                  width: 350.0,
                  decoration: BoxDecoration(
                    color: themeExtension.background,
                    border: Border(
                      right: BorderSide(
                        color: themeExtension.border,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: _buildChatListPanel(context, themeExtension, isDesktop: true),
                ),
                // Right Panel - Workspace/Placeholder
                Expanded(
                  child: _buildDesktopPlaceholder(context, themeExtension),
                ),
              ],
            );
          }

          // Mobile Layout
          return SafeArea(
            child: _buildChatListPanel(context, themeExtension, isDesktop: false),
          );
        },
      ),
    );
  }

  Widget _buildChatListPanel(
    BuildContext context,
    AppColorScheme themeExtension, {
    required bool isDesktop,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mobile Top Header (Hidden on Desktop as Side Nav handles it)
        if (!isDesktop) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
            child: Row(
              children: [
                Icon(Icons.chat_bubble, color: themeExtension.textInputColor, size: 28.0),
                const SizedBox(width: 12.0),
                Text(
                  'Chats',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: themeExtension.textInputColor,
                  ),
                ),
                const Spacer(),
                Icon(Icons.people_outline, color: themeExtension.textInputColor, size: 24.0),
                const SizedBox(width: 16.0),
                Icon(Icons.settings_outlined, color: themeExtension.textInputColor, size: 24.0),
              ],
            ),
          ),
          Divider(color: themeExtension.border, height: 1.0),
        ],

        // Desktop Title (Only shown on Desktop)
        if (isDesktop) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Recent Conversations',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: themeExtension.textInputColor,
              ),
            ),
          ),
        ],

        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 40.0,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2329) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: TextField(
              style: TextStyle(color: themeExtension.textInputColor),
              decoration: InputDecoration(
                hintText: 'Search messages or contacts...',
                hintStyle: TextStyle(
                  color: isDark ? const Color(0xFF9095A1) : const Color(0xFFBCC1CA),
                  fontSize: 14.0,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? const Color(0xFF9095A1) : const Color(0xFFBCC1CA),
                  size: 20.0,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),

        // Sub-header (Recent Conversations & Mark All Read) for Mobile
        if (!isDesktop) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT CONVERSATIONS',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF9095A1) : const Color(0xFF565D6D),
                    letterSpacing: 0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () => ref
                      .read(syncStatesProvider.notifier)
                      .markAllRead(),
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2EB82E), // Green success color
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Chat List
        Expanded(child: _buildConversationList(themeExtension)),

        // Desktop Bottom "Mark all read" Action
        if (isDesktop) ...[
          Divider(color: themeExtension.border, height: 1.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () =>
                    ref.read(syncStatesProvider.notifier).markAllRead(),
                child: const Text(
                  'Mark all read',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2EB82E),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopPlaceholder(BuildContext context, AppColorScheme themeExtension) {
    return Container(
      color: themeExtension.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom Slashed Circle Icon
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2EB82E), // Green
                        width: 4.0,
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: -0.785, // -45 degrees
                    child: Container(
                      width: 4.0,
                      height: 110,
                      decoration: BoxDecoration(
                        color: themeExtension.textInputColor,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'No chat selected',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: themeExtension.textInputColor,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Select a contact to resume a conversation',
              style: TextStyle(
                fontSize: 14.0,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF9095A1)
                    : const Color(0xFF565D6D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationList(AppColorScheme themeExtension) {
    final syncStates = ref.watch(syncStatesProvider);

    return syncStates.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Could not load conversations.',
            textAlign: TextAlign.center,
            style: TextStyle(color: themeExtension.textInputColor),
          ),
        ),
      ),
      data: (rows) {
        if (rows.isEmpty) {
          return Center(
            child: Text(
              'No conversations yet',
              style: TextStyle(color: themeExtension.textInputColor),
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            for (final row in rows) ...[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Chatting(
                        conversationId: row.conversationId,
                        displayName: row.displayName,
                        avatarUrl: row.avatar ?? '',
                        status: row.status,
                        conversationType: row.conversationType,
                      ),
                    ),
                  );
                },
                child: ConversationListItem(
                  displayName: row.displayName,
                  lastMessage: row.lastMessage ?? '',
                  time: formatChatTime(row.updatedAt),
                  avatarUrl: row.avatar ?? '',
                  colour: parseHexColour(row.colour),
                  unreadCount: row.unreadCount,
                  mentions: row.mentions,
                  isMuted: row.muted == 1,
                  isPinned: row.pinned == 1,
                  status: row.status,
                ),
              ),
              Divider(color: themeExtension.border, height: 1, indent: 90),
            ],
          ],
        );
      },
    );
  }
}