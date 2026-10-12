import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//  AppColorScheme, AppTypography, AppColors, and ConversationListItem 
import '../engine/database/app_database.dart';
import '../widgets/app_theme.dart';
import '../widgets/display/conversation_card.dart';
import '../widgets/display/navigation.dart';
import '../state/providers.dart';
import '../utils/formatting.dart';
import 'chatting.dart';
import 'contacts_screen.dart';
import 'settings_screen.dart';
import 'updates_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  NavigationTab _currentTab = NavigationTab.chats;

  /// When true the chat list shows archived conversations instead of the
  /// active ones.
  bool _showArchived = false;

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

        if (tab == NavigationTab.updates) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const UpdatesScreen()),
          );
          return;
        }

        if (tab == NavigationTab.settings) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
                IconButton(
                  onPressed: () =>
                      setState(() => _showArchived = !_showArchived),
                  icon: Icon(
                    _showArchived
                        ? Icons.unarchive_outlined
                        : Icons.archive_outlined,
                    color: _showArchived
                        ? AppColors.haloRing
                        : themeExtension.textInputColor,
                  ),
                  tooltip: _showArchived ? 'Back to chats' : 'Archived',
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  icon: Icon(Icons.settings_outlined, color: themeExtension.textInputColor),
                  tooltip: 'Settings',
                ),
              ],
            ),
          ),
          Divider(color: themeExtension.border, height: 1.0),
        ],

        // Desktop Title (Only shown on Desktop)
        if (isDesktop) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _showArchived ? 'Archived' : 'Recent Conversations',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: themeExtension.textInputColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      setState(() => _showArchived = !_showArchived),
                  icon: Icon(
                    _showArchived
                        ? Icons.unarchive_outlined
                        : Icons.archive_outlined,
                    color: _showArchived
                        ? AppColors.haloRing
                        : themeExtension.textInputColor,
                  ),
                  tooltip: _showArchived ? 'Back to chats' : 'Archived',
                ),
              ],
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
                  _showArchived ? 'ARCHIVED' : 'RECENT CONVERSATIONS',
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
        final visible = rows
            .where((row) => (row.archived == 1) == _showArchived)
            .toList(growable: false);

        if (visible.isEmpty) {
          return Center(
            child: Text(
              _showArchived ? 'No archived conversations' : 'No conversations yet',
              style: TextStyle(color: themeExtension.textInputColor),
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            for (final row in visible) ...[
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
                onLongPress: () => _showConversationActions(row),
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

  Future<void> _showConversationActions(SyncStateData row) async {
    final isArchived = row.archived == 1;
    final isPinned = row.pinned == 1;
    final isMuted = row.muted == 1;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                isArchived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
              ),
              title: Text(isArchived ? 'Unarchive' : 'Archive'),
              onTap: () {
                Navigator.pop(sheetContext);
                ref
                    .read(syncStatesProvider.notifier)
                    .setArchived(row.conversationId, archived: !isArchived);
              },
            ),
            ListTile(
              leading: Icon(
                isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              ),
              title: Text(isPinned ? 'Unpin' : 'Pin'),
              onTap: () {
                Navigator.pop(sheetContext);
                ref
                    .read(syncStatesProvider.notifier)
                    .setPinned(row.conversationId, pinned: !isPinned);
              },
            ),
            ListTile(
              leading: Icon(
                isMuted
                    ? Icons.notifications_off
                    : Icons.notifications_none,
              ),
              title: Text(isMuted ? 'Unmute' : 'Mute'),
              onTap: () {
                Navigator.pop(sheetContext);
                ref
                    .read(syncStatesProvider.notifier)
                    .setMuted(row.conversationId, muted: !isMuted);
              },
            ),
            ListTile(
              leading: const Icon(Icons.done_all),
              title: const Text('Mark as read'),
              onTap: () {
                Navigator.pop(sheetContext);
                ref
                    .read(syncStatesProvider.notifier)
                    .markRead(
                      row.conversationId,
                      messageId: row.lastMessageId ?? '',
                      message: row.lastMessage ?? '',
                    );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Color(0xFFF44336),
              ),
              title: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFF44336)),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _confirmDelete(row);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(SyncStateData row) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: Text(
          'This permanently deletes your chat with '
          '${row.displayName} and all of its messages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFF44336)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await ref.read(syncStatesProvider.notifier).delete(row.conversationId);
  }
}