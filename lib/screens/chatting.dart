import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../state/providers.dart';
import '../widgets/chats/chat_bubble_component.dart';
import '../widgets/chats/chat_input_component.dart';

class Chatting extends ConsumerStatefulWidget {
  final String conversationId;
  final String displayName;
  final String avatarUrl;
  final int status;
  final int conversationType;

  const Chatting({
    super.key,
    required this.conversationId,
    required this.displayName,
    this.avatarUrl = '',
    this.status = 0,
    this.conversationType = 0,
  });

  @override
  ConsumerState<Chatting> createState() => _ChattingState();
}

class _ChattingState extends ConsumerState<Chatting> {
  static const _uuid = Uuid();
  final ScrollController _scrollController = ScrollController();
  int _lastItemCount = 0;

  bool get _isGroup => widget.conversationType == 1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _maybeScrollToBottom(int itemCount) {
    if (_scrollController.hasClients && itemCount > _lastItemCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
    _lastItemCount = itemCount;
  }

  Color _statusColor() {
    switch (widget.status) {
      case 1:
        return const Color(0xFF2EB82E);
      case 2:
        return const Color(0xFFFFC107);
      case 3:
        return const Color(0xFFF44336);
      case 0:
      default:
        return const Color(0xFFDEE1E6);
    }
  }

  String _statusLabel() {
    switch (widget.status) {
      case 1:
        return 'ACTIVE NOW';
      case 2:
        return 'AWAY';
      case 3:
        return 'BUSY';
      case 0:
      default:
        return 'OFFLINE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final messagesAsync = ref.watch(chatMessagesProvider(widget.conversationId));
    final syncState =
        ref.watch(conversationSyncStateProvider(widget.conversationId));
    final draft = syncState.value?.draft ?? '';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          _buildHeader(context, colorScheme),
          Expanded(child: _buildMessages(context, colorScheme, messagesAsync)),
          ChatInput(
            initialText: draft,
            onTextChanged: (text) => ref
                .read(syncStateDaoProvider)
                .updateDraft(widget.conversationId, text),
            groupMembers: const [],
            onSendMessage: (text, mediaType, {mediaUrl}) {
              unawaited(_queueMessage(text));
            },
          ),
        ],
      ),
    );
  }

  Future<void> _queueMessage(String text) async {
    final conversation = await ref
        .read(conversationsDaoProvider)
        .getConversationById(widget.conversationId);
    if (!mounted) return;

    if (conversation == null || conversation.serverId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This conversation has no server.')),
      );
      return;
    }

    try {
      final session = await ref
          .read(appDatabaseProvider)
          .sessionsDao
          .getSessionByConversationId(widget.conversationId);
      final handshakeRequired = session?.status != 2;

      if (handshakeRequired) {
        await ref.read(taskQueueProvider).queueTask(
              functionName: 'sendChatHandshakeDh',
              args: [widget.conversationId, conversation.serverId],
              serverId: conversation.serverId,
            );
        await ref.read(taskQueueProvider).queueTask(
              functionName: 'sendChatHandshakeConfirmation',
              args: [widget.conversationId, conversation.serverId],
              serverId: conversation.serverId,
            );
      }

      await ref.read(taskQueueProvider).queueTask(
            functionName: 'sendChatMessage',
            args: [
              widget.conversationId,
              text,
              conversation.serverId,
              _uuid.v4(),
              _uuid.v4(),
            ],
            serverId: conversation.serverId,
          );

      await ref
          .read(syncStateDaoProvider)
          .updateDraft(widget.conversationId, '');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not queue message: $error')),
      );
    }
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    final initials = widget.displayName.isNotEmpty
        ? widget.displayName
            .trim()
            .split(' ')
            .where((w) => w.isNotEmpty)
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase()
        : (_isGroup ? 'G' : 'U');

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.only(top: 8, bottom: 12, left: 8, right: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: colorScheme.onSurface, size: 20),
            onPressed: () => Navigator.maybePop(context),
          ),
          const SizedBox(width: 4),
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: widget.avatarUrl.isNotEmpty
                    ? NetworkImage(widget.avatarUrl)
                    : null,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!_isGroup)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _statusColor(),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: colorScheme.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.circle, color: _statusColor(), size: 6),
                    const SizedBox(width: 4),
                    Text(
                      _statusLabel(),
                      style: TextStyle(
                        color: _statusColor(),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                color: Colors.green),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(
    BuildContext context,
    ColorScheme colorScheme,
    AsyncValue<List<ChatMessageItem>> messagesAsync,
  ) {
    return messagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'Could not load messages.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Text(
              'No messages yet',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          );
        }

        _maybeScrollToBottom(items.length);

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              ChatBubbleComponent(message: items[index]),
        );
      },
    );
  }
}