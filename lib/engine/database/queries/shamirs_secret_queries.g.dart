// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shamirs_secret_queries.dart';

// ignore_for_file: type=lint
mixin _$ShamirsSecretDaoMixin on DatabaseAccessor<dynamic /* = invalid*/> {
  $IdentityTable get identity => attachedDatabase.identity;
  $ShamirsSecretTable get shamirsSecret => attachedDatabase.shamirsSecret;
  ShamirsSecretDaoManager get managers => ShamirsSecretDaoManager(this);
}

class ShamirsSecretDaoManager {
  final _$ShamirsSecretDaoMixin _db;
  ShamirsSecretDaoManager(this._db);
  $$IdentityTableTableManager get identity =>
      $$IdentityTableTableManager(_db.attachedDatabase, _db.identity);
  $$ShamirsSecretTableTableManager get shamirsSecret =>
      $$ShamirsSecretTableTableManager(_db.attachedDatabase, _db.shamirsSecret);
}
