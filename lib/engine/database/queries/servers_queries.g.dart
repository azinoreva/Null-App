// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'servers_queries.dart';

// ignore_for_file: type=lint
mixin _$ServersDaoMixin on DatabaseAccessor<dynamic /* = invalid*/> {
  $ServersTable get servers => attachedDatabase.servers;
  ServersDaoManager get managers => ServersDaoManager(this);
}

class ServersDaoManager {
  final _$ServersDaoMixin _db;
  ServersDaoManager(this._db);
  $$ServersTableTableManager get servers =>
      $$ServersTableTableManager(_db.attachedDatabase, _db.servers);
}
