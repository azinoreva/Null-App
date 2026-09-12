// module name: server_management.dart

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../database/queries/servers_queries.dart';
import 'server_colour.dart';
import '../../network/servers/servers.dart'; // ServerDirectoryService, ServerInfo, ServerListResponse

/// 1. Creates a new server row.
/// Reads all existing servers' colours, picks a distinct new colour via
/// pickDistinctColour, and inserts the new server with it.
Future<void> createServer(
  ServersDao serversDao, {
  required String serverId,
  required String serverName,
  required String serverUrl,
  required String mediaUrl,
  required int mediaSizeLimit,
  required int mediaTimer,
  required int maxPayload,
  required int capabilities,
}) async {
  final usedColours = await serversDao.getAllDistinctColours();
  final colour = pickDistinctColour(usedColours);

  final companion = ServersCompanion.insert(
    serverId: serverId,
    serverName: serverName,
    serverUrl: serverUrl,
    mediaUrl: mediaUrl,
    mediaSizeLimit: Value(mediaSizeLimit),
    mediaTimer: Value(mediaTimer),
    maxPayload: Value(maxPayload),
    capabilities: Value(capabilities),
    colour: Value(colour),
    mediaLastReset: DateTime.now(),
    totalMediaSent: const Value(0),
  );

  await serversDao.insertServer(companion);
}

/// 2. Updates any server field except serverId. Only fields you pass are
/// changed; everything else is left as-is.
Future<void> updateServerFields(
  ServersDao serversDao, {
  required String serverId,
  String? serverName,
  String? serverUrl,
  String? mediaUrl,
  int? mediaSizeLimit,
  int? mediaTimer,
  int? maxPayload,
  int? capabilities,
  int? colour,
  int? totalMediaSent,
  DateTime? mediaLastReset,
}) async {
  final companion = ServersCompanion(
    serverName:
        serverName != null ? Value(serverName) : const Value.absent(),
    serverUrl: serverUrl != null ? Value(serverUrl) : const Value.absent(),
    mediaUrl: mediaUrl != null ? Value(mediaUrl) : const Value.absent(),
    mediaSizeLimit: mediaSizeLimit != null
        ? Value(mediaSizeLimit)
        : const Value.absent(),
    mediaTimer:
        mediaTimer != null ? Value(mediaTimer) : const Value.absent(),
    maxPayload:
        maxPayload != null ? Value(maxPayload) : const Value.absent(),
    capabilities:
        capabilities != null ? Value(capabilities) : const Value.absent(),
    colour: colour != null ? Value(colour) : const Value.absent(),
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
/// Fetches the server list, then for each returned server that already
/// exists locally, updates only the fields that changed. Servers the
/// remote directory returns but that aren't already in the local DB are
/// ignored entirely — this function never creates new rows.
Future<void> refreshServers(
  ServersDao serversDao,
  ServerDirectoryService directoryService,
) async {
  final result = await directoryService.getServers();

  for (final remote in result.servers) {
    final local = await serversDao.getServerById(remote.serverId);

    if (local == null) {
      // Unknown server — ignored, per spec.
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
      mediaUrl: remote.mediaUrl != local.mediaUrl ? remote.mediaUrl : null,
      mediaSizeLimit: remote.mediaSizeLimit != local.mediaSizeLimit
          ? remote.mediaSizeLimit
          : null,
      mediaTimer:
          remote.mediaTimer != local.mediaTimer ? remote.mediaTimer : null,
      maxPayload:
          remote.maxPayload != local.maxPayload ? remote.maxPayload : null,
      capabilities: remote.capabilities != local.capabilities
          ? remote.capabilities
          : null,
    );
  }
}