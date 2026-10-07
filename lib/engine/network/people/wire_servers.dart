// module name: wire_servers
//
// One place to read a "list of server ids" out of a JSON payload, shared by
// every model the wire carries servers on (contact inbox, dh-drop inbox,
// fetched contact card, identity card).

/// Returns the server ids in [json] — the `servers` list the wire carries.
/// A missing or non-list value becomes an empty list.
List<String> readServersFromJson(Map<String, dynamic> json) {
  final raw = json['servers'];
  if (raw is! List) return const <String>[];
  return raw.whereType<String>().toList(growable: false);
}
