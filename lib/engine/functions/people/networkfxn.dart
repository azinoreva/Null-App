// module name: contact_network_management.dart

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/queries/network_queries.dart';

const _uuid = Uuid();

/// 1. Creates a new contact network.
/// Generates networkId (uuid), stamps createdAt/updatedAt to now.
Future<String> createContactNetwork(
  ContactsNetworkDao networkDao, {
  required String networkName,
  required String serverId,
}) async {
  final networkId = _uuid.v4();
  final now = DateTime.now().millisecondsSinceEpoch;

  final companion = ContactsNetworkCompanion.insert(
    networkId: networkId,
    networkName: networkName,
    createdAt: now,
    updatedAt: now,
    serverId: serverId,
  );

  await networkDao.insertNetwork(companion);
  return networkId;
}

/// 2. Bulk (or single) write of contacts into a network.
/// Pass one or more contact IDs; each is inserted as a member row of
/// [networkId]. Wrapped in a transaction so it's all-or-nothing.
Future<void> addContactsToNetwork(
  ContactNetworkMembersDao membersDao, {
  required String networkId,
  required List<String> contactIds,
}) async {
  final now = DateTime.now().millisecondsSinceEpoch;

  await membersDao.db.transaction(() async {
    for (final contactId in contactIds) {
      await membersDao.db.into(membersDao.db.contactNetworkMembers).insert(
            ContactNetworkMembersCompanion.insert(
              networkId: networkId,
              contactId: contactId,
              createdAt: now,
            ),
          );
    }
  });
}

/// 3. Deletes a network and all of its members.
/// Explicitly deletes member rows first (safeguard in case cascading
/// foreign keys aren't enabled), then deletes the network row itself.
Future<void> deleteNetworkAndMembers(
  ContactsNetworkDao networkDao,
  ContactNetworkMembersDao membersDao,
  String networkId,
) async {
  await networkDao.db.transaction(() async {
    await (membersDao.delete(membersDao.db.contactNetworkMembers)
          ..where((t) => t.networkId.equals(networkId)))
        .go();

    await networkDao.deleteNetwork(networkId);
  });
}

/// 4. Removes a single contact from a network (leaves the network and
/// other members intact).
Future<void> removeContactFromNetwork(
  ContactNetworkMembersDao membersDao, {
  required String networkId,
  required String contactId,
}) {
  return membersDao.removeMember(networkId, contactId);
}

