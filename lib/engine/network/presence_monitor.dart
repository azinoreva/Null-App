import 'dart:async';

import '../../utils/server_list.dart';
import '../database/app_database.dart';
import 'api_client.dart';
import 'auth_failure_handler.dart';
import 'chats/prescence_check.dart';

/// Keeps every connected contact's online status fresh.
///
/// The server tracks presence only while a user holds a live socket, and
/// answers `POST /api/presence` with a `user_id -> online` map. Nothing pushed
/// that over the message socket, so the app has to ask. This polls each
/// contact's own servers on an interval shorter than the server's presence
/// lease, then writes the result into both the `contacts` and `sync_state`
/// projections so the contacts list and the chat list's status dot agree.
class PresenceMonitor {
  PresenceMonitor({
    required this.database,
    this.interval = const Duration(seconds: 60),
  });

  final AppDatabase database;
  final Duration interval;

  Timer? _timer;
  bool _running = false;
  bool _ticking = false;

  void start() {
    if (_running) return;
    _running = true;
    unawaited(refresh());
    _timer = Timer.periodic(interval, (_) => unawaited(refresh()));
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  /// Queries presence for every connected contact and persists the result.
  /// Re-entrant calls while a tick is still running are dropped.
  Future<void> refresh() async {
    if (_ticking) return;
    _ticking = true;
    try {
      final contacts = await database.contactsDao.getConnectedContacts();
      if (contacts.isEmpty) return;

      // Contacts whose saved card never carried a server list still have to be
      // asked somewhere; fall back to the servers this device is registered on.
      final localServers = await ServerListService.readServerIds();

      final idsByServer = <String, Set<String>>{};
      for (final contact in contacts) {
        final servers =
            contact.servers.isEmpty ? localServers : contact.servers;
        for (final serverId in servers) {
          if (serverId.isEmpty) continue;
          idsByServer.putIfAbsent(serverId, () => <String>{}).add(
            contact.contactId,
          );
        }
      }

      final online = <String, bool>{};
      for (final entry in idsByServer.entries) {
        try {
          if (!ApiClient.isRegistered(entry.key)) {
            await ApiClient.registerServer(
              serverId: entry.key,
              onAuthFailure: serverAuthFailureCallbackFor(entry.key),
            );
          }
          final response = await PresenceService(
            serverId: entry.key,
          ).getPresence(userIds: entry.value.toList());
          online.addAll(response.presence);
        } catch (_) {
          // One unreachable server must not stop the rest from reporting.
        }
      }

      for (final contact in contacts) {
        final isOnline = online[contact.contactId];
        if (isOnline == null) continue;
        final status = isOnline ? 1 : 0;
        if (contact.isOnline != status) {
          await database.contactsDao.setOnlineStatus(contact.contactId, status);
        }
        await database.syncStateDao.setStatus(contact.contactId, status);
      }
    } finally {
      _ticking = false;
    }
  }
}
