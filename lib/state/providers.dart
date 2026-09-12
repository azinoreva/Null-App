import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/database/app_database.dart';
import '../engine/network/updates/check_updates.dart';
import '../engine/database/queries/contacts_queries.dart';
import '../engine/database/queries/group_members_queries.dart';
import '../engine/database/queries/groups_queries.dart';
import '../engine/database/queries/identity_queries.dart';
import '../engine/database/queries/messages_queries.dart';
import '../engine/database/queries/sync_state_queries.dart';
import '../utils/formatting.dart';
import '../widgets/chats/chat_bubble_component.dart';

/// Data needed to render one post in the updates feed (see [UpdateComponent]).
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

/// Simple data holder for one contact entry shown in the contacts screen.
///
/// [displayName] follows the same "Name - Title" convention used by
/// [ContactCard] (e.g. "Alice Johnson - Product Designer").
class ContactData {
  final String avatarUrl;
  final String displayName;
  final int isOnline;

  const ContactData({
    required this.avatarUrl,
    required this.displayName,
    required this.isOnline,
  });

  /// Just the name portion, used for sorting / grouping by letter.
  String get name {
    final dashIndex = displayName.indexOf('-');
    return dashIndex == -1 ? displayName.trim() : displayName.substring(0, dashIndex).trim();
  }
}

/// The app's single [AppDatabase] instance.
///
/// This provider has no default value; it is overridden in `main()` with the
/// database created by `DatabaseInitializer.initialize()`.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden in ProviderScope '
    'with the initialized AppDatabase instance.',
  );
});

/// Data access object for the `sync_state` table.
///
/// Reads, writes, and — most importantly — streamed watchers for the table.
final syncStateDaoProvider = Provider<SyncStateDao>((ref) {
  return ref.watch(appDatabaseProvider).syncStateDao;
});

/// Reactive mirror of the `sync_state` table.
///
/// Riverpod is the single source of sync state for the chat UI. The notifier
/// subscribes to [SyncStateDao.watchAllSyncStates], so any change made to the
/// `sync_state` table (here or anywhere else in the app) is picked up and the
/// UI rebuilds automatically.
final syncStatesProvider =
    AsyncNotifierProvider<SyncStatesNotifier, List<SyncStateData>>(
  SyncStatesNotifier.new,
);

class SyncStatesNotifier extends AsyncNotifier<List<SyncStateData>> {
  StreamSubscription<List<SyncStateData>>? _subscription;

  @override
  Future<List<SyncStateData>> build() async {
    final dao = ref.watch(syncStateDaoProvider);
    final ready = Completer<void>();

    _subscription = dao.watchAllSyncStates().listen(
      (rows) {
        state = AsyncData(List.unmodifiable(rows));
        if (!ready.isCompleted) ready.complete();
      },
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncError(error, stackTrace);
        if (!ready.isCompleted) ready.complete();
      },
    );

    ref.onDispose(() => _subscription?.cancel());

    await ready.future;
    return state.value ?? const [];
  }

  SyncStateDao get _dao => ref.read(syncStateDaoProvider);

  /// Creates or overwrites a conversation's sync state row.
  Future<void> upsert(SyncStateData row) => _dao.upsertSyncState(row);

  /// Marks every conversation as read.
  Future<void> markAllRead() => _dao.markAllRead();

  /// Marks a single conversation as read up to [messageId].
  Future<void> markRead(
    String conversationId, {
    required String messageId,
    required String message,
  }) =>
      _dao.updateLastRead(
        conversationId,
        messageId: messageId,
        message: message,
        unreadCount: 0,
      );

  /// Updates the last message preview shown in the chat list.
  Future<void> updateLastMessage(
    String conversationId, {
    required String messageId,
    required String message,
  }) =>
      _dao.updateLastMessage(
        conversationId,
        messageId: messageId,
        message: message,
      );

  /// Pins or unpins a conversation.
  Future<void> setPinned(
    String conversationId, {
    required bool pinned,
    int? position,
  }) =>
      _dao.setPinned(
        conversationId,
        pinned: pinned ? 1 : 0,
        pinnedPosition: position,
      );

  /// Mutes or unmutes a conversation.
  Future<void> setMuted(String conversationId, {required bool muted}) =>
      _dao.setMuted(conversationId, muted ? 1 : 0);

  /// Updates the ring colour shown around the avatar.
  Future<void> updateColour(String conversationId, String colour) =>
      _dao.updateColour(conversationId, colour);

  /// Saves or clears the draft for a conversation.
  Future<void> updateDraft(String conversationId, String? draft) =>
      _dao.updateDraft(conversationId, draft);

  /// Adds mention count for a conversation.
  Future<void> addMentions(String conversationId, int mentions) =>
      _dao.setMentions(conversationId, mentions);

  /// Removes a conversation from the sync state.
  Future<void> remove(String conversationId) =>
      _dao.deleteSyncState(conversationId);
}

