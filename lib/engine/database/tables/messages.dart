import 'package:drift/drift.dart';

import 'conversations.dart'; // for foreign key reference

/// Drift table definition for the `Messages` table.
class Messages extends Table {
  TextColumn get messageId => text()();
  TextColumn get logicalMessageId => text()();

  // Foreign key to Conversations with cascade delete.
  TextColumn get conversationId => text().references(
    Conversations,
    #conversationId,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get senderId => text()();

  IntColumn get senderSequence => integer()();
  IntColumn get messageOrder => integer()();
  IntColumn get chainIndex => integer()();

  // Column name `_timestamp` (reserved in Dart, so we use `timestamp` getter).
  IntColumn get timestamp => integer().named('_timestamp')();

  BlobColumn get ciphertext => blob()();
  BlobColumn get nonce => blob()();

  IntColumn get messageType => integer()();

  // Column name `_status`.
  IntColumn get status => integer().named('_status')();
  BlobColumn get mac => blob()();

  IntColumn get keyVersion => integer()();

  TextColumn get replyTo => text().nullable()();

  IntColumn get edited =>
      integer().withDefault(const Constant(0)).check(edited.isIn([0, 1]))();

  IntColumn get protocolVersion => integer().withDefault(const Constant(1))();

  IntColumn get receivedAt => integer().nullable()();
  IntColumn get readAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {messageId};
}
