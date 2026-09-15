// module name: sessions_queries

import 'package:drift/drift.dart';
import '../app_database.dart';

import '../tables/sessions.dart';

part 'sessions_queries.g.dart';

/// Data Access Object for the `Sessions` table.
@DriftAccessor(tables: [Sessions])
class SessionsDao extends DatabaseAccessor<AppDatabase>
    with _$SessionsDaoMixin {
  SessionsDao(super.db);

  Future<Session?> getSessionByConversationId(String conversationId) =>
      (select(db.sessions)
            ..where((t) => t.conversationId.equals(conversationId)))
          .getSingleOrNull();

  Future<int> insertSession(Insertable<Session> session) =>
      into(db.sessions).insert(session);

  Future<void> upsertSession(Insertable<Session> session) =>
      into(db.sessions).insertOnConflictUpdate(session);

  Future<int> deleteSession(String conversationId) =>
      (delete(db.sessions)
            ..where((t) => t.conversationId.equals(conversationId)))
          .go();

  /// Starts a fresh pending session, storing our ephemeral keypair.
  /// Overwrites any prior session for this conversation (a fresh
  /// handshake attempt supersedes an old one).
  Future<void> startPendingSession({
    required String conversationId,
    required Uint8List ephemeralPrivateKey,
    required Uint8List ephemeralPublicKey,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await upsertSession(
      SessionsCompanion.insert(
        conversationId: conversationId,
        ephemeralPrivateKey: Value(ephemeralPrivateKey),
        ephemeralPublicKey: Value(ephemeralPublicKey),
        symmetricKey: const Value(null),
        status: const Value(0),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Records the derived symmetric key once the DH exchange completes,
  /// and advances status to 1 (confirming).
  Future<void> setSymmetricKey({
    required String conversationId,
    required Uint8List symmetricKey,
  }) async {
    await (update(db.sessions)
          ..where((t) => t.conversationId.equals(conversationId)))
        .write(
      SessionsCompanion(
        symmetricKey: Value(symmetricKey),
        status: const Value(1),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Creates an established session for a locally generated pre-shared key.
  Future<void> establishWithSymmetricKey({
    required String conversationId,
    required Uint8List symmetricKey,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await upsertSession(
      SessionsCompanion.insert(
        conversationId: conversationId,
        symmetricKey: Value(symmetricKey),
        status: const Value(2),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Marks the session as fully established and clears the now-unneeded
  /// ephemeral private key.
  Future<void> markEstablished(String conversationId) async {
    await (update(db.sessions)
          ..where((t) => t.conversationId.equals(conversationId)))
        .write(
      SessionsCompanion(
        status: const Value(2),
        ephemeralPrivateKey: const Value(null),
        ephemeralPublicKey: const Value(null),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}