// module name: sessions (table)

import 'package:drift/drift.dart';

import 'conversations.dart'; // for foreign key reference

/// Drift table definition for the `Sessions` table.
///
/// Stores Diffie-Hellman handshake state and the resulting symmetric
/// session key per conversation, so a handshake can resume/survive an
/// app restart instead of living only in memory.
///
/// Lifecycle:
///   status 0 (pending)   -> ephemeralPrivateKey/ephemeralPublicKey are set,
///                           symmetricKey is null. We've sent our DH
///                           public key and are waiting for the contact's.
///   status 1 (confirming) -> symmetricKey is set (DH completed), but the
///                            "oknull" round-trip confirmation hasn't
///                            completed yet.
///   status 2 (established) -> fully confirmed, ready for real messages.
///                             ephemeralPrivateKey is cleared at this
///                             point (no longer needed, shouldn't linger).
class Sessions extends Table {
  TextColumn get conversationId => text().references(
    Conversations,
    #conversationId,
    onDelete: KeyAction.cascade,
  )();

  // Our local ephemeral X25519 keypair for the in-progress handshake.
  // Cleared once the session reaches status 2 (established).
  BlobColumn get ephemeralPrivateKey => blob().nullable()();
  BlobColumn get ephemeralPublicKey => blob().nullable()();

  // The derived shared symmetric key, once the DH exchange completes.
  BlobColumn get symmetricKey => blob().nullable()();

  IntColumn get keyVersion => integer().withDefault(const Constant(1))();

  // 0 = pending DH, 1 = confirming oknull, 2 = established.
  IntColumn get status =>
      integer().withDefault(const Constant(0)).check(status.isIn([0, 1, 2]))();

  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {conversationId};
}