/// Data access object for the `Messages` table.
final messagesDaoProvider = Provider<MessagesDao>((ref) {
  return ref.watch(appDatabaseProvider).messagesDao;
});

/// Data access object for the `Contacts` table.
final contactsDaoProvider = Provider<ContactsDao>((ref) {
  return ref.watch(appDatabaseProvider).contactsDao;
});

/// Data access object for the `Identity` table.
final identityDaoProvider = Provider<IdentityDao>((ref) {
  return ref.watch(appDatabaseProvider).identityDao;
});

/// Data access object for the `Groups` table.
final groupsDaoProvider = Provider<GroupsDao>((ref) {
  return ref.watch(appDatabaseProvider).groupsDao;
});

/// Data access object for the `GroupMembers` table.
final groupMembersDaoProvider = Provider<GroupMembersDao>((ref) {
  return ref.watch(appDatabaseProvider).groupMembersDao;
});

/// The current user's identity id, or `null` while no identity exists yet.
///
/// Determines which messages are "mine" (aligned right, delivery status).
final currentUserIdProvider = FutureProvider<String?>((ref) async {
  final identity =
      await ref.watch(identityDaoProvider).getCurrentIdentityOrNull();
  return identity?.identityId;
});

/// A live view of one conversation's `sync_state` row.
///
/// The chat screen watches this for the header, the draft, and — most
/// importantly — `lastMessageId` changes, which drive the partial update of
/// the message list (append only the new messages instead of a full reload).
final conversationSyncStateProvider =
    StreamProvider.family<SyncStateData?, String>((ref, conversationId) {
  return ref.watch(syncStateDaoProvider).watchSyncStateById(conversationId);
});

/// The rendered message list for a conversation.
///
/// Built from the `messages` table, using `sync_state.lastMessageId` to anchor
/// the initial window (the last 20 messages up to that message's order). When
/// `lastMessageId` changes, [ChatMessagesNotifier] appends only the messages
/// newer than the last loaded one — the DB and UI update partially rather than
/// reloading the whole conversation.
final chatMessagesProvider =
    AsyncNotifierProvider.family<ChatMessagesNotifier, List<ChatMessageItem>,
        String>(ChatMessagesNotifier.new);

class ChatMessagesNotifier extends AsyncNotifier<List<ChatMessageItem>> {
  ChatMessagesNotifier(this.conversationId);

  /// Conversation being rendered (matches `sync_state.conversationId`).
  final String conversationId;

  static const int _initialWindow = 20;

  /// Highest `message_order` currently held in state, or -1 when empty.
  int _loadedUpToOrder = -1;

  /// The `lastMessageId` the state currently reflects. Used to ignore
  /// `sync_state` emissions that don't advance the conversation.
  String? _lastProcessedMessageId;

  bool _deltaBusy = false;
  bool _deltaPending = false;

  @override
  Future<List<ChatMessageItem>> build() async {
    final messagesDao = ref.watch(messagesDaoProvider);
    final syncState =
        await ref.watch(syncStateDaoProvider).getSyncStateById(conversationId);
    final ownId = await ref.watch(currentUserIdProvider.future);
    final isGroup = (syncState?.conversationType ?? 0) == 1;

    _lastProcessedMessageId = syncState?.lastMessageId;
    _loadedUpToOrder = -1;

    final List<Message> initialMessages = await _loadWindow(messagesDao, syncState?.lastMessageId);

    ref.listen(conversationSyncStateProvider(conversationId),
        (previous, next) {
      unawaited(_onSyncStateChanged(next.value));
    });

    return _toChatItems(initialMessages, isGroup: isGroup, ownId: ownId);
  }

  /// Loads a window of messages. When [anchorMessageId] is set, the window
  /// is the last [_initialWindow] messages with order <= the anchor's order.
  Future<List<Message>> _loadWindow(
    MessagesDao dao,
    String? anchorMessageId,
  ) async {
    final List<Message> messages;
    if (anchorMessageId != null) {
      final anchor = await dao.getMessageById(anchorMessageId);
      messages = await dao.getMessagesBeforeOrder(
        conversationId,
        anchor?.messageOrder ?? 0,
        limit: _initialWindow,
      );
    } else {
      messages = await dao.getLastMessages(conversationId, limit: _initialWindow);
    }

    messages.sort((a, b) => a.messageOrder.compareTo(b.messageOrder));
    _loadedUpToOrder = messages.isEmpty ? -1 : messages.last.messageOrder;
    return messages;
  }

