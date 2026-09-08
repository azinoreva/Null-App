import 'package:flutter/material.dart';
import '../widgets/display/contact_menu.dart';
import '../widgets/chats/chat_input_component.dart';
import '../widgets/chats/chat_bubble_component.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isContactMenuVisible = false;

  void _toggleContactMenu() {
    setState(() {
      _isContactMenuVisible = !_isContactMenuVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const senderAlex = SenderPresentation(
      userId: 'alex_rivera',
      displayName: 'Alex Rivera',
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Main Chat Interface Layout
          Column(
            children: [
              // Header / App Bar
              Container(
                color: theme.appBarTheme.backgroundColor ?? colorScheme.surface,
                padding: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top + 8,
                  bottom: 12,
                  left: 8,
                  right: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface, size: 20),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(width: 4),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            'AR',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: colorScheme.surface, width: 2),
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
                            senderAlex.displayName!,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Row(
                            children: [
                              Icon(Icons.circle, color: Colors.green, size: 6),
                              SizedBox(width: 4),
                              Text(
                                'ACTIVE NOW',
                                style: TextStyle(
                                  color: Colors.green,
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
                      icon: const Icon(Icons.notifications_none_rounded, color: Colors.green),
                      onPressed: () {},
                    ),
                    // Ellipsis button triggers ContactMenu modal overlay
                    IconButton(
                      icon: Icon(Icons.more_vert_rounded, color: colorScheme.onSurface),
                      onPressed: _toggleContactMenu,
                    ),
                  ],
                ),
              ),

              // Chat Messages Feed
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Today',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    ChatBubbleComponent(
                      message: ChatMessageItem(
                        id: 'msg_1',
                        isMe: false,
                        chatType: ChatType.individual,
                        sender: senderAlex,
                        content: 'Hey! Did you check out that new design resource I mentioned earlier? 🎨',
                        timestamp: '10:24 AM',
                      ),
                    ),

                    const ChatBubbleComponent(
                      message: ChatMessageItem(
                        id: 'msg_2',
                        isMe: true,
                        chatType: ChatType.individual,
                        content: "Not yet, but send me the link! I'm actually looking for some inspiration for the new project.",
                        timestamp: '10:26 AM',
                        deliveryStatus: DeliveryStatus.read,
                      ),
                    ),

                    ChatBubbleComponent(
                      message: ChatMessageItem(
                        id: 'msg_3',
                        isMe: false,
                        chatType: ChatType.individual,
                        sender: senderAlex,
                        content: 'Here it is! Their component library is absolutely stunning. Let me know what you think about the dark mode implementation.',
                        timestamp: '10:27 AM',
                      ),
                    ),

                    const ChatBubbleComponent(
                      message: ChatMessageItem(
                        id: 'msg_4',
                        isMe: true,
                        chatType: ChatType.individual,
                        content: 'Wow, this is exactly what we need. The typography hierarchy is spot on! Thanks for sharing this mate. 🙌',
                        timestamp: '10:30 AM',
                        deliveryStatus: DeliveryStatus.read,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text(
                        '•••  Alex is typing...',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Chat Input Component
              ChatInput(
                groupMembers: const [senderAlex],
                onSendMessage: (text, mediaType, {mediaUrl}) {},
              ),
            ],
          ),

          // Contact Menu Overlay Modal
          if (_isContactMenuVisible) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleContactMenu,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: Colors.black38,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 56,
              right: 16,
              child: ContactMenu(
                onPhoneTap: _toggleContactMenu,
                onVideoTap: _toggleContactMenu,
                onLocationTap: _toggleContactMenu,
                onMediaTap: _toggleContactMenu,
                onSearchTap: _toggleContactMenu,
              ),
            ),
          ],
        ],
      ),
    );
  }
}