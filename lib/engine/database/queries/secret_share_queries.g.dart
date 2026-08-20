// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secret_share_queries.dart';

// ignore_for_file: type=lint
mixin _$SecretShareDaoMixin on DatabaseAccessor<dynamic /* = invalid*/> {
  $IdentityTable get identity => attachedDatabase.identity;
  $SecretShareTable get secretShare => attachedDatabase.secretShare;
  SecretShareDaoManager get managers => SecretShareDaoManager(this);
}

class SecretShareDaoManager {
  final _$SecretShareDaoMixin _db;
  SecretShareDaoManager(this._db);
  $$IdentityTableTableManager get identity =>
      $$IdentityTableTableManager(_db.attachedDatabase, _db.identity);
  $$SecretShareTableTableManager get secretShare =>
      $$SecretShareTableTableManager(_db.attachedDatabase, _db.secretShare);
}
