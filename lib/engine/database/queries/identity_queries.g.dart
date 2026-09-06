// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_queries.dart';

// ignore_for_file: type=lint
mixin _$IdentityDaoMixin on DatabaseAccessor<AppDatabase> {
  $IdentityTable get identity => attachedDatabase.identity;
  IdentityDaoManager get managers => IdentityDaoManager(this);
}

class IdentityDaoManager {
  final _$IdentityDaoMixin _db;
  IdentityDaoManager(this._db);
  $$IdentityTableTableManager get identity =>
      $$IdentityTableTableManager(_db.attachedDatabase, _db.identity);
}
