import 'package:drift/drift.dart';

import '../tables/servers.dart';

// You need to import your main database class here (the one with @DriftDatabase).
// For example:
// import '../database/app_database.dart';

part 'servers_queries.g.dart';

/// Data Access Object for the `Servers` table.
@DriftAccessor(tables: [Servers])
class ServersDao extends DatabaseAccessor<AppDatabase> with _$ServersDaoMixin {
  ServersDao(super.db);

  // Fetch a single server by its ID.
  Future<Servers?> getServerById(String id) => (select(
    db.servers,
  )..where((t) => t.serverId.equals(id))).getSingleOrNull();

  // Retrieve all servers.
  Future<List<Servers>> getAllServers() => select(db.servers).get();

  // Insert a new server.
  Future<int> insertServer(Insertable<Servers> server) =>
      into(db.servers).insert(server);

  // Replace an existing server (upsert).
  Future<void> upsertServer(Servers server) =>
      into(db.servers).insertOnConflictUpdate(server);

  // Update an existing server row.
  Future<bool> updateServer(Servers server) =>
      update(db.servers).replace(server);

  // Delete a server by ID.
  Future<int> deleteServer(String id) =>
      (delete(db.servers)..where((t) => t.serverId.equals(id))).go();

  // Increment the total media sent by a given amount.
  Future<void> incrementMediaSent(String serverId, int amount) async {
    final server = await getServerById(serverId);
    if (server != null) {
      final newTotal = server.totalMediaSent + amount;
      await (update(db.servers)..where((t) => t.serverId.equals(serverId)))
          .write(ServersCompanion(totalMediaSent: Value(newTotal)));
    }
  }

  // Reset the media usage counter and update the last reset timestamp.
  Future<void> resetMediaUsage(String serverId) async {
    await (update(db.servers)..where((t) => t.serverId.equals(serverId))).write(
      ServersCompanion(
        totalMediaSent: const Value(0),
        mediaLastReset: Value(DateTime.now()),
      ),
    );
  }

  // Update the capabilities bitmask.
  Future<void> updateCapabilities(String serverId, int newCapabilities) async {
    await (update(db.servers)..where((t) => t.serverId.equals(serverId))).write(
      ServersCompanion(capabilities: Value(newCapabilities)),
    );
  }
}
