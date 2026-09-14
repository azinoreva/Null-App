// module name: message_types

/// Wire-level message type. The integer values are the on-the-wire and
/// database contract (they are stamped onto `Messages.message_type`) and
/// mirror the `MessageType` IntEnum in `app/models/messages.py` on the
/// server. Keep the values stable — v1 protocol, do not renumber.
enum MessageType {
  /// DH key-exchange / oknull-confirmation handshake (pre-session).
  exchange(0),

  /// A regular encrypted chat message (the classic "message" type 1).
  message(1),

  /// Media attachment (image / video / audio / file).
  media(2),

  /// Presence ping: "I am alive / check if I am reachable".
  ping(3),

  /// Presence pong: reply to a ping.
  pong(4),

  /// User joined a room / group.
  join(5),

  /// User left a room / group.
  leave(6),

  /// Conversation / room generic metadata.
  metadata(7),

  /// Error / failure report.
  error(8),

  /// Encryption key management (query / rotate / report).
  keys(9),

  /// Read receipt for one or more message ids.
  read(10),

  /// Delivery (received) receipt for one or more message ids.
  received(11),

  /// Poll definition.
  polls(12),

  /// A vote cast on a poll.
  poll_vote(13),

  /// Poll closed by an admin / owner.
  poll_close(14),

  /// Pin a message in the conversation.
  pin(15),

  /// Unpin a message from the conversation.
  unpin(16),

  /// A message's text content was edited.
  edit(17),

  /// A message was deleted.
  delete(18),

  /// Nested / side-channel reply to another message.
  thread_reply(19),

  /// Server-fetched link preview (title / image / site) for a shared URL.
  link_preview(20),

  /// Geolocation payload (lat / lon / accuracy / label).
  location(21),

  /// Shared vCard / contact card.
  contact_card(22),

  /// Scheduled / referenced sticker by pack + id.
  sticker(23),

  /// Typing indicator start.
  typing_start(24),

  /// Typing indicator stop.
  typing_stop(25),

  /// Add an emoji reaction to a message.
  reaction_add(26),

  /// Remove an emoji reaction from a message.
  reaction_remove(27),

  /// Room renamed.
  room_rename(28),

  /// Room avatar updated.
  room_avatar_update(29),

  /// Admin muted a user in this conversation.
  user_mute(30),

  /// Admin kicked a user.
  user_kick(31),

  /// Admin banned a user.
  user_ban(32),

  /// VoIP call invitation / start "Join Call" banner.
  call_start(33),

  /// VoIP call ended (with duration summary).
  call_end(34),

  /// WebRTC SDP / ICE signaling relay.
  webrtc_signal(35),

  /// Annotation / note attached to a message or conversation.
  annotation(36),

  /// Status update (the "updates" feed).
  updates(37);

  const MessageType(this.value);

  /// The integer value that goes on the wire and into the DB.
  final int value;

  /// Reverse lookup. Returns null for unknown values so new server types
  /// do not crash the receive dispatcher.
  static MessageType? fromValue(int value) {
    for (final type in MessageType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

/// How a message type is carried on the wire.
enum WireCarrier {
  /// Ratchet-encrypted, persisted in `Messages`, part of chat history.
  encrypted,

  /// Plaintext control envelope, ephemeral, never advances the ratchet
  /// and never lands in the `Messages` table (like handshake type 0).
  control,
}

/// Protocol attributes for each message type.
extension MessageTypeProtocol on MessageType {
  WireCarrier get carrier {
    switch (this) {
      case MessageType.message:
      case MessageType.media:
      case MessageType.edit:
      case MessageType.delete:
      case MessageType.thread_reply:
      case MessageType.link_preview:
      case MessageType.location:
      case MessageType.contact_card:
      case MessageType.sticker:
      case MessageType.polls:
      case MessageType.poll_vote:
      case MessageType.pin:
      case MessageType.unpin:
      case MessageType.reaction_add:
      case MessageType.reaction_remove:
      case MessageType.annotation:
      case MessageType.updates:
        return WireCarrier.encrypted;
      case MessageType.exchange:
      case MessageType.ping:
      case MessageType.pong:
      case MessageType.join:
      case MessageType.leave:
      case MessageType.metadata:
      case MessageType.error:
      case MessageType.keys:
      case MessageType.read:
      case MessageType.received:
      case MessageType.poll_close:
      case MessageType.typing_start:
      case MessageType.typing_stop:
      case MessageType.room_rename:
      case MessageType.room_avatar_update:
      case MessageType.user_mute:
      case MessageType.user_kick:
      case MessageType.user_ban:
      case MessageType.call_start:
      case MessageType.call_end:
      case MessageType.webrtc_signal:
        return WireCarrier.control;
    }
  }

  /// True when the type is delivered inside `NullCrypto.encryptMessage`
  /// ratchet ciphertext and is persisted to the `Messages` table.
  bool get isEncrypted => carrier == WireCarrier.encrypted;

  /// True when the type is an ephemeral plaintext control envelope.
  bool get isControl => carrier == WireCarrier.control;

  /// Canonical `kind` discriminator used inside plaintext control
  /// envelopes. Defaults to the Dart enum member name, which already
  /// matches the wire kind for every control type ('ping', 'pong'...).
  String get controlKind => name;
}