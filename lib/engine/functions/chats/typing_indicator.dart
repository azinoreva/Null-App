// module name: typing_indicator
//
// MessageType.typing_start (24) / MessageType.typing_stop (25) — ephemeral
// "peer is typing" hints. Control carrier: plaintext, never persisted, never
// advances the ratchet.
//
// Typing state is intentionally in-memory only: it is transient UI feedback,
// not history. [TypingIndicators] is a process-wide singleton updated by the
// receive handler and watched by the chat screen. The receive task and the UI
// both live on the main isolate, so a plain in-memory stream is enough.

import 'dart:async';

/// How long a typing hint stays live without a refresh. Typing indicators are
/// fire-and-forget, so a lost "stop" must eventually clear itself.
const Duration kTypingTimeout = Duration(seconds: 5);

/// Process-wide set of conversations whose peer is currently typing.
class TypingIndicators {
  TypingIndicators._();

  static final TypingIndicators instance = TypingIndicators._();

  final StreamController<Set<String>> _controller =
      StreamController<Set<String>>.broadcast();
  final Set<String> _active = <String>{};
  final Map<String, Timer> _timers = <String, Timer>{};

  /// Emits the current set of typing conversation ids on every change.
  Stream<Set<String>> get stream => _controller.stream;

  /// Snapshot of the conversations currently marked typing.
  Set<String> get active => Set.unmodifiable(_active);

  bool isTyping(String conversationId) => _active.contains(conversationId);

  /// Marks [conversationId] as typing and (re)arms the auto-expiry timer.
  void start(String conversationId) {
    _active.add(conversationId);
    _timers[conversationId]?.cancel();
    _timers[conversationId] = Timer(kTypingTimeout, () => stop(conversationId));
    _emit();
  }

  /// Clears the typing flag for [conversationId].
  void stop(String conversationId) {
    _timers.remove(conversationId)?.cancel();
    if (_active.remove(conversationId)) _emit();
  }

  void _emit() {
    if (!_controller.isClosed) _controller.add(active);
  }
}

/// Applies a received typing hint (24 = start, 25 = stop).
IncomingTypingResult handleTyping({
  required bool start,
  required String conversationId,
}) {
  if (start) {
    TypingIndicators.instance.start(conversationId);
  } else {
    TypingIndicators.instance.stop(conversationId);
  }
  return IncomingTypingResult(conversationId: conversationId, typing: start);
}

/// What [handleTyping] applied.
class IncomingTypingResult {
  const IncomingTypingResult({
    required this.conversationId,
    required this.typing,
  });

  final String conversationId;
  final bool typing;
}
