import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'check_updates.dart';
import 'comments.dart';

/// Local, on-device cache for the updates feed.
///
/// Every update fetched from the server is written into a Hive box so the
/// feed renders instantly (and offline) on the next app launch. Entries are
/// pruned once they are older than [ttl] (7 days by default), matching the
/// server's `UPDATE_EXPIRATION` so the cache never outlives the source data.
///
/// Values are stored as JSON strings, so no Hive adapters / code generation
/// are required.
class UpdatesCacheService {
  UpdatesCacheService._();

  static final UpdatesCacheService instance = UpdatesCacheService._();

  static const String boxName = 'updates_cache';
  static const String _savedAtKey = '_saved_at';
  static const String _updateKey = 'update';
  static const String _commentsKey = 'comments';
  static const String _orderKey = 'order';
  static const String _offsetPrefix = '_offset:';
  static const String _hasMorePrefix = '_has_more:';
  static const String _reactionPrefix = '_reaction:';
  static const String _orderSeqKey = '_order_seq';
  static const String _seenPrefix = '_seen:';
  static const String _seenAtKey = 'seen_at';

  /// Stable, order-of-arrival sequence assigned to an update the first time it
  /// is cached. The feed sorts by it (highest = newest), so pagination and
  /// re-saves never reshuffle what the user has already scrolled through.
  int _seq = 0;
  bool _seqLoaded = false;

  /// How long a cached update survives before it is deleted.
  static const Duration ttl = Duration(days: 7);

  Box<String>? _box;
  bool _hiveInitialized = false;

  bool get isOpen => _box?.isOpen ?? false;

  /// Initializes Hive, opens the cache box and immediately prunes anything
  /// past [ttl]. Safe to call more than once. Call during app startup.
  Future<void> init() async {
    if (!_hiveInitialized) {
      await Hive.initFlutter();
      _hiveInitialized = true;
    }
    _box ??= await Hive.openBox<String>(boxName);
    await purgeExpired();
    await _backfillOrders(_box!);
  }

  /// Closes the cache box (mainly for tests / teardown).
  Future<void> close() async {
    await _box?.close();
    _box = null;
    _seqLoaded = false;
    _seq = 0;
  }

  Box<String> get _requireBox {
    final box = _box;
    if (box == null || !box.isOpen) {
      throw StateError(
        'UpdatesCacheService.init() must be called before using the cache.',
      );
    }
    return box;
  }

  /// Writes [updates] to the cache, keyed by update id. Re-saving an update
  /// refreshes its saved-at timestamp but keeps the order it was first assigned.
  ///
  /// Returns the feed order for every update written (highest = newest), so the
  /// caller can build the visible feed in a stable, sequential order.
  Future<Map<String, int>> save(Iterable<Update> updates) async {
    if (updates.isEmpty) return const {};
    final box = _requireBox;
    _ensureSeqLoaded(box);
    final now = DateTime.now().millisecondsSinceEpoch;
    final entries = <String, String>{};
    final orders = <String, int>{};
    var assignedNewOrder = false;
    for (final update in updates) {
      final existing = _readEnvelope(box.get(update.updateId));
      final existingOrder = existing?[_orderKey];
      final int order;
      if (existingOrder is int && existingOrder > 0) {
        order = existingOrder;
      } else {
        order = _nextSeq();
        assignedNewOrder = true;
      }
      orders[update.updateId] = order;
      entries[update.updateId] = jsonEncode({
        _savedAtKey: now,
        _orderKey: order,
        _updateKey: update.toJson(),
        if (existing?[_commentsKey] is List)
          _commentsKey: existing![_commentsKey],
      });
    }
    await box.putAll(entries);
    if (assignedNewOrder) await box.put(_orderSeqKey, '$_seq');
    return orders;
  }

  /// Stores comments in the same Hive entry as their post, under its update ID.
  Future<void> saveComments(String updateId, List<Comment> comments) async {
    final box = _requireBox;
    final envelope = _readEnvelope(box.get(updateId));
    if (envelope == null) return;
    envelope[_commentsKey] = comments.map((comment) => comment.toJson()).toList();
    await box.put(updateId, jsonEncode(envelope));
  }

