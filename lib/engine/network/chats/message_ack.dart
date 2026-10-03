import 'dart:async';

import '../api_client.dart';
import 'delete_message.dart';

/// Batches acknowledgements for messages the app has persisted locally.
///
/// The server keeps a message in its queue until the recipient acks it, so an
/// ack is only correct once the message is safely in the local database. That
/// makes this the one place that can turn "we stored it" into "the server may
/// forget it".
///
/// Ids are buffered and flushed in batches because the server caps a single
/// `POST /api/messages/ack` at 100 ids, and because a burst of inbound
/// messages shouldn't turn into a burst of requests. A batch that fails is put
/// back and retried, so a message is never silently dropped.
class ReceivedMessageAcks {
  ReceivedMessageAcks._();

  static final ReceivedMessageAcks instance = ReceivedMessageAcks._();

  /// How long to collect ids before flushing.
  static const Duration _flushDelay = Duration(seconds: 2);

  /// Server-side cap on ids per request.
  static const int _maxIdsPerRequest = 100;

  /// Backoff ceiling for a failing flush.
  static const Duration _maxRetryDelay = Duration(minutes: 2);

  final Map<String, Set<String>> _pending = {};
  final Map<String, Timer> _timers = {};
  final Map<String, Duration> _retryDelays = {};

  /// Lets the transport drop its duplicate-suppression entry once the server
  /// has confirmed it, so the memory isn't held forever.
  void Function(String serverId, String messageId)? onAcked;

  bool _disposed = false;

  /// Records that [messageId] from [serverId] is now stored locally and may be
  /// released on the server.
  void record(String serverId, String messageId) {
    if (_disposed) return;

    final ids = _pending.putIfAbsent(serverId, () => <String>{});
    if (!ids.add(messageId)) return;

    // A flush already scheduled for this server will pick this up.
    if (_timers.containsKey(serverId)) return;

    _schedule(serverId, _flushDelay);
  }

  /// Number of ids waiting to be flushed for [serverId]; exposed for tests and
  /// diagnostics.
  int pendingCount(String serverId) => _pending[serverId]?.length ?? 0;

  /// Flushes immediately instead of waiting out the batch window.
  Future<void> flush(String serverId) => _flush(serverId);

  void _schedule(String serverId, Duration delay) {
    _timers[serverId]?.cancel();
    _timers[serverId] = Timer(delay, () {
      _timers.remove(serverId);
      unawaited(_flush(serverId));
    });
  }

  Future<void> _flush(String serverId) async {
    if (_disposed) return;

    final ids = _pending[serverId];
    if (ids == null || ids.isEmpty) return;

    // Nothing to talk to yet (server still being registered, or logged out).
    // Keep the ids and try again on the backoff rather than dropping them.
    if (!ApiClient.isRegistered(serverId)) {
      _schedule(serverId, _retryDelay(serverId));
      return;
    }

    final batch = ids.take(_maxIdsPerRequest).toList();
    try {
      await MessagesService(serverId: serverId).ackMessages(messageIds: batch);
    } catch (_) {
      // Left in `_pending` so the next flush retries them.
      _schedule(serverId, _retryDelay(serverId));
      return;
    }

    // Only drop the ids that actually went through.
    ids.removeAll(batch);
    for (final messageId in batch) {
      onAcked?.call(serverId, messageId);
    }
    _retryDelays.remove(serverId);

    if (ids.isNotEmpty) {
      // More than one batch worth arrived; drain the rest right away.
      unawaited(_flush(serverId));
    }
  }

  Duration _retryDelay(String serverId) {
    final next = _retryDelays[serverId] ?? const Duration(seconds: 5);
    final doubled = Duration(seconds: next.inSeconds * 2);
    return doubled > _maxRetryDelay ? _maxRetryDelay : doubled;
  }

  /// Forgets everything pending for [serverId], e.g. when it is removed from
  /// the server list. Any unacked messages will be replayed on reconnect.
  void forgetServer(String serverId) {
    _timers[serverId]?.cancel();
    _timers.remove(serverId);
    _pending.remove(serverId);
    _retryDelays.remove(serverId);
  }

  void dispose() {
    _disposed = true;
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _pending.clear();
    _retryDelays.clear();
  }
}