  Future<void> _onSyncStateChanged(SyncStateData? next) async {
    final anchorId = next?.lastMessageId;
    if (anchorId == null || anchorId == _lastProcessedMessageId) return;
    final previousId = _lastProcessedMessageId;

    final messagesDao = ref.read(messagesDaoProvider);
    final anchor = await messagesDao.getMessageById(anchorId);

    if (anchor != null && anchor.messageOrder > _loadedUpToOrder) {
      // Newer messages arrived: a partial append of only what's new.
      _lastProcessedMessageId = anchorId;
      await _appendDelta();

      final haveAnchor =
          (state.value ?? const <ChatMessageItem>[]).any((m) => m.id == anchorId);
      if (!haveAnchor) _lastProcessedMessageId = previousId;
      return;
    }

    if (anchor != null) {
      // Anchor moved to an older position (rare) — full window reload.
      _lastProcessedMessageId = anchorId;
      final syncState =
          await ref.read(syncStateDaoProvider).getSyncStateById(conversationId);
      final ownId = await ref.read(currentUserIdProvider.future);
      final isGroup = (syncState?.conversationType ?? 0) == 1;
      final window = await _loadWindow(messagesDao, anchorId);
      state =
          AsyncData(await _toChatItems(window, isGroup: isGroup, ownId: ownId));
      return;
    }

    // The message row isn't written yet; retry on the next emission.
    _lastProcessedMessageId = previousId;
  }

  Future<void> _appendDelta() async {
    if (_deltaBusy) {
      _deltaPending = true;
      return;
    }
    _deltaBusy = true;
    try {
      do {
        _deltaPending = false;
        final fresh = await ref
            .read(messagesDaoProvider)
            .getMessagesAfterOrder(conversationId, _loadedUpToOrder);
        if (fresh.isEmpty) break;

        final current = state.value ?? const <ChatMessageItem>[];
        final existingIds = current.map((m) => m.id).toSet();
        final ownId = await ref.read(currentUserIdProvider.future);
        final syncState =
            await ref.read(syncStateDaoProvider).getSyncStateById(conversationId);
        final isGroup = (syncState?.conversationType ?? 0) == 1;

        final additions = (await _toChatItems(fresh, isGroup: isGroup, ownId: ownId))
            .where((m) => !existingIds.contains(m.id))
            .toList();

        _loadedUpToOrder =
            _loadedUpToOrder > fresh.last.messageOrder ? _loadedUpToOrder : fresh.last.messageOrder;
        if (additions.isEmpty) break;

        state = AsyncData([...current, ...additions]);
      } while (_deltaPending);
    } finally {
      _deltaBusy = false;
      if (_deltaPending) {
        _deltaPending = false;
        unawaited(_appendDelta());
      }
    }
  }

  Future<List<ChatMessageItem>> _toChatItems(
    List<Message> messages, {
    required bool isGroup,
    String? ownId,
  }) async {
    if (messages.isEmpty) return const [];

    Map<String, GroupMember> membersById = const {};
    if (isGroup) {
      final members =
          await ref.read(groupMembersDaoProvider).getMembersOfGroup(conversationId);
      membersById = {for (final m in members) m.identityId: m};
    }

    final contact = isGroup
        ? null
        : await ref.read(contactsDaoProvider).getContactByConversationId(conversationId);

    final items = <ChatMessageItem>[];
    for (final m in messages) {
      final isMe = ownId != null && m.senderId == ownId;

      SenderPresentation? sender;
      if (isGroup) {
        final member = membersById[m.senderId];
        if (member != null) {
          sender = SenderPresentation(
            userId: member.identityId,
            displayName: member.name,
          );
        }
      } else if (!isMe && contact != null) {
        sender = SenderPresentation(
          userId: contact.contactId,
          displayName: contact.nickname,
        );
      }

      items.add(ChatMessageItem(
        id: m.messageId,
        isMe: isMe,
        chatType: isGroup ? ChatType.group : ChatType.individual,
        sender: sender,
        content: m.decryptedMessage ?? '',
        mediaType: MessageMediaType.text,
        timestamp: formatChatTime(m.timestamp),
        isEdited: m.edited == 1,
        deliveryStatus: isMe ? _deliveryStatusFor(m.status) : null,
      ));
    }
    return items;
  }

  DeliveryStatus _deliveryStatusFor(int status) {
    if (status >= 3) return DeliveryStatus.read;
    if (status == 2) return DeliveryStatus.delivered;
    if (status == 1) return DeliveryStatus.sent;
    return DeliveryStatus.sending;
  }
}

/// API client used to fetch the updates feed. Every request is scoped to a
/// single server; the app's main server id is `server_1`.
final updatesServiceProvider = Provider<UpdatesService>((ref) {
  return const UpdatesService(serverId: 'server_1');
});

