import 'package:drift/drift.dart';
import 'identity.dart';
import 'groups.dart';

/// Drift table definition for the `ConnectionRequests` table.
///
/// Stores connection requests between users, typically within a group
/// context. Status values: 0 = pending, 1 = accepted, 2 = rejected.
class ConnectionRequests extends Table {
  TextColumn get requestId => text()();

  TextColumn get requesterId =>
      text().references(Identity, #identityId, onDelete: KeyAction.cascade)();

  TextColumn get recipientId =>
      text().references(Identity, #identityId, onDelete: KeyAction.cascade)();

  TextColumn get groupId =>
      text().references(Groups, #groupId, onDelete: KeyAction.cascade)();

  TextColumn get introduction => text()();

  // Column name `_status`.
  IntColumn get status => integer().named('_status')();

  // Timestamps stored as Unix epoch milliseconds.
  IntColumn get createdAt => integer()();
  IntColumn get acceptedAt => integer().nullable()();
  IntColumn get rejectedAt => integer().nullable()();
  IntColumn get expiresAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {requestId};
}