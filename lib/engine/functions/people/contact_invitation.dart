// module name: invite_contact

import '../../database/queries/identity_queries.dart';
import '../../network/people/create_invite.dart';

/// Sends an invitation to a contact.
///
/// Looks up the current user's identity to get their public key (the
/// invite is generated using the CURRENT user's public key, per
/// SendContactService's contract), then calls the invite-contact API
/// via SendContactService using [serverId].
Future<SendContactResponse> sendContactInvitation(
  IdentityDao identityDao, {
  required String serverId,
}) async {
  final identity = await identityDao.getCurrentIdentityOrNull();

  if (identity == null) {
    throw StateError('No local identity found — cannot send an invite.');
  }

  final publicKey = identity.publicKey;
  if (publicKey == null) {
    throw StateError('Current identity has no public key set.');
  }

  final service = SendContactService(serverId: serverId);

  final result = await service.generateInvite(publicKey: publicKey);

  return result;
}