import 'package:flutter/material.dart';
import 'chat_bubble_component.dart';

class ChatInput extends StatefulWidget {
  final List<SenderPresentation> groupMembers;
  final ReplyPreview? replyPreview;
  final VoidCallback? onCancelReply;
  final Function(String text, MessageMediaType mediaType, {String? mediaUrl}) onSendMessage;
  final VoidCallback? onAttachmentTap;
  final VoidCallback? onEmojiTap;
  final bool isDisabled;
  final String initialText;
  final ValueChanged<String>? onTextChanged;

  const ChatInput({
    super.key,
    this.groupMembers = const [],
    required this.onSendMessage,
    this.replyPreview,
    this.onCancelReply,
    this.onAttachmentTap,
    this.onEmojiTap,
    this.isDisabled = false,
    this.initialText = '',
    this.onTextChanged,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _showMentionDropdown = false;
  List<SenderPresentation> _filteredMembers = [];
  int _mentionStartIndex = -1;

  @override
  void initState() {
    super.initState();
    if (widget.initialText.isNotEmpty) {
      _controller.text = widget.initialText;
    }
    _controller.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only adopt an externally supplied draft while the user isn't actively
    // typing, so we never fight the cursor while they edit.
    if (widget.initialText != oldWidget.initialText && !_focusNode.hasFocus) {
      _controller.text = widget.initialText;
    }
  }

  void _handleTextChange() {
    final text = _controller.text;
    final selection = _controller.selection;

    widget.onTextChanged?.call(text);

    if (selection.baseOffset < 0) return;

    final textBeforeCursor = text.substring(0, selection.baseOffset);
    final lastAtPos = textBeforeCursor.lastIndexOf('@');

    if (lastAtPos != -1) {
      final query = textBeforeCursor.substring(lastAtPos + 1);
      if (!query.contains(' ')) {
        final matches = widget.groupMembers.where((m) {
          final name = m.displayName ?? '';
          return name.toLowerCase().contains(query.toLowerCase());
        }).toList();

        setState(() {
          _mentionStartIndex = lastAtPos;
          _filteredMembers = matches;
          _showMentionDropdown = matches.isNotEmpty;
        });
        return;
      }
    }

    if (_showMentionDropdown) {
      setState(() {
        _showMentionDropdown = false;
      });
    }
  }

  void _insertMention(SenderPresentation member) {
    final text = _controller.text;
    final name = (member.displayName ?? 'user').replaceAll(' ', '');

    final beforeAt = text.substring(0, _mentionStartIndex);
    final afterCursor = text.substring(_controller.selection.baseOffset);

    final updatedText = '$beforeAt@$name $afterCursor';
    _controller.text = updatedText;

    final newCursorPosition = _mentionStartIndex + name.length + 2;
    _controller.selection = TextSelection.collapsed(offset: newCursorPosition);

    setState(() {
      _showMentionDropdown = false;
    });
    _focusNode.requestFocus();
  }

  void _handleSend() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty || widget.isDisabled) return;

    widget.onSendMessage(trimmed, MessageMediaType.text);
    _controller.clear();
    setState(() {
      _showMentionDropdown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Exact Colors mapped directly from UI CSS specification
    const containerBg = Color(0xFF161A1D);
    const textboxBg = Color(0xFF181C20);
    const borderColor = Color(0xFF31383F);
    const iconColor = Color(0xFFBCC2C8);

    return Opacity(
      opacity: widget.isDisabled ? 0.4 : 1.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mention Dropdown List
          if (_showMentionDropdown)
            Container(
              constraints: const BoxConstraints(maxHeight: 180.0),
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: textboxBg,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8.0,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredMembers.length,
                itemBuilder: (context, index) {
                  final member = _filteredMembers[index];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 12.0,
                      backgroundColor: borderColor,
                      backgroundImage: (member.avatarUrl != null && member.avatarUrl!.isNotEmpty)
                          ? NetworkImage(member.avatarUrl!)
                          : null,
                      child: (member.avatarUrl == null || member.avatarUrl!.isEmpty)
                          ? Text(
                              member.displayName?[0] ?? 'U',
                              style: const TextStyle(fontSize: 10, color: Colors.white),
                            )
                          : null,
                    ),
                    title: Text(
                      member.displayName ?? 'Unknown',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.0),
                    ),
                    onTap: () => _insertMention(member),
                  );
                },
              ),
            ),

          // Reply Preview Banner
          if (widget.replyPreview != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: containerBg,
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 18.0, color: Color(0xFF2EB82E)),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Replying to ${widget.replyPreview!.senderName}',
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2EB82E),
                          ),
                        ),
                        Text(
                          widget.replyPreview!.snippet,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.0, color: iconColor),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18.0, color: iconColor),
                    onPressed: widget.onCancelReply,
                  ),
                ],
              ),
            ),

          // Container Bar (71px height from CSS spec)
          Container(
            constraints: const BoxConstraints(minHeight: 71.0),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
            decoration: const BoxDecoration(
              color: containerBg,
            ),
            child: SafeArea(
              top: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Attachment Button (.button CSS class)
                  SizedBox(
                    width: 40.0,
                    height: 40.0,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.attach_file_rounded,
                        color: Colors.white,
                        size: 22.0,
                      ),
                      onPressed: widget.isDisabled ? null : widget.onAttachmentTap,
                      splashRadius: 20.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),

                  // Textbox Input (.textbox CSS class)
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44.0),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: !widget.isDisabled,
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.0,
                          height: 22 / 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          hintStyle: const TextStyle(
                            color: iconColor,
                            fontSize: 14.0,
                          ),
                          filled: true,
                          fillColor: textboxBg,
                          contentPadding: const EdgeInsets.only(
                            left: 12.0,
                            right: 4.0,
                            top: 11.0,
                            bottom: 11.0,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0),
                            borderSide: const BorderSide(
                              color: borderColor,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0),
                            borderSide: const BorderSide(
                              color: borderColor,
                              width: 1.0,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0),
                            borderSide: const BorderSide(
                              color: borderColor,
                              width: 1.0,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.sentiment_satisfied_outlined,
                              color: iconColor,
                              size: 20.0,
                            ),
                            onPressed: widget.isDisabled ? null : widget.onEmojiTap,
                            splashRadius: 16.0,
                          ),
                        ),
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),

                  // Send Action Button
                  SizedBox(
                    width: 40.0,
                    height: 40.0,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.send_outlined,
                        color: iconColor,
                        size: 20.0,
                      ),
                      onPressed: widget.isDisabled ? null : _handleSend,
                      splashRadius: 20.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}