/// The state of the updates feed screen: the rendered posts plus its
/// pagination bookkeeping.
class UpdatesFeedState {
  final List<PostData> posts;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  const UpdatesFeedState({
    this.posts = const [],
    this.page = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  UpdatesFeedState copyWith({
    List<PostData>? posts,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return UpdatesFeedState(
      posts: posts ?? this.posts,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Owns the updates feed screen's state.
///
/// Intentionally NOT autoDisposed: the notifier (and its loaded pages) is
/// kept alive for the lifetime of the ProviderScope, so navigating away and
/// back renders the cached feed instantly instead of refetching.
final updatesFeedProvider =
    AsyncNotifierProvider<UpdatesFeedNotifier, UpdatesFeedState>(
  UpdatesFeedNotifier.new,
);

class UpdatesFeedNotifier extends AsyncNotifier<UpdatesFeedState> {
  static const int _pageSize = 20;

  /// Hard cap on a feed request so the screen never hangs on the network.
  static const Duration _fetchTimeout = Duration(seconds: 4);

  UpdatesService get _service => ref.read(updatesServiceProvider);

  @override
  Future<UpdatesFeedState> build() async {
    // Non-blocking first load: return an empty feed immediately and fetch in
    // the background, so the screen always renders instead of freezing on a
    // full-screen spinner.
    _scheduleBackgroundRefresh();
    return const UpdatesFeedState();
  }

  void _scheduleBackgroundRefresh() {
    // Defer to after this build so state updates never happen mid-build.
    Future<void>.delayed(Duration.zero, () async {
      await refresh();
    });
  }

  /// Reloads the feed from the first page. Used by the background loader and
  /// the inline retry.
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await _loadFirstPage());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<UpdatesFeedState> _loadFirstPage() async {
    final updates =
        await _service.getUpdates(limit: _pageSize).timeout(_fetchTimeout);
    return UpdatesFeedState(
      posts: updates.map(_toPostData).toList(),
      page: 1,
      hasMore: updates.length == _pageSize,
    );
  }

  /// Appends the next page of posts. No-op while a page is already loading
  /// or when there's nothing left to fetch.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final updates = await _service
          .getUpdates(limit: _pageSize, before: current.posts.length)
          .timeout(_fetchTimeout);
      if (updates.isEmpty) {
        state = AsyncData(
          current.copyWith(isLoadingMore: false, hasMore: false),
        );
        return;
      }

      state = AsyncData(
        UpdatesFeedState(
          posts: [...current.posts, ...updates.map(_toPostData)],
          page: current.page + 1,
          hasMore: updates.length == _pageSize,
        ),
      );
    } catch (_) {
      // Keep the already-loaded posts; surface the failure by clearing the
      // loading flag so the footer returns to its normal state.
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  PostData _toPostData(Update update) {
    return PostData(
      avatarUrl:
          'https://api.dicebear.com/7.x/avataaars/png?seed='
          '${Uri.encodeComponent(update.nickname)}&size=128',
      nickname: update.nickname,
      timeText: '',
      text: update.text,
      mediaUrl: update.media?.mediaUrl,
    );
  }
}

/// Owns the contacts screen's state (connected contacts only).
///
/// Intentionally NOT autoDisposed: the loaded list is kept alive for the
/// lifetime of the ProviderScope, so re-entering the screen renders from
/// cache instead of hitting the database again.
final contactsProvider =
    AsyncNotifierProvider<ContactsNotifier, List<ContactData>>(
  ContactsNotifier.new,
);

class ContactsNotifier extends AsyncNotifier<List<ContactData>> {
  ContactsDao get _dao => ref.read(contactsDaoProvider);

  @override
  Future<List<ContactData>> build() async {
    final rows = await _dao.getConnectedContacts();
    return rows.map(_toContactData).toList();
  }

  /// Reloads the contact list from the database. Call after any contact
  /// save/change so the cached list stays in sync.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final rows = await _dao.getConnectedContacts();
      return rows.map(_toContactData).toList();
    });
  }

  ContactData _toContactData(Contact contact) {
    return ContactData(
      avatarUrl: _avatarUrlFor(contact),
      displayName: (contact.nickname?.trim().isNotEmpty ?? false)
          ? contact.nickname!.trim()
          : contact.contactId,
      isOnline: contact.isOnline,
    );
  }

  /// Stored avatars are PNG blobs; expose them as data URIs so the existing
  /// `NetworkImage(avatarUrl)` widgets keep working. Falls back to a
  /// deterministic Dicebear avatar when the contact has no stored image.
  String _avatarUrlFor(Contact contact) {
    final avatar = contact.avatar;
    if (avatar != null && avatar.isNotEmpty) {
      return 'data:image/png;base64,${base64Encode(avatar)}';
    }
    return 'https://api.dicebear.com/7.x/avataaars/png?seed='
        '${Uri.encodeComponent(contact.contactId)}&size=128';
  }
}