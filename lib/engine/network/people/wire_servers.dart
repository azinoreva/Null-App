// module name: wire_servers
//
// One place to read a "list of server ids" out of a JSON payload, shared by
// every model the wire carries servers on (contact inbox, dh-drop inbox,
// fetched contact card, identity card).
//
// The wire (Null-service `ServerClass`) ships servers as a list of objects:
//   "servers": [{"server_id": "K4m_lsBLJIkT"}]
// Older/simpler payloads may ship a bare list of id strings. Both shapes are
// accepted here.

/// Returns the server ids in [json] — the `servers` list the wire carries.
/// A missing or non-list value becomes an empty list.
List<String> readServersFromJson(Map<String, dynamic> json) {
  final raw = json['servers'];
  if (raw is! List) return const <String>[];

  final ids = <String>[];
  for (final entry in raw) {
    if (entry is String) {
      if (entry.isNotEmpty) ids.add(entry);
    } else if (entry is Map) {
      final id = entry['server_id'];
      if (id is String && id.isNotEmpty) ids.add(id);
    }
  }
  return List<String>.unmodifiable(ids);
}

/// Encodes [ids] the way the wire expects: a list of `{"server_id": id}`
/// objects (Null-service `ServerClass`). Empty ids are dropped.
List<Map<String, String>> writeServersToJson(Iterable<String> ids) => ids
    .where((id) => id.isNotEmpty)
    .map((id) => <String, String>{'server_id': id})
    .toList(growable: false);
