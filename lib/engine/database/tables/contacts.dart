import 'dart:convert';

import 'package:drift/drift.dart';

import 'conversations.dart'; // for foreign key reference

/// Maps a contact's server list to the JSON text stored in
/// `contacts.servers`.
///
/// Rows written before multi-server support held a bare server id, so
/// [fromSql] falls back to wrapping an unparsable value as a single-element
/// list instead of failing to read the row.
class ServersConverter extends TypeConverter<List<String>, String>
    with JsonTypeConverter2<List<String>, String, Object?> {
  const ServersConverter();

  @override
  String toSql(List<String> value) => jsonEncode(value);

  @override
  List<String> fromSql(String fromDb) => _decode(fromDb);

  @override
  Object? toJson(List<String> value) => value;

  @override
  List<String> fromJson(Object? json) {
    if (json is List) return json.map((e) => e.toString()).toList();
    if (json is String) return _decode(json);
    return <String>[];
  }

  static List<String> _decode(String raw) {
    if (raw.isEmpty) return <String>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.map((e) => e.toString()).toList();
      if (decoded is String) {
        return decoded.isEmpty ? <String>[] : [decoded];
      }
    } on FormatException {
      // Legacy value: a bare server id written before the list migration.
    }
    return [raw];
  }
}

/// Drift table definition for the `Contacts` table.
///
/// Stores the user's contacts and their relationship/notification settings.
/// Each contact can be linked to a one-on-one conversation.
class Contacts extends Table {
  TextColumn get contactId => text()();
  TextColumn get nickname => text().nullable()();
  BlobColumn get avatar => blob().nullable()(); // Changed to BLOB
  TextColumn get bio => text().nullable()();
  TextColumn get publicKey => text().nullable()();

  IntColumn get muted =>
      integer().withDefault(const Constant(0)).check(muted.isIn([0, 1]))();
  IntColumn get pinned =>
      integer().withDefault(const Constant(0)).check(pinned.isIn([0, 1]))();
  IntColumn get isOnline =>
      integer().withDefault(const Constant(0)).check(isOnline.isIn([0, 1]))();

  // Unix epoch milliseconds (nullable).
  IntColumn get lastSeen => integer().nullable()();

  IntColumn get connectionStatus => integer()();

  /// The servers this contact is on (a user has at most 8), stored as JSON
  /// text. Replaces the single `server_id` column; rows written before the
  /// change are read back as a one-element list by [ServersConverter].
  TextColumn get servers => text().map(const ServersConverter())();

  // Unix epoch milliseconds.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  IntColumn get ignorePing =>
      integer().withDefault(const Constant(0)).check(ignorePing.isIn([0, 1]))();

  // Foreign key linking to a conversation (one-on-one chat).
  TextColumn get conversationId => text().nullable().references(
    Conversations,
    #conversationId,
    onDelete: KeyAction.setNull,
  )();

  @override
  Set<Column> get primaryKey => {contactId};
}
