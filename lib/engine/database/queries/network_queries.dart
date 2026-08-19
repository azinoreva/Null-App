import 'package:drift/drift.dart';

import '../tables/networks.dart';
import '../tables/contacts.dart';

part 'network_queries.g.dart';

/// Data Access Object for the `ContactsNetwork` table.
@DriftAccessor(tables: [ContactsNetwork])
class ContactsNetworkDao extends DatabaseAccessor<AppDatabase>
    with _$ContactsNetworkDaoMixin {
  ContactsNetworkDao(AppDatabase db) : super(db);

  // Get a single network by ID.
  Future<ContactsNetwork?> getNetworkById(String id) => (select(
    db.contactsNetwork,
  )..where((t) => t.networkId.equals(id))).getSingleOrNull();

  // Get all networks.
  Future<List<ContactsNetwork>> getAllNetworks() =>
      select(db.contactsNetwork).get();

  // Insert a new network.
  Future<int> insertNetwork(Insertable<ContactsNetwork> network) =>
      into(db.contactsNetwork).insert(network);

  // Upsert a network.
  Future<void> upsertNetwork(ContactsNetwork network) =>
      into(db.contactsNetwork).insertOnConflictUpdate(network);

  // Update an existing network.
  Future<bool> updateNetwork(ContactsNetwork network) =>
      update(db.contactsNetwork).replace(network);

  // Delete a network by ID.
  Future<int> deleteNetwork(String id) =>
      (delete(db.contactsNetwork)..where((t) => t.networkId.equals(id))).go();
}

/// Data Access Object for the `ContactNetworkMembers` junction table.
@DriftAccessor(tables: [ContactNetworkMembers])
class ContactNetworkMembersDao extends DatabaseAccessor<AppDatabase>
    with _$ContactNetworkMembersDaoMixin {
  ContactNetworkMembersDao(AppDatabase db) : super(db);

  // Add a contact to a network.
  Future<int> addMember(String networkId, String contactId) =>
      into(db.contactNetworkMembers).insert(
        ContactNetworkMembersCompanion.insert(
          networkId: networkId,
          contactId: contactId,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  // Remove a contact from a network.
  Future<int> removeMember(String networkId, String contactId) =>
      (delete(db.contactNetworkMembers)..where(
            (t) =>
                t.networkId.equals(networkId) & t.contactId.equals(contactId),
          ))
          .go();

  // Check if a contact is in a network.
  Future<bool> isMember(String networkId, String contactId) async {
    final count =
        await (selectOnly(db.contactNetworkMembers)
              ..addColumns([db.contactNetworkMembers.contactId])
              ..where(
                db.contactNetworkMembers.networkId.equals(networkId) &
                    db.contactNetworkMembers.contactId.equals(contactId),
              ))
            .get();
    return count.isNotEmpty;
  }

  // Get all contact IDs in a network.
  Future<List<String>> getContactIdsInNetwork(String networkId) async {
    final rows =
        await (selectOnly(db.contactNetworkMembers)
              ..addColumns([db.contactNetworkMembers.contactId])
              ..where(db.contactNetworkMembers.networkId.equals(networkId)))
            .get();
    return rows
        .map((row) => row.read(db.contactNetworkMembers.contactId)!)
        .toList();
  }

  // Get all network IDs for a contact.
  Future<List<String>> getNetworkIdsForContact(String contactId) async {
    final rows =
        await (selectOnly(db.contactNetworkMembers)
              ..addColumns([db.contactNetworkMembers.networkId])
              ..where(db.contactNetworkMembers.contactId.equals(contactId)))
            .get();
    return rows
        .map((row) => row.read(db.contactNetworkMembers.networkId)!)
        .toList();
  }
}
