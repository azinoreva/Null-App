import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'pick_contact.dart';

class PendingContactsCacheService {
  PendingContactsCacheService._();

  static final PendingContactsCacheService instance =
      PendingContactsCacheService._();

  static const String boxName = 'pending_contacts';

  Box<String>? _box;

  Future<void> init() async {
    _box ??= await Hive.openBox<String>(boxName);
  }

  Box<String> get _requireBox {
    final box = _box;
    if (box == null || !box.isOpen) {
      throw StateError(
        'PendingContactsCacheService.init() must be called before use.',
      );
    }
    return box;
  }

  List<ReceivedContact> load() {
    final contacts = <ReceivedContact>[];
    for (final raw in _requireBox.values) {
      try {
        contacts.add(
          ReceivedContact.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw) as Map),
          ),
        );
      } catch (_) {
        // Remove malformed entries so they cannot block future loads.
      }
    }
    return contacts;
  }

  Future<void> save(Iterable<ReceivedContact> contacts) async {
    final entries = <String, String>{};
    for (final contact in contacts) {
      entries[contact.contactId] = jsonEncode(contact.toJson());
    }
    if (entries.isNotEmpty) await _requireBox.putAll(entries);
  }

  Future<void> remove(String contactId) => _requireBox.delete(contactId);
}
