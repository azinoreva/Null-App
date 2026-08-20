// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_members_queries.dart';

// ignore_for_file: type=lint
mixin _$GroupMembersDaoMixin on DatabaseAccessor<dynamic /* = invalid*/> {
  $GroupsTable get groups => attachedDatabase.groups;
  $IdentityTable get identity => attachedDatabase.identity;
  $GroupMembersTable get groupMembers => attachedDatabase.groupMembers;
  GroupMembersDaoManager get managers => GroupMembersDaoManager(this);
}

class GroupMembersDaoManager {
  final _$GroupMembersDaoMixin _db;
  GroupMembersDaoManager(this._db);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db.attachedDatabase, _db.groups);
  $$IdentityTableTableManager get identity =>
      $$IdentityTableTableManager(_db.attachedDatabase, _db.identity);
  $$GroupMembersTableTableManager get groupMembers =>
      $$GroupMembersTableTableManager(_db.attachedDatabase, _db.groupMembers);
}
