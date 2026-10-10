import 'dart:convert';

import 'package:drift/drift.dart';

/// Maps a JSON list of server ids to/from the text stored in a `servers`
/// column (used by both `contacts.servers` and `conversations.servers`).
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
