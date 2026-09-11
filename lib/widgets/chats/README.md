# `lib/widgets/chats` — Chat UI Components

| File | Purpose |
|---|---|
| `chat_bubble_component.dart` | The core chat display module. Defines the **data models** consumed across the app — `ChatType`, `DeliveryStatus` (sending/sent/delivered/read), `MessageMediaType` (text/image/video/file), `SenderPresentation`, `ReplyPreview`, `MessageReaction`, and `ChatMessageItem` (the canonical message item built by the Riverpod `chatMessagesProvider`). `ChatBubbleComponent` renders outgoing/incoming bubbles (dark/light aware), sender avatar/name for group chats, reply-preview blocks, media placeholders, footer with delivery-status icons, a reactions bar, and double-tap-to-reply. `RichMessageText` renders markdown-ish text: `||spoiler||` (tap to reveal), `**bold**`, `_italic_`, `~underline~`, `~~strikethrough~~`, code blocks/`inline code`, `> quotes`, tappable `http(s)://` links, and `@mention`. |
| `chat_input_component.dart` | `ChatInput` — the composer bar: attachment button, rounded multiline text field (1–4 lines), emoji button, send button (icon or keyboard submit). Supports an **@mention dropdown** for groups (filters `groupMembers`, inserts `@Name` at the cursor), an optional reply-preview banner with cancel, draft restoration via `initialText`, and callbacks (`onSendMessage`, `onAttachmentTap`, `onEmojiTap`, `onTextChanged`). Used in `Chatting` (currently with an empty group-members list and a stub `onSendMessage`). |

`ChatMessageItem` and friends are produced by `lib/state/providers.dart`
(chatMessagesProvider) and rendered by `lib/screens/chatting.dart`.