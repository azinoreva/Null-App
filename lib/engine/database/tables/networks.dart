import 'package:drift/drift.dart';

import 'contacts.dart'; // for foreign key reference

/// Drift table definition for the `ContactsNetwork` table.
///
/// Stores user‑defined groups/lists of contacts.
class ContactsNetwork extends Table {
  TextColumn get networkId => text()();
  TextColumn get networkName => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get serverId => text()();

  @override
  Set<Column> get primaryKey => {networkId};
}

/// Drift table definition for the `ContactNetworkMembers` table.
///
/// Junction table linking contacts to networks (many‑to‑many).
class ContactNetworkMembers extends Table {
  TextColumn get networkId => text().references(
    ContactsNetwork,
    #networkId,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get contactId =>
      text().references(Contacts, #contactId, onDelete: KeyAction.cascade)();

  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {networkId, contactId};
}
