import 'package:drift/drift.dart';

import '../tables/connection_requests.dart';

part 'connection_requests_queries.g.dart';

/// Data Access Object for the `ConnectionRequests` table.
@DriftAccessor(tables: [ConnectionRequests])
class ConnectionRequestsDao extends DatabaseAccessor<AppDatabase>
    with _$ConnectionRequestsDaoMixin {
  ConnectionRequestsDao(AppDatabase db) : super(db);

  // Get a single request by ID.
  Future<ConnectionRequests?> getRequestById(String id) => (select(
    db.connectionRequests,
  )..where((t) => t.requestId.equals(id))).getSingleOrNull();

  // Get all requests where the given identity is the recipient.
  Future<List<ConnectionRequests>> getRequestsForRecipient(
    String recipientId,
  ) => (select(
    db.connectionRequests,
  )..where((t) => t.recipientId.equals(recipientId))).get();

  // Get all requests where the given identity is the requester.
  Future<List<ConnectionRequests>> getRequestsByRequester(String requesterId) =>
      (select(
        db.connectionRequests,
      )..where((t) => t.requesterId.equals(requesterId))).get();

  // Get all requests for a specific group.
  Future<List<ConnectionRequests>> getRequestsForGroup(String groupId) =>
      (select(
        db.connectionRequests,
      )..where((t) => t.groupId.equals(groupId))).get();

  // Get pending (status = 0) requests for a recipient.
  Future<List<ConnectionRequests>> getPendingRequestsForRecipient(
    String recipientId,
  ) =>
      (select(db.connectionRequests)..where(
            (t) => t.recipientId.equals(recipientId) & t.status.equals(0),
          ))
          .get();

  // Insert a new connection request.
  Future<int> insertRequest(Insertable<ConnectionRequests> request) =>
      into(db.connectionRequests).insert(request);

  // Update an existing request row.
  Future<bool> updateRequest(ConnectionRequests request) =>
      update(db.connectionRequests).replace(request);

  // Delete a request by ID.
  Future<int> deleteRequest(String id) => (delete(
    db.connectionRequests,
  )..where((t) => t.requestId.equals(id))).go();

  // Accept a request: set status = 1 and accepted_at = now.
  Future<void> acceptRequest(String requestId, {int? timestamp}) async {
    final now = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    await (update(
      db.connectionRequests,
    )..where((t) => t.requestId.equals(requestId))).write(
      ConnectionRequestsCompanion(
        status: const Value(1),
        acceptedAt: Value(now),
      ),
    );
  }

  // Reject a request: set status = 2 and rejected_at = now.
  Future<void> rejectRequest(String requestId, {int? timestamp}) async {
    final now = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    await (update(
      db.connectionRequests,
    )..where((t) => t.requestId.equals(requestId))).write(
      ConnectionRequestsCompanion(
        status: const Value(2),
        rejectedAt: Value(now),
      ),
    );
  }

  // Automatically reject all pending requests past their expiration time.
  Future<int> rejectExpiredRequests({int? currentTime}) async {
    final now = currentTime ?? DateTime.now().millisecondsSinceEpoch;
    final affected =
        await (update(db.connectionRequests)..where(
              (t) =>
                  t.status.equals(0) &
                  t.expiresAt.isNotNull() &
                  t.expiresAt.isSmallerThanValue(now),
            ))
            .write(
              ConnectionRequestsCompanion(
                status: const Value(2),
                rejectedAt: Value(now),
              ),
            );
    return affected;
  }
}
