// module name: handshake_registry

import 'dart:async';

/// Tracks in-flight handshake confirmations for the CURRENT process only.
/// Key material lives in the Sessions table (see SessionsDao) — this
/// class only coordinates "is someone waiting for a live reply right
/// now," which is inherently process-local and doesn't need persistence.
class HandshakeRegistry {
  HandshakeRegistry._();
  static final HandshakeRegistry instance = HandshakeRegistry._();

  final Map<String, Completer<void>> _dhCompleters = {};
  final Map<String, Completer<void>> _confirmCompleters = {};

  Completer<void> registerDhWait(String conversationId) {
    final c = Completer<void>();
    _dhCompleters[conversationId] = c;
    return c;
  }

  void confirmDhReceived(String conversationId) {
    final c = _dhCompleters[conversationId];
    if (c != null && !c.isCompleted) c.complete();
  }

  Completer<void> registerConfirmWait(String conversationId) {
    final c = Completer<void>();
    _confirmCompleters[conversationId] = c;
    return c;
  }

  void confirmOknullReceived(String conversationId) {
    final c = _confirmCompleters[conversationId];
    if (c != null && !c.isCompleted) c.complete();
  }

  void clear(String conversationId) {
    _dhCompleters.remove(conversationId);
    _confirmCompleters.remove(conversationId);
  }
}