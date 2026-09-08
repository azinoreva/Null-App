// ==========================================
// FILE 1: chat_bubble_component.dart
// ==========================================

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum ChatType { individual, group }
enum DeliveryStatus { sending, sent, delivered, read }
enum MessageMediaType { text, image, video, file }

class SenderPresentation {
  final String userId;
  final String? avatarUrl;
  final String? displayName;

  const SenderPresentation({
    required this.userId,
    this.avatarUrl,
    this.displayName,
  });
}

class ReplyPreview {
  final String messageId;
  final String senderName;
  final String snippet;
  final String? mediaUrl;

  const ReplyPreview({
    required this.messageId,
    required this.senderName,
    required this.snippet,
    this.mediaUrl,
  });
}

class MessageReaction {
  final String emoji;
  final int count;
  final bool isReactedByMe;

  const MessageReaction({
    required this.emoji,
    required this.count,
    this.isReactedByMe = false,
  });
}

class ChatMessageItem {
  final String id;
  final bool isMe;
  final ChatType chatType;
  final SenderPresentation? sender;
  final ReplyPreview? replyPreview;
  final String content;
  final MessageMediaType mediaType;
  final String? mediaUrl;
  final String timestamp;
  final bool isEdited;
  final DeliveryStatus? deliveryStatus;
  final List<MessageReaction>? reactions;

  const ChatMessageItem({
    required this.id,
    required this.isMe,
    required this.chatType,
    this.sender,
    this.replyPreview,
    required this.content,
    this.mediaType = MessageMediaType.text,
    this.mediaUrl,
    required this.timestamp,
    this.isEdited = false,
    this.deliveryStatus,
    this.reactions,
  });
}

// Utility functions for Spoiler translation
String encodeSpoiler(String text) => '||$text||';
String decodeSpoiler(String spoilerText) => spoilerText.replaceAll('||', '');

class ChatBubbleComponent extends StatelessWidget {
  final ChatMessageItem message;
  final Function(String messageId)? onReplyClick;
  final Function(String emoji)? onReactionClick;
  final Function(String url)? onMediaClick;
  final Function(String url)? onLinkClick;