  /// Returns null when comments have not been cached; an empty list means the
  /// post was checked and currently has no comments.
  List<Comment>? loadComments(String updateId) {
    final envelope = _readEnvelope(_requireBox.get(updateId));
    final rawComments = envelope?[_commentsKey];
    if (rawComments is! List) return null;
    try {
      return rawComments
          .whereType<Map>()
          .map((comment) => Comment.fromJson(Map<String, dynamic>.from(comment)))
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  /// Persists the user's reaction locally, keyed by its source server and
  /// update id. Reaction state is restored from Hive without a server read.
  Future<void> saveReaction({
    required String serverId,
    required String updateId,
    required bool liked,
    required bool disliked,
  }) async {
    final key = _reactionKey(serverId, updateId);
    await _requireBox.put(
      key,
      jsonEncode({'liked': liked, 'disliked': disliked}),
    );
  }

  CachedUpdateReaction loadReaction({
    required String serverId,
    required String updateId,
  }) {
    final raw = _requireBox.get(_reactionKey(serverId, updateId));
    if (raw == null) return const CachedUpdateReaction();
    try {
      final value = jsonDecode(raw) as Map<String, dynamic>;
      return CachedUpdateReaction(
        liked: value['liked'] == true,
        disliked: value['disliked'] == true,
      );
    } catch (_) {
      return const CachedUpdateReaction();
    }
  }

  String _reactionKey(String serverId, String updateId) =>
      _reactionPrefix +
      base64Url.encode(utf8.encode('$serverId\u0000$updateId'));

  /// The Hive key used to record that an update has been seen.
  ///
  /// Public so the feed notifier can build the same key when deciding whether
  /// an update was already seen in a previous session.
  static String seenKeyFor(String serverId, String updateId) =>
      _seenPrefix +
      base64Url.encode(utf8.encode('$serverId\u0000$updateId'));

  /// Records [items] as seen, keyed by server + update id. Seen state is a
  /// property of the update itself, so it survives category-filter changes.
  Future<void> markSeenBatch(
    Iterable<({String serverId, String updateId, int order})> items,
  ) async {
    final box = _requireBox;
    final now = DateTime.now().millisecondsSinceEpoch;
    final entries = <String, String>{};
    for (final item in items) {
      if (item.serverId.isEmpty || item.updateId.isEmpty) continue;
      entries[seenKeyFor(item.serverId, item.updateId)] = jsonEncode({
        _orderKey: item.order,
        _seenAtKey: now,
      });
    }
    if (entries.isEmpty) return;
    await box.putAll(entries);
  }

  /// Every update id currently recorded as seen, as a ready-to-compare set of
  /// the same keys [seenKeyFor] produces.
  Set<String> loadSeenKeys() {
    final box = _requireBox;
    final keys = <String>{};
    for (final key in box.keys) {
      if (key is String && key.startsWith(_seenPrefix)) keys.add(key);
    }
    return keys;
  }

  int? _readSeenAt(String? raw) {
    final envelope = _readEnvelope(raw);
    final seenAt = envelope?[_seenAtKey];
    return seenAt is int ? seenAt : null;
  }

  int _nextSeq() => ++_seq;

  void _ensureSeqLoaded(Box<String> box) {
    if (_seqLoaded) return;
    _seq = int.tryParse(box.get(_orderSeqKey) ?? '') ?? 0;
    _seqLoaded = true;
  }

  /// Assigns a stable order to cached updates written before ordering existed,
  /// preserving their current on-device (saved-at) order.
  Future<void> _backfillOrders(Box<String> box) async {
    final pending = <(String, int, Map<String, dynamic>)>[];
    for (final key in box.keys) {
      if (key is! String || _isMetadataKey(key)) continue;
      final envelope = _readEnvelope(box.get(key));
      if (envelope == null) continue;
      final existingOrder = envelope[_orderKey];
      if (existingOrder is int && existingOrder > 0) continue;
      final savedAt = envelope[_savedAtKey];
      if (savedAt is! int) continue;
      pending.add((key, savedAt, envelope));
    }
    if (pending.isEmpty) return;
    pending.sort((a, b) => a.$2.compareTo(b.$2));
    _ensureSeqLoaded(box);
    final entries = <String, String>{};
    for (final (key, _, envelope) in pending) {
      envelope[_orderKey] = _nextSeq();
      entries[key] = jsonEncode(envelope);
    }
    await box.putAll(entries);
    await box.put(_orderSeqKey, '$_seq');
  }

  bool _isMetadataKey(String key) =>
      key == _orderSeqKey ||
      key.startsWith(_offsetPrefix) ||
      key.startsWith(_hasMorePrefix) ||
      key.startsWith(_reactionPrefix) ||
      key.startsWith(_seenPrefix);

  /// Returns the last pagination offset saved for each server.
  Map<String, int> loadOffsets() => _loadIntMetadata(_offsetPrefix);

  /// Returns whether each server may still have another page.
  Map<String, bool> loadHasMore() => _loadBoolMetadata(_hasMorePrefix);

  /// Persists pagination progress independently for each server.
  Future<void> savePageState(
    String serverId, {
    required int offset,
    required bool hasMore,
  }) async {
    final box = _requireBox;
    await box.put(_offsetPrefix + serverId, '$offset');
    await box.put(_hasMorePrefix + serverId, hasMore ? '1' : '0');
  }

  /// Clears cursors before a new feed refresh starts.
  Future<void> clearPageState() async {
    final box = _requireBox;
    final keys = box.keys.where((key) {
      return key is String &&
          (key.startsWith(_offsetPrefix) || key.startsWith(_hasMorePrefix));
    }).toList();
    if (keys.isNotEmpty) await box.deleteAll(keys);
  }

  /// All cached updates, most recently added first (by feed order).
  List<CachedUpdate> load() {
    final box = _requireBox;
    final cached = <CachedUpdate>[];
    for (final raw in box.values) {
      final parsed = _decode(raw);
      if (parsed != null) cached.add(parsed);
    }
    cached.sort((a, b) => b.order.compareTo(a.order));
    return cached;
  }

  /// Deletes every cached update (and seen record) older than [ttl], plus any
  /// malformed entries. This is the feed's scheduled deleter: it runs on every
  /// start-up and feed refresh, so seen history never outlives the server's own
  /// `UPDATE_EXPIRATION` window.
  Future<void> purgeExpired() async {
    final box = _box;
    if (box == null || !box.isOpen) return;

    final cutoff = DateTime.now().subtract(ttl).millisecondsSinceEpoch;
    final stale = <dynamic>[];
    for (final key in box.keys) {
      if (key is! String) {
        stale.add(key);
        continue;
      }
      if (key == _orderSeqKey ||
          key.startsWith(_offsetPrefix) ||
          key.startsWith(_hasMorePrefix) ||
          key.startsWith(_reactionPrefix)) {
        continue;
      }
      if (key.startsWith(_seenPrefix)) {
        final seenAt = _readSeenAt(box.get(key));
        if (seenAt == null || seenAt < cutoff) stale.add(key);
        continue;
      }
      final parsed = _decode(box.get(key));
      if (parsed == null || parsed.savedAt < cutoff) stale.add(key);
    }
    if (stale.isNotEmpty) await box.deleteAll(stale);
  }

  /// Removes everything from the cache.
  Future<void> clear() async {
    await _requireBox.clear();
  }

  Map<String, int> _loadIntMetadata(String prefix) {
    final box = _requireBox;
    final values = <String, int>{};
    for (final key in box.keys) {
      if (key is! String || !key.startsWith(prefix)) continue;
      final value = int.tryParse(box.get(key) ?? '');
      if (value != null) values[key.substring(prefix.length)] = value;
    }
    return values;
  }

  Map<String, bool> _loadBoolMetadata(String prefix) {
    final box = _requireBox;
    final values = <String, bool>{};
    for (final key in box.keys) {
      if (key is! String || !key.startsWith(prefix)) continue;
      final value = box.get(key);
      if (value == '0' || value == '1') {
        values[key.substring(prefix.length)] = value == '1';
      }
    }
    return values;
  }

  /// Returns the cached update plus its saved-at / feed-order metadata, or
  /// `null` for malformed entries.
  CachedUpdate? _decode(String? raw) {
    try {
      final map = _readEnvelope(raw);
      if (map == null) return null;
      final savedAt = map[_savedAtKey];
      final updateJson = map[_updateKey];
      if (savedAt is! int || updateJson is! Map) return null;
      final order = map[_orderKey];
      return CachedUpdate(
        update: Update.fromJson(Map<String, dynamic>.from(updateJson)),
        order: order is int ? order : savedAt,
        savedAt: savedAt,
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _readEnvelope(String? raw) {
    if (raw == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }
}

class CachedUpdateReaction {
  final bool liked;
  final bool disliked;

  const CachedUpdateReaction({this.liked = false, this.disliked = false});
}

/// A cached [Update] together with the metadata the feed needs: its stable
/// [order] (highest = newest) and when it was last written ([savedAt]).
class CachedUpdate {
  final Update update;
  final int order;
  final int savedAt;

  const CachedUpdate({
    required this.update,
    required this.order,
    this.savedAt = 0,
  });
}
