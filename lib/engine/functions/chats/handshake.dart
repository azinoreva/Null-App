// module name: start_encrypted_conversation

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../database/queries/contacts_queries.dart';
import '../../database/queries/conversations_queries.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/sessions_queries.dart';
import '../../crypto/chat/key_exchange.dart'; // KeyExchange
import '../../crypto/chat/identity_crypto.dart'; // IdentityCrypto
import '../../network/chats/send_message.dart';
import 'handshake_registry.dart.dart';

const _uuid = Uuid();

/// Starts (or resumes) an encrypted conversation as the initiator. Sends
/// our DH public key (message type 0), and retries until the contact
/// comes online and sends theirs back — via SSE triggering
/// handleIncomingHandshakeMessage, which completes the wait here. Once
/// both ephemeral keys are exchanged, derives the shared symmetric key,
/// then exchanges an "oknull" confirmation encrypted with THAT key,
/// retrying that step too. Throws if either step never confirms within
/// maxAttempts — there is no way to proceed without it.
Future<void> startEncryptedConversation(
  ContactsDao contactsDao,
  ConversationsDao conversationsDao,
  IdentityDao identityDao,
  SessionsDao sessionsDao, {
  required String contactId,
  required String serverId,
  required IdentityCrypto myIdentityCrypto,
  int maxAttempts = 5,
  Duration attemptTimeout = const Duration(seconds: 15),
}) async {
  final contact = await contactsDao.getContactById(contactId);
  if (contact == null) {
    throw StateError('Contact $contactId not found locally.');
  }
  final contactIdentityPublicKey = contact.publicKey;
  if (contactIdentityPublicKey == null) {
    throw StateError('Contact $contactId has no identity public key on file.');
  }
  final identity = await identityDao.getCurrentIdentityOrNull();
  if (identity == null) throw StateError('No local identity found.');
  final myIdentityPublicKey = identity.publicKey;
  if (myIdentityPublicKey == null) {
    throw StateError('Local identity has no public key set.');
  }

  final existingConvo = await conversationsDao.getConversationById(contactId);
  if (existingConvo == null) {
    final now = DateTime.now().millisecondsSinceEpoch;
    await conversationsDao.insertConversation(
      ConversationsCompanion.insert(
        conversationId: contactId,
        conversationType: 0,
        serverId: serverId,
        unreadCount: const Value(0),
        muted: const Value(0),
        pinned: const Value(0),
        archived: const Value(0),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  // --- Phase 1: exchange ephemeral DH public keys ---
  final ephemeralKeyPair = await KeyExchange.generateEphemeralKeyPair();

  await sessionsDao.startPendingSession(
    conversationId: contactId,
    ephemeralPrivateKey: ephemeralKeyPair.privateKey,
    ephemeralPublicKey: ephemeralKeyPair.publicKey,
  );

  final mySignature = await KeyExchange.signExchange(
    identity: myIdentityCrypto,
    conversationId: contactId,
    localIdentityId: identity.identityId,
    peerIdentityId: contactId,
    localIdentityPublicKey: base64Decode(myIdentityPublicKey),
    peerIdentityPublicKey: base64Decode(contactIdentityPublicKey),
    localEphemeralPublicKey: ephemeralKeyPair.publicKey,
    peerEphemeralPublicKey: Uint8List(0), // peer's key not known yet
    initiator: true,
  );

  await _retryUntilConfirmed(
    maxAttempts: maxAttempts,
    attemptTimeout: attemptTimeout,
    waitFor: () => HandshakeRegistry.instance.registerDhWait(contactId),
    send: () => _sendDhPayload(
      contactId: contactId,
      contactUserName: contact.nickname ?? contactId,
      serverId: serverId,
      ephemeralPublicKey: ephemeralKeyPair.publicKey,
      signature: mySignature,
    ),
    failureMessage: 'DH key exchange with $contactId did not complete',
  );

  // The receive handler has, by now, stashed the derived symmetric key
  // into the Sessions table — see _handleDhExchange below.
  final session = await sessionsDao.getSessionByConversationId(contactId);
  final symmetricKeyBytes = session?.symmetricKey;
  if (symmetricKeyBytes == null) {
    throw StateError('Symmetric key was not derived for $contactId.');
  }

  // --- Phase 2: confirm both sides derived the same key via "oknull" ---
  await _retryUntilConfirmed(
    maxAttempts: maxAttempts,
    attemptTimeout: attemptTimeout,
    waitFor: () => HandshakeRegistry.instance.registerConfirmWait(contactId),
    send: () => _sendOknullConfirmation(
      contactId: contactId,
      contactUserName: contact.nickname ?? contactId,
      serverId: serverId,
      symmetricKeyBytes: symmetricKeyBytes,
    ),
    failureMessage: 'Oknull confirmation with $contactId did not complete',
  );

  await sessionsDao.markEstablished(contactId);
  HandshakeRegistry.instance.clear(contactId);
}

Future<void> _retryUntilConfirmed({
  required int maxAttempts,
  required Duration attemptTimeout,
  required Completer<void> Function() waitFor,
  required Future<void> Function() send,
  required String failureMessage,
}) async {
  var attempt = 0;
  var backoff = const Duration(seconds: 1);

  while (attempt < maxAttempts) {
    attempt++;
    final completer = waitFor();
    try {
      await send();
      await completer.future.timeout(attemptTimeout);
      return; // confirmed
    } on TimeoutException {
      // retry
    } catch (_) {
      // send failed — retry
    }
    if (attempt < maxAttempts) {
      await Future.delayed(backoff);
      backoff *= 2;
    }
  }

  throw StateError('$failureMessage after $maxAttempts attempts.');
}

Future<void> _sendDhPayload({
  required String contactId,
  required String contactUserName,
  required String serverId,
  required Uint8List ephemeralPublicKey,
  required Uint8List signature,
}) async {
  final payload = jsonEncode({
    'kind': 'dh_exchange',
    'ephemeral_public_key': base64UrlEncode(ephemeralPublicKey),
    'signature': base64UrlEncode(signature),
  });

  final service = SendMessageService(serverId: serverId);
  await service.sendMessage(
    recipientIds: [
      MessageRecipient(userId: contactId, userName: contactUserName),
    ],
    messageId: _uuid.v4(),
    logicalId: _uuid.v4(),
    conversationId: contactId,
    messageType: 0,
    // DH public keys aren't confidential on their own — only authenticity
    // matters, which the signature provides — so this payload is sent
    // as plaintext JSON, not further encrypted.
    message: payload,
    messageOrder: 0,
    nonce: 'none',
    senderSequence: 0,
  );
}

Future<void> _sendOknullConfirmation({
  required String contactId,
  required String contactUserName,
  required String serverId,
  required Uint8List symmetricKeyBytes,
}) async {
  final aesGcm = AesGcm.with256bits();
  final secretKey = SecretKey(symmetricKeyBytes);
  final secretBox = await aesGcm.encrypt(
    utf8.encode('oknull'),
    secretKey: secretKey,
  );

  final payload = jsonEncode({
    'kind': 'confirmation',
    'nonce': base64UrlEncode(secretBox.nonce),
    'ciphertext': base64UrlEncode(secretBox.cipherText),
    'mac': base64UrlEncode(secretBox.mac.bytes),
  });

  final service = SendMessageService(serverId: serverId);
  await service.sendMessage(
    recipientIds: [
      MessageRecipient(userId: contactId, userName: contactUserName),
    ],
    messageId: _uuid.v4(),
    logicalId: _uuid.v4(),
    conversationId: contactId,
    messageType: 0,
    message: payload,
    messageOrder: 0,
    nonce: 'none',
    senderSequence: 0,
  );
}