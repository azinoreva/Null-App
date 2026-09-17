import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'check_updates.dart';

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
  }

  /// Closes the cache box (mainly for tests / teardown).
  Future<void> close() async {
    await _box?.close();
    _box = null;
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
  /// refreshes its saved-at timestamp.
  Future<void> save(Iterable<Update> updates) async {
    if (updates.isEmpty) return;
    final box = _requireBox;
    final now = DateTime.now().millisecondsSinceEpoch;
    final entries = <String, String>{};
    for (final update in updates) {
      entries[update.updateId] = jsonEncode({
        _savedAtKey: now,
        _updateKey: update.toJson(),
      });
    }
    await box.putAll(entries);
  }

  /// All cached updates, most recently saved first.
  List<Update> load() {
    final box = _requireBox;
    final cached = <(int, Update)>[];
    for (final raw in box.values) {
      final parsed = _decode(raw);
      if (parsed != null) cached.add(parsed);
    }
    cached.sort((a, b) => b.$1.compareTo(a.$1));
    return cached.map((entry) => entry.$2).toList(growable: false);
  }

  /// Deletes every cached update older than [ttl] (and any malformed entries).
  Future<void> purgeExpired() async {
    final box = _box;
    if (box == null || !box.isOpen) return;

    final cutoff = DateTime.now().subtract(ttl).millisecondsSinceEpoch;
    final stale = <dynamic>[];
    for (final key in box.keys) {
      final parsed = _decode(box.get(key));
      if (parsed == null || parsed.$1 < cutoff) stale.add(key);
    }
    if (stale.isNotEmpty) await box.deleteAll(stale);
  }

  /// Removes everything from the cache.
  Future<void> clear() async {
    await _requireBox.clear();
  }

  /// Returns `(savedAtMillis, Update)`, or `null` for malformed entries.
  (int, Update)? _decode(String? raw) {
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt = map[_savedAtKey];
      final updateJson = map[_updateKey];
      if (savedAt is! int || updateJson is! Map) return null;
      return (savedAt, Update.fromJson(Map<String, dynamic>.from(updateJson)));
    } catch (_) {
      return null;
    }
  }
}
