import 'package:uuid/uuid.dart';
import '../database/queries/connection_requests_queries.dart';

const _uuid = Uuid();
const _thirtyDaysMs = 30 * 24 * 60 * 60 * 1000;

/// Creates a new pending connection request.
Future<String> createConnectionRequest(
  ConnectionRequestsDao dao, {
  required String requesterId,
  required String recipientId,
  required String groupId,
  required String introduction,
  int? expiresAt,
}) async {
  final requestId = _uuid.v4();
  final now = DateTime.now().millisecondsSinceEpoch;

  final companion = ConnectionRequestsCompanion.insert(
    requestId: requestId,
    requesterId: requesterId,
    recipientId: recipientId,
    groupId: groupId,
    introduction: introduction,
    status: 0, // pending
    createdAt: now,
    expiresAt: Value(expiresAt),
  );

  await dao.insertRequest(companion);
  return requestId;
}

/// Accepts a connection request.
Future<void> acceptConnectionRequest(
  ConnectionRequestsDao dao,
  String requestId,
) async {
  await dao.acceptRequest(requestId);
}

/// Rejects a connection request, then sweeps the table for any requests
/// whose expiration is more than 30 days in the past, deleting them.
Future<void> rejectConnectionRequest(
  ConnectionRequestsDao dao,
  String requestId,
) async {
  await dao.rejectRequest(requestId);

  final now = DateTime.now().millisecondsSinceEpoch;
  final allRequests = await dao.db.select(dao.db.connectionRequests).get();

  for (final request in allRequests) {
    final expiresAt = request.expiresAt;
    if (expiresAt != null && now - expiresAt > _thirtyDaysMs) {
      await dao.deleteRequest(request.requestId);
    }
  }
}