  const ChatBubbleComponent({
    super.key,
    required this.message,
    this.onReplyClick,
    this.onReactionClick,
    this.onMediaClick,
    this.onLinkClick,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool showSenderInfo = !message.isMe && message.chatType == ChatType.group;

    final incomingBgColor = isDark ? const Color(0xFF1E2329) : const Color(0xFF2C3038);
    final incomingTextColor = Colors.white;

    final outgoingBgColor = isDark ? const Color(0xFF86EFAC) : const Color(0xFFE5E7EB);
    final outgoingTextColor = isDark ? const Color(0xFF0F172A) : const Color(0xFF171A1F);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSenderInfo) ...[
            _buildAvatar(message.sender),
            const SizedBox(width: 8.0),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (showSenderInfo && message.sender?.displayName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0, left: 4.0),
                    child: Text(
                      message.sender?.displayName ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9095A1),
                      ),
                    ),
                  ),

                // Main Chat Container
                GestureDetector(
                  onDoubleTap: () {
                    if (onReplyClick != null) onReplyClick!(message.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: message.isMe ? outgoingBgColor : incomingBgColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16.0),
                        topRight: const Radius.circular(16.0),
                        bottomLeft: Radius.circular(message.isMe ? 16.0 : 4.0),
                        bottomRight: Radius.circular(message.isMe ? 4.0 : 16.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Reply Preview
                        if (message.replyPreview != null)
                          _buildReplyPreviewWidget(
                            context,
                            message.replyPreview!,
                            message.isMe,
                            outgoingTextColor,
                            incomingTextColor,
                          ),

                        // Media Attachment
                        if (message.mediaUrl != null && message.mediaUrl!.isNotEmpty)
                          _buildMediaContent(message.mediaType, message.mediaUrl!),

                        // Message Text Content
                        if (message.content.isNotEmpty)
                          RichMessageText(
                            text: message.content,
                            textColor: message.isMe ? outgoingTextColor : incomingTextColor,
                            isMe: message.isMe,
                            onLinkClick: onLinkClick,
                          ),
                      ],
                    ),
                  ),
                ),

                // Footer (Timestamp, Edited, Delivery Status)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.timestamp,
                        style: const TextStyle(
                          fontSize: 10.0,
                          color: Color(0xFF9095A1),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (message.isEdited) ...[
                        const SizedBox(width: 4.0),
                        const Text(
                          '(edited)',
                          style: TextStyle(fontSize: 10.0, color: Color(0xFF9095A1)),
                        ),
                      ],
                      if (message.isMe && message.deliveryStatus != null) ...[
                        const SizedBox(width: 4.0),
                        _buildDeliveryIcon(message.deliveryStatus!),
                      ],
                    ],
                  ),
                ),

                // Reactions Bar
                if (message.reactions != null && message.reactions!.isNotEmpty)
                  _buildReactionsBar(message.reactions!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(SenderPresentation? sender) {
    return CircleAvatar(
      radius: 16.0,
      backgroundColor: const Color(0xFF323741),
      backgroundImage: (sender?.avatarUrl != null && sender!.avatarUrl!.isNotEmpty)
          ? NetworkImage(sender.avatarUrl!)
          : null,
      child: (sender?.avatarUrl == null || sender!.avatarUrl!.isEmpty)
          ? Text(
              (sender?.displayName != null && sender!.displayName!.isNotEmpty)
                  ? sender.displayName![0].toUpperCase()
                  : 'U',
              style: const TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.bold),
            )
          : null,
    );
  }

  Widget _buildReplyPreviewWidget(
    BuildContext context,
    ReplyPreview reply,
    bool isMe,
    Color outgoingColor,
    Color incomingColor,
  ) {
    final barColor = const Color(0xFF2EB82E);
    final bgColor = Colors.black.withOpacity(0.12);

    return GestureDetector(
      onTap: () {
        if (onReplyClick != null) onReplyClick!(reply.messageId);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border(left: BorderSide(color: barColor, width: 3.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reply.senderName,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: barColor,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    reply.snippet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: (isMe ? outgoingColor : incomingColor).withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (reply.mediaUrl != null) ...[
              const SizedBox(width: 8.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.network(reply.mediaUrl!, width: 36.0, height: 36.0, fit: BoxFit.cover),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent(MessageMediaType type, String url) {
    return GestureDetector(
      onTap: () {
        if (onMediaClick != null) onMediaClick!(url);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: type == MessageMediaType.image
              ? Image.network(url, fit: BoxFit.cover, width: double.infinity, height: 180.0)
              : Container(
                  height: 60.0,
                  color: Colors.black26,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Icon(
                        type == MessageMediaType.video ? Icons.play_circle_fill : Icons.insert_drive_file,
                        color: Colors.white,
                        size: 32.0,
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          url.split('/').last,
                          style: const TextStyle(color: Colors.white, fontSize: 13.0),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDeliveryIcon(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.sending:
        return const Icon(Icons.access_time, size: 12.0, color: Color(0xFF9095A1));
      case DeliveryStatus.sent:
        return const Icon(Icons.check, size: 12.0, color: Color(0xFF9095A1));
      case DeliveryStatus.delivered:
        return const Icon(Icons.done_all, size: 12.0, color: Color(0xFF9095A1));
      case DeliveryStatus.read:
        return const Icon(Icons.done_all, size: 12.0, color: Color(0xFF2EB82E));
    }
  }

  Widget _buildReactionsBar(List<MessageReaction> reactions) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Wrap(
        spacing: 4.0,
        runSpacing: 4.0,
        children: reactions.map((r) {
          return GestureDetector(
            onTap: () {
              if (onReactionClick != null) onReactionClick!(r.emoji);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: r.isReactedByMe ? const Color(0xFF2EB82E).withOpacity(0.2) : const Color(0xFF23272F),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: r.isReactedByMe ? const Color(0xFF2EB82E) : Colors.transparent,
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(r.emoji, style: const TextStyle(fontSize: 12.0)),
                  const SizedBox(width: 4.0),
                  Text(
                    '${r.count}',
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                      color: r.isReactedByMe ? const Color(0xFF2EB82E) : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class RichMessageText extends StatefulWidget {
  final String text;
  final Color textColor;
  final bool isMe;
  final Function(String url)? onLinkClick;

  const RichMessageText({
    super.key,
    required this.text,
    required this.textColor,
    required this.isMe,
    this.onLinkClick,
  });

  @override
  State<RichMessageText> createState() => _RichMessageTextState();
}

class _RichMessageTextState extends State<RichMessageText> {
  final Set<int> _revealedSpoilers = {};

  @override
  Widget build(BuildContext context) {
    final List<InlineSpan> spans = [];
    final TextStyle baseStyle = TextStyle(color: widget.textColor, fontSize: 14.5, height: 1.35);

    final RegExp regex = RegExp(
      r'(\|\|.*?\|\|)|' // 1. Spoiler
      r'(\*\*.*?\*\*)|' // 2. Bold
      r'(_.*?_)|' // 3. Italic
      r'(~.*?~)|' // 4. Underline
      r'(~~.*?~~)|' // 5. Strikethrough
      r'(```[\s\S]*?```)|' // 6. Code Block
      r'(`.*?`)|' // 7. Inline Code
      r'(> .*)' // 8. Quote
      r'|(https?:\/\/[^\s]+)|' // 9. Link
      r'(@\w+)', // 10. Mention
      multiLine: true,
    );

    int lastMatchEnd = 0;
    int spoilerIndex = 0;

    for (final match in regex.allMatches(widget.text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: widget.text.substring(lastMatchEnd, match.start),
          style: baseStyle,
        ));
      }

      final String token = match.group(0)!;

      if (token.startsWith('||') && token.endsWith('||')) {
        final currentSpoilerId = spoilerIndex++;
        final isRevealed = _revealedSpoilers.contains(currentSpoilerId);
        final innerText = decodeSpoiler(token);

        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isRevealed) {
                    _revealedSpoilers.remove(currentSpoilerId);
                  } else {
                    _revealedSpoilers.add(currentSpoilerId);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                decoration: BoxDecoration(
                  color: isRevealed ? Colors.black12 : (widget.isMe ? Colors.black38 : Colors.black87),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  isRevealed ? innerText : '▇▇▇▇▇',
                  style: baseStyle.copyWith(
                    color: isRevealed ? widget.textColor : Colors.transparent,
                    letterSpacing: isRevealed ? 0 : 2.0,
                  ),
                ),
              ),
            ),
          ),
        );
      } else if (token.startsWith('**') && token.endsWith('**')) {
        spans.add(TextSpan(
          text: token.substring(2, token.length - 2),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ));
      } else if (token.startsWith('_') && token.endsWith('_')) {
        spans.add(TextSpan(
          text: token.substring(1, token.length - 1),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (token.startsWith('~') && token.endsWith('~') && !token.startsWith('~~')) {
        spans.add(TextSpan(
          text: token.substring(1, token.length - 1),
          style: baseStyle.copyWith(decoration: TextDecoration.underline),
        ));
      } else if (token.startsWith('~~') && token.endsWith('~~')) {
        spans.add(TextSpan(
          text: token.substring(2, token.length - 2),
          style: baseStyle.copyWith(decoration: TextDecoration.lineThrough),
        ));
      } else if (token.startsWith('```') && token.endsWith('```')) {
        spans.add(TextSpan(
          text: '\n${token.substring(3, token.length - 3).trim()}\n',
          style: TextStyle(
            fontFamily: 'monospace',
            backgroundColor: Colors.black.withOpacity(0.2),
            fontSize: 13.0,
            color: widget.textColor,
          ),
        ));
      } else if (token.startsWith('`') && token.endsWith('`')) {
        spans.add(TextSpan(
          text: token.substring(1, token.length - 1),
          style: TextStyle(
            fontFamily: 'monospace',
            backgroundColor: Colors.black.withOpacity(0.2),
            fontSize: 13.0,
            color: widget.textColor,
          ),
        ));
      } else if (token.startsWith('> ')) {
        spans.add(TextSpan(
          text: token.substring(2),
          style: baseStyle.copyWith(
            fontStyle: FontStyle.italic,
            color: widget.textColor.withOpacity(0.85),
          ),
        ));
      } else if (token.startsWith('http://') || token.startsWith('https://')) {
        spans.add(TextSpan(
          text: token,
          style: baseStyle.copyWith(
            color: const Color(0xFF2EB82E),
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (widget.onLinkClick != null) widget.onLinkClick!(token);
            },
        ));
      } else if (token.startsWith('@')) {
        spans.add(TextSpan(
          text: token,
          style: baseStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2EB82E),
          ),
        ));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < widget.text.length) {
      spans.add(TextSpan(
        text: widget.text.substring(lastMatchEnd),
        style: baseStyle,
      ));
    }

    return SelectableText.rich(TextSpan(children: spans));
  }
}