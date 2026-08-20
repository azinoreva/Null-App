// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_queries.dart';

// ignore_for_file: type=lint
mixin _$ContactsNetworkDaoMixin on DatabaseAccessor<dynamic /* = invalid*/> {
  $ContactsNetworkTable get contactsNetwork => attachedDatabase.contactsNetwork;
  ContactsNetworkDaoManager get managers => ContactsNetworkDaoManager(this);
}

class ContactsNetworkDaoManager {
  final _$ContactsNetworkDaoMixin _db;
  ContactsNetworkDaoManager(this._db);
  $$ContactsNetworkTableTableManager get contactsNetwork =>
      $$ContactsNetworkTableTableManager(
        _db.attachedDatabase,
        _db.contactsNetwork,
      );
}

mixin _$ContactNetworkMembersDaoMixin
    on DatabaseAccessor<dynamic /* = invalid*/> {
  $ContactsNetworkTable get contactsNetwork => attachedDatabase.contactsNetwork;
  $ConversationsTable get conversations => attachedDatabase.conversations;
  $ContactsTable get contacts => attachedDatabase.contacts;
  $ContactNetworkMembersTable get contactNetworkMembers =>
      attachedDatabase.contactNetworkMembers;
  ContactNetworkMembersDaoManager get managers =>
      ContactNetworkMembersDaoManager(this);
}

class ContactNetworkMembersDaoManager {
  final _$ContactNetworkMembersDaoMixin _db;
  ContactNetworkMembersDaoManager(this._db);
  $$ContactsNetworkTableTableManager get contactsNetwork =>
      $$ContactsNetworkTableTableManager(
        _db.attachedDatabase,
        _db.contactsNetwork,
      );
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db.attachedDatabase, _db.conversations);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db.attachedDatabase, _db.contacts);
  $$ContactNetworkMembersTableTableManager get contactNetworkMembers =>
      $$ContactNetworkMembersTableTableManager(
        _db.attachedDatabase,
        _db.contactNetworkMembers,
      );
}
