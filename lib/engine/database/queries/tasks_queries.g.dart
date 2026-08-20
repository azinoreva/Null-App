// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks_queries.dart';

// ignore_for_file: type=lint
mixin _$TasksDaoMixin on DatabaseAccessor<dynamic /* = invalid*/> {
  $ServersTable get servers => attachedDatabase.servers;
  $TasksTable get tasks => attachedDatabase.tasks;
  TasksDaoManager get managers => TasksDaoManager(this);
}

class TasksDaoManager {
  final _$TasksDaoMixin _db;
  TasksDaoManager(this._db);
  $$ServersTableTableManager get servers =>
      $$ServersTableTableManager(_db.attachedDatabase, _db.servers);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db.attachedDatabase, _db.tasks);
}
