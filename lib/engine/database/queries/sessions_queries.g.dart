// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions_queries.dart';

// ignore_for_file: type=lint
mixin _$SessionsDaoMixin on DatabaseAccessor<dynamic /* = invalid*/> {
  $ConversationsTable get conversations => attachedDatabase.conversations;
  $SessionsTable get sessions => attachedDatabase.sessions;
  SessionsDaoManager get managers => SessionsDaoManager(this);
}

class SessionsDaoManager {
  final _$SessionsDaoMixin _db;
  SessionsDaoManager(this._db);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db.attachedDatabase, _db.conversations);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db.attachedDatabase, _db.sessions);
}
