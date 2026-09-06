// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_requests_queries.dart';

// ignore_for_file: type=lint
mixin _$ConnectionRequestsDaoMixin on DatabaseAccessor<dynamic /* = invalid*/> {
  $IdentityTable get identity => attachedDatabase.identity;
  $GroupsTable get groups => attachedDatabase.groups;
  $ConnectionRequestsTable get connectionRequests =>
      attachedDatabase.connectionRequests;
  ConnectionRequestsDaoManager get managers =>
      ConnectionRequestsDaoManager(this);
}

class ConnectionRequestsDaoManager {
  final _$ConnectionRequestsDaoMixin _db;
  ConnectionRequestsDaoManager(this._db);
  $$IdentityTableTableManager get identity =>
      $$IdentityTableTableManager(_db.attachedDatabase, _db.identity);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db.attachedDatabase, _db.groups);
  $$ConnectionRequestsTableTableManager get connectionRequests =>
      $$ConnectionRequestsTableTableManager(
        _db.attachedDatabase,
        _db.connectionRequests,
      );
}
