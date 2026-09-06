// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_queries.dart';

// ignore_for_file: type=lint
mixin _$ContactsDaoMixin on DatabaseAccessor<dynamic /* = invalid*/> {
  $ConversationsTable get conversations => attachedDatabase.conversations;
  $ContactsTable get contacts => attachedDatabase.contacts;
  ContactsDaoManager get managers => ContactsDaoManager(this);
}

class ContactsDaoManager {
  final _$ContactsDaoMixin _db;
  ContactsDaoManager(this._db);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db.attachedDatabase, _db.conversations);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db.attachedDatabase, _db.contacts);
}
