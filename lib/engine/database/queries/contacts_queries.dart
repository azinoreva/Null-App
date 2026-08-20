import 'package:drift/drift.dart';

import '../tables/contacts.dart';

part 'contacts_queries.g.dart';

/// Data Access Object for the `Contacts` table.
@DriftAccessor(tables: [Contacts])
class ContactsDao extends DatabaseAccessor<AppDatabase>
    with _$ContactsDaoMixin {
  ContactsDao(super.db);

  // Get a single contact by ID.
  Future<Contacts?> getContactById(String id) => (select(
    db.contacts,
  )..where((t) => t.contactId.equals(id))).getSingleOrNull();

  // Get all contacts.
  Future<List<Contacts>> getAllContacts() => select(db.contacts).get();

  // Get contacts by connection status (1=Pending, 2=Connected, etc.).
  Future<List<Contacts>> getContactsByStatus(int status) => (select(
    db.contacts,
  )..where((t) => t.connectionStatus.equals(status))).get();

  // Get only connected contacts (status = 2).
  Future<List<Contacts>> getConnectedContacts() => getContactsByStatus(2);

  // Get contacts that are online and connected.
  Future<List<Contacts>> getOnlineConnectedContacts() => (select(
    db.contacts,
  )..where((t) => t.connectionStatus.equals(2) & t.isOnline.equals(1))).get();

  // Get a contact by its linked conversation ID.
  Future<Contacts?> getContactByConversationId(String conversationId) =>
      (select(db.contacts)
            ..where((t) => t.conversationId.equals(conversationId)))
          .getSingleOrNull();

  // Insert a new contact.
  Future<int> insertContact(Insertable<Contacts> contact) =>
      into(db.contacts).insert(contact);

  // Upsert (insert or update) a contact.
  Future<void> upsertContact(Contacts contact) =>
      into(db.contacts).insertOnConflictUpdate(contact);

  // Update an existing contact row.
  Future<bool> updateContact(Contacts contact) =>
      update(db.contacts).replace(contact);

  // Delete a contact by ID.
  Future<int> deleteContact(String id) =>
      (delete(db.contacts)..where((t) => t.contactId.equals(id))).go();

  // Update the online status of a contact.
  Future<void> setOnlineStatus(String contactId, int isOnline) async {
    await (update(db.contacts)..where((t) => t.contactId.equals(contactId)))
        .write(ContactsCompanion(isOnline: Value(isOnline)));
  }

  // Update the last seen timestamp of a contact.
  Future<void> updateLastSeen(String contactId, int timestamp) async {
    await (update(db.contacts)..where((t) => t.contactId.equals(contactId)))
        .write(ContactsCompanion(lastSeen: Value(timestamp)));
  }

  // Toggle the mute flag for a contact.
  Future<void> setMuted(String contactId, int muted) async {
    await (update(db.contacts)..where((t) => t.contactId.equals(contactId)))
        .write(ContactsCompanion(muted: Value(muted)));
  }

  // Toggle the pinned flag for a contact.
  Future<void> setPinned(String contactId, int pinned) async {
    await (update(db.contacts)..where((t) => t.contactId.equals(contactId)))
        .write(ContactsCompanion(pinned: Value(pinned)));
  }

  // Update the connection status (e.g., after accept/block/delete).
  Future<void> setConnectionStatus(String contactId, int status) async {
    await (update(db.contacts)..where((t) => t.contactId.equals(contactId)))
        .write(ContactsCompanion(connectionStatus: Value(status)));
  }

  // Link or update the conversation ID for a contact.
  Future<void> setConversationId(
    String contactId,
    String? conversationId,
  ) async {
    await (update(db.contacts)..where((t) => t.contactId.equals(contactId)))
        .write(ContactsCompanion(conversationId: Value(conversationId)));
  }
}
