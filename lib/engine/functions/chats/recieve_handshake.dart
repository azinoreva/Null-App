// module name: receive_handshake_message

import 'dart:convert';
import 'package:cryptography/cryptography.dart';

import '../../database/queries/contacts_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/messages_queries.dart';
import '../../database/queries/sessions_queries.dart';
import '../../crypto/chat/key_exchange.dart';
import '../../crypto/chat/identity_crypto.dart';
import 'handshake_registry.dart.dart';

/// Call this from your SSE listener for every incoming message where
/// messageType is 0 or 1. Returns true if it handled the message.
Future<bool> handleIncomingHandshakeMessage(
  ContactsDao contactsDao,
  IdentityDao identityDao,
  MessagesDao messagesDao,
  SessionsDao sessionsDao, {
  required String senderContactId,
  required int messageType,
  required String rawMessage, // the "message" field from the SSE payload
  required IdentityCrypto myIdentityCrypto,
}) async {
  if (messageType != 0 && messageType != 1) return false;

  if (messageType == 1) {
    // Ratchet-start message — decrypting this with the established
    // symmetric key depends on the ratchet/AEAD wrapper used for regular
    // post-handshake messages, which hasn't been provided yet. Left as a
    // stub; tell me the ratchet module and I'll fill this in.
    return true;
  }

  final decoded = jsonDecode(rawMessage) as Map<String, dynamic>;
  final kind = decoded['kind'] as String?;

  if (kind == 'dh_exchange') {
    await _handleDhExchange(
      contactsDao,
      identityDao,
      sessionsDao,
      senderContactId: senderContactId,
      decoded: decoded,
    );
    return true;
  }

  if (kind == 'confirmation') {
    await _handleConfirmation(
      sessionsDao,
      senderContactId: senderContactId,
      decoded: decoded,
    );
    return true;
  }

  return false;
}

/// Handles an incoming DH exchange payload. Only the invite-sender ever
/// initiates a handshake, so this always expects a pending local session
/// (created by startEncryptedConversation) to already exist — there is
/// no responder/glare-resolution path.
Future<void> _handleDhExchange(
  ContactsDao contactsDao,
  IdentityDao identityDao,
  SessionsDao sessionsDao, {
  required String senderContactId,
  required Map<String, dynamic> decoded,
}) async {
  final contact = await contactsDao.getContactById(senderContactId);
  if (contact == null || contact.publicKey == null) {
    throw StateError(
      'Unknown contact or missing identity key for $senderContactId.',
    );
  }
  final identity = await identityDao.getCurrentIdentityOrNull();
  if (identity == null || identity.publicKey == null) {
    throw StateError('No local identity/public key available.');
  }

  final peerEphemeralPublicKey =
      base64Url.decode(decoded['ephemeral_public_key'] as String);
  final signature = base64Url.decode(decoded['signature'] as String);

  final session = await sessionsDao.getSessionByConversationId(senderContactId);
  final myEphemeralPrivateKey = session?.ephemeralPrivateKey;
  final myEphemeralPublicKey = session?.ephemeralPublicKey;

  if (myEphemeralPrivateKey == null || myEphemeralPublicKey == null) {
    // We never initiated a handshake for this conversation. Since only
    // the invite-sender initiates, this means either the message arrived
    // unexpectedly or the local session was lost. Not recoverable here —
    // the sender's own retry loop will simply time out.
    throw StateError(
      'Received DH exchange from $senderContactId with no local pending '
      'session — ignoring.',
    );
  }

  final verified = await KeyExchange.verifyExchange(
    conversationId: senderContactId,
    localIdentityId: identity.identityId,
    peerIdentityId: senderContactId,
    localIdentityPublicKey: base64Decode(identity.publicKey!),
    peerIdentityPublicKey: base64Decode(contact.publicKey!),
    localEphemeralPublicKey: myEphemeralPublicKey,
    peerEphemeralPublicKey: peerEphemeralPublicKey,
    signature: signature,
    peerWasInitiator: false, // we are always the initiator in this model
  );
  if (!verified) {
    throw StateError(
      'DH exchange signature from $senderContactId failed verification.',
    );
  }

  final sharedSecret = await KeyExchange.deriveSharedSecret(
    localPrivateKey: myEphemeralPrivateKey,
    peerPublicKey: peerEphemeralPublicKey,
  );

  await sessionsDao.setSymmetricKey(
    conversationId: senderContactId,
    symmetricKey: sharedSecret,
  );

  HandshakeRegistry.instance.confirmDhReceived(senderContactId);
}

Future<void> _handleConfirmation(
  SessionsDao sessionsDao, {
  required String senderContactId,
  required Map<String, dynamic> decoded,
}) async {
  final session = await sessionsDao.getSessionByConversationId(senderContactId);
  final symmetricKeyBytes = session?.symmetricKey;
  if (symmetricKeyBytes == null) {
    throw StateError('No symmetric key established yet for $senderContactId.');
  }

  final aesGcm = AesGcm.with256bits();
  final secretBox = SecretBox(
    base64Url.decode(decoded['ciphertext'] as String),
    nonce: base64Url.decode(decoded['nonce'] as String),
    mac: Mac(base64Url.decode(decoded['mac'] as String)),
  );

  final plaintextBytes = await aesGcm.decrypt(
    secretBox,
    secretKey: SecretKey(symmetricKeyBytes),
  );
  final plaintext = utf8.decode(plaintextBytes);

  if (plaintext != 'oknull') {
    throw StateError('Confirmation from $senderContactId was not "oknull".');
  }

  HandshakeRegistry.instance.confirmOknullReceived(senderContactId);
}