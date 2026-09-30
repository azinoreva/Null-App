// module name: server_management.dart

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../database/queries/servers_queries.dart';
import 'server_colour.dart';
import '../../network/servers/servers.dart'; // ServerDirectoryService, ServerInfo, ServerListResponse

/// SQLite has no list columns, so the API's string lists (`categories` and
/// the media block's `media_type`) are persisted as JSON text.
String? _encodeStringList(List<String>? values) =>
    values == null ? null : jsonEncode(values);

List<String>? _decodeStringList(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return null;
    return decoded.whereType<String>().toList();
  } catch (_) {
    return null;
  }
}

bool _stringListsEqual(List<String>? a, List<String>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Rebuilds the media block stored across a row's flattened media columns.
ServerMedia? _mediaFromRow(Server row) => ServerMedia.tryFromJson({
      'url': row.mediaUrl,
      'size': row.mediaSize,
      'timer': row.mediaTimer,
      'media_type': _decodeStringList(row.mediaType),
    });

/// Rebuilds the API's `Server` model from a stored row, so a value read back
/// out of the database is indistinguishable from one the directory returned.
ServerInfo serverInfoFromRow(Server row) => ServerInfo(
      serverId: row.serverId,
      serverName: row.serverName,
      serverUrl: row.serverUrl,
      serverType: ServerType.tryFromJson(row.serverType) ?? ServerType.public,
      maxPayload: row.maxPayload,
      colour: row.colour,
      about: row.about,
      categories: _decodeStringList(row.categories),
      annotated: row.annotated,
      disabled: row.disabled,
      location: row.location,
      media: _mediaFromRow(row),
    );

/// 1. Creates a new server row from a server returned by the directory.
///
/// Reads all existing servers' accent colours, picks a distinct new one via
/// pickDistinctColour, and inserts the server with it. Pass [accentColour] to
/// keep an already-picked accent across a delete/re-insert.
Future<void> createServer(
  ServersDao serversDao, {
  required ServerInfo server,
  int? accentColour,
}) async {
  final accent = accentColour ??
      pickDistinctColour(await serversDao.getAllDistinctColours());

  final companion = ServersCompanion.insert(
    serverId: server.serverId,
    serverName: server.serverName,
    serverUrl: server.serverUrl,
    serverType: Value(server.serverType.toJson()),
    maxPayload: Value(server.maxPayload),
    colour: Value(server.colour),
    about: Value(server.about),
    categories: Value(_encodeStringList(server.categories)),
    annotated: Value(server.annotated),
    disabled: Value(server.disabled),
    location: Value(server.location),
    mediaUrl: Value(server.media?.url),
    mediaSize: Value(server.media?.size),
    mediaTimer: Value(server.media?.timer),
    mediaType: Value(
      _encodeStringList(server.media?.mediaType.map((e) => e.toJson()).toList()),
    ),
    accentColour: Value(accent),
    mediaLastReset: DateTime.now(),
    totalMediaSent: const Value(0),
  );

  await serversDao.insertServer(companion);
}

/// 2. Updates any server field except serverId. Only fields you pass are
/// changed; everything else is left as-is.
///
/// Scalar columns take the new value directly (`null` means "leave alone").
/// The nullable ones - `categories`, `location` and the `media` block - take
/// a `Value`, so `Value(null)` explicitly clears them while an absent
/// `Value` leaves the column untouched.
Future<void> updateServerFields(
  ServersDao serversDao, {
  required String serverId,
  String? serverName,
  String? serverUrl,
  ServerType? serverType,
  int? maxPayload,
  String? colour,
  String? about,
  Value<List<String>?>? categories,
  bool? annotated,
  bool? disabled,
  Value<String?>? location,
  Value<ServerMedia?>? media,
  int? accentColour,
  int? totalMediaSent,
  DateTime? mediaLastReset,
}) async {
  final mediaValue = media?.value;

  final companion = ServersCompanion(
    serverName:
        serverName != null ? Value(serverName) : const Value.absent(),
    serverUrl: serverUrl != null ? Value(serverUrl) : const Value.absent(),
    serverType: serverType != null
        ? Value(serverType.toJson())
        : const Value.absent(),
    maxPayload:
        maxPayload != null ? Value(maxPayload) : const Value.absent(),
    colour: colour != null ? Value(colour) : const Value.absent(),
    about: about != null ? Value(about) : const Value.absent(),
    categories: categories != null
        ? Value(_encodeStringList(categories.value))
        : const Value.absent(),
    annotated: annotated != null ? Value(annotated) : const Value.absent(),
    disabled: disabled != null ? Value(disabled) : const Value.absent(),
    location: location != null ? Value(location.value) : const Value.absent(),
    mediaUrl:
        media != null ? Value(mediaValue?.url) : const Value.absent(),
    mediaSize:
        media != null ? Value(mediaValue?.size) : const Value.absent(),
    mediaTimer:
        media != null ? Value(mediaValue?.timer) : const Value.absent(),
    mediaType: media != null
        ? Value(_encodeStringList(
            mediaValue?.mediaType.map((e) => e.toJson()).toList(),
          ))
        : const Value.absent(),
    accentColour:
        accentColour != null ? Value(accentColour) : const Value.absent(),
    totalMediaSent: totalMediaSent != null
        ? Value(totalMediaSent)
        : const Value.absent(),
    mediaLastReset: mediaLastReset != null
        ? Value(mediaLastReset)
        : const Value.absent(),
  );

  await (serversDao.update(serversDao.db.servers)
        ..where((t) => t.serverId.equals(serverId)))
      .write(companion);
}

/// 3. Deletes a server by ID.
Future<int> deleteServerById(ServersDao serversDao, String serverId) {
  return serversDao.deleteServer(serverId);
}
/// 4. Refreshes local servers from the remote directory.
/// Fetches the server list and persists every returned server, including its
/// server URL. Existing rows are updated in place; new rows are inserted.
Future<void> refreshServers(
  ServersDao serversDao,
  ServerDirectoryService directoryService,
) async {
  final result = await directoryService.getServers();

  for (final remote in result.servers) {
    final local = await serversDao.getServerById(remote.serverId);

    if (local == null) {
      await createServer(serversDao, server: remote);
      continue;
    }

    // Only write fields that actually differ from what's stored.
    await updateServerFields(
      serversDao,
      serverId: remote.serverId,
      serverName: remote.serverName != local.serverName
          ? remote.serverName
          : null,
      serverUrl:
          remote.serverUrl != local.serverUrl ? remote.serverUrl : null,
      serverType: remote.serverType.name != local.serverType
          ? remote.serverType
          : null,
      maxPayload:
          remote.maxPayload != local.maxPayload ? remote.maxPayload : null,
      colour: remote.colour != local.colour ? remote.colour : null,
      about: remote.about != local.about ? remote.about : null,
      annotated:
          remote.annotated != local.annotated ? remote.annotated : null,
      disabled: remote.disabled != local.disabled ? remote.disabled : null,
      categories:
          _stringListsEqual(remote.categories, _decodeStringList(local.categories))
              ? null
              : Value(remote.categories),
      location:
          remote.location != local.location ? Value(remote.location) : null,
      media: remote.media == _mediaFromRow(local) ? null : Value(remote.media),
    );
  }
}
