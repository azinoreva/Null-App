// module name: dh_drop_flow
//
// Diffie-Hellman key delivery through the main server's "dh-drop" inbox,
// replacing the retired message-type-0 signature handshake:
//
//   1. When a contact is received, seal our fresh ephemeral X25519 public
//      key to the contact's long-term X25519 public key and POST it to
//      /api/dh-drop (recipient_id = the contact's user id).
//   2. After a short wait, /api/check_dh_drops pulls whatever
//      the contact sealed back to us (their own ephemeral public key).
//      That endpoint atomically fetches-and-clears the inbox, so each drop
//      is delivered exactly once.
//   3. Either way, both sides end up able to derive the same symmetric
//      session key via X25519(ourEphemeralPrivate, theirEphemeralPublic),
//      initialize the message ratchet with a deterministic initiator, and
//      send messages. The first "hi" is queued through the durable task
//      queue via [appTaskQueueRef].
//
// "When picking DH: check sender_id is a contact. If sent before, complete
// (symmetric key, conversation row, first message). If not sent before,
// make ours, drop, and complete immediately."
//
// Both devices run the same code, so the "who initializes the ratchet"
// question is answered deterministically instead of by a forwarder/follower
// split: the lexicographically smaller identity id initializes.

import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:uuid/uuid.dart';

import '../../app_queue.dart';
import '../../crypto/chat/asymetric_encryption.dart';
import '../../crypto/chat/dh_identity_crypto.dart';
import '../../crypto/chat/identity_crypto.dart';
import '../../crypto/chat/key_exchange.dart';
import '../../crypto/chat/null_crypto.dart';
import '../../crypto/chat/ratchet_store.dart';
import '../../database/app_database.dart';
import '../../network/main_server_client.dart';
import '../../network/people/drop_dh.dart';
import '../../network/people/pick_dh.dart';

const _uuid = Uuid();

/// How long to wait for the peer's drop to land before re-checking the
/// inbox inside [ensureDhDropForContact].
const Duration kDhDropPollInterval = Duration(seconds: 5);

/// How many inbox polls [ensureDhDropForContact] attempts before giving up
/// and letting a later app-open / contacts-screen check finish the job.
const int kDhDropPollAttempts = 5;

/// Task executor for `ensureDhFlow`. Runs right after a contact is
/// received: makes sure our ephemeral key is dropped to them, then polls
/// the inbox so a drop they made lands back and completes the session.
///
/// args: [contactId, serverId]
Future<void> runEnsureDhFlowTask(
  List<dynamic> args,
  AppDatabase database,
) async {
  final contactId = args[0] as String;
  final serverId = args[1] as String;
  await ensureDhDropForContact(
    database: database,
    contactId: contactId,
    serverId: serverId,
  );
}

/// Task executor for `checkDhDrops`: polls the inbox once and completes any
/// drops that arrived while away (app start / contacts screen).
///
/// args: []
Future<void> runCheckDhDropsTask(
  List<dynamic> args,
  AppDatabase database,
) async {
  // Complete the queued poll once auth expiry has cleared the token.
  if (await MainServerClient.getAccessToken() == null) return;
  await checkPendingDhDrops(database: database);
}

/// Ensures a pending DH drop exists toward [contactId]: creates an ephemeral
/// keypair (or reuses the stored one), drops it, then polls the inbox for the
/// contact's drop so both sides can complete. No-op once established.
Future<void> ensureDhDropForContact({
  required AppDatabase database,
  required String contactId,
  required String serverId,
}) async {
  final contact = await database.contactsDao.getContactById(contactId);
  if (contact == null || contact.publicKey == null || contact.publicKey!.isEmpty) {
    throw StateError('Contact $contactId has no public key on file.');
  }
  await _ensureConversation(database, contactId, serverId);

  final session = await database.sessionsDao.getSessionByConversationId(
    contactId,
  );
  if (session?.status == 2) return;

  if (session == null || session.ephemeralPrivateKey == null) {
    final ephemeral = await KeyExchange.generateEphemeralKeyPair();
    await database.sessionsDao.startPendingSession(
      conversationId: contactId,
      ephemeralPrivateKey: ephemeral.privateKey,
      ephemeralPublicKey: ephemeral.publicKey,
    );
  }

  await _dropForContact(database, contact);

  // Poll the inbox a few times so a slow peer's drop gets caught without
  // hanging a background task forever. Stops as soon as the session
  // completes (either side may complete it depending on drop order).
  for (var attempt = 0; attempt < kDhDropPollAttempts; attempt++) {
    if (await _isEstablished(database, contactId)) return;
    await checkPendingDhDrops(database: database);
    if (await _isEstablished(database, contactId)) return;
    if (attempt < kDhDropPollAttempts - 1) {
      await Future<void>.delayed(kDhDropPollInterval);
    }
  }
}

/// Polls /api/check_dh_drops (atomic fetch-and-clear) and lets
/// every drop from a known contact complete its session — dropping ours back
/// first when we haven't done so.
Future<void> checkPendingDhDrops({required AppDatabase database}) async {
  final identity = await database.identityDao.getCurrentIdentityOrNull();
  if (identity == null) return;
  if (await MainServerClient.getAccessToken() == null) return;

  // Unsealing drops needs our X25519 identity key — ensure it exists before
  // consuming the inbox (check_dh_drops clears it server-side).
  await DhIdentityCrypto.ensurePrivateKey();

  final drops = await const CheckDhDropsService().checkDhDrops();
  for (final drop in drops) {
    try {
      await _processDrop(database, drop);
    } catch (_) {
      // A drop we can't make sense of (stale, or sealed before the X25519
      // identity migration) must not fail the whole check.
    }
  }
}

Future<bool> _isEstablished(AppDatabase database, String conversationId) async {
  final session = await database.sessionsDao.getSessionByConversationId(
    conversationId,
  );
  return session?.status == 2;
}

/// Completes the DH for a single incoming [drop]: unseals the peer's
/// ephemeral public key, optionally drops ours back (when we haven't
/// dropped to this contact yet), derives the symmetric key, initializes the
/// ratchet, and queues the first message.
Future<void> _processDrop(AppDatabase database, DhDrop drop) async {
  final contactId = drop.senderId;
  final contact = await database.contactsDao.getContactById(contactId);
  if (contact == null) return; // not a known contact — ignore
  if (contact.publicKey == null || contact.publicKey!.isEmpty) return;

  final session = await database.sessionsDao.getSessionByConversationId(
    contactId,
  );
  if (session?.status == 2) return; // already established

  await _ensureConversation(
    database,
    contactId,
    contact.serverId,
  );

  // Our own ephemeral private key: either already stored (we dropped first)
  // or freshly made + dropped now ("not sent before").
  if (session == null || session.ephemeralPrivateKey == null) {
    final ephemeral = await KeyExchange.generateEphemeralKeyPair();
    await database.sessionsDao.startPendingSession(
      conversationId: contactId,
      ephemeralPrivateKey: ephemeral.privateKey,
      ephemeralPublicKey: ephemeral.publicKey,
    );
  }
  await _dropForContact(database, contact);

  final stored = await database.sessionsDao.getSessionByConversationId(
    contactId,
  );
  final localPrivateKey = stored?.ephemeralPrivateKey;
  if (localPrivateKey == null) return;

  final peerPublicKey = await _unsealEphemeralKey(
    sealed: drop.dhEncKey,
  );
  if (peerPublicKey == null) return;

  final sharedSecret = await KeyExchange.deriveSharedSecret(
    localPrivateKey: localPrivateKey,
    peerPublicKey: peerPublicKey,
  );

  await _completeDh(
    database: database,
    contactId: contactId,
    serverId: contact.serverId,
    sharedSecret: sharedSecret,
  );
}

/// Drops our stored ephemeral public key to [contact] unless we've already
/// dropped successfully (dropSent == 1).
Future<void> _dropForContact(AppDatabase database, Contact contact) async {
  final session = await database.sessionsDao.getSessionByConversationId(
    contact.contactId,
  );
  if (session == null || session.dropSent == 1) return;
  final ephemeralPublicKey = session.ephemeralPublicKey;
  final contactPublicKey = contact.publicKey;
  if (ephemeralPublicKey == null || contactPublicKey == null) return;

  await _dropEphemeralKeyTo(
    recipientId: contact.contactId,
    recipientPublicKey: contactPublicKey,
    ephemeralPublicKey: ephemeralPublicKey,
  );
  await database.sessionsDao.markDhDropped(contact.contactId);
}

/// Completes a DH exchange once both ephemeral keys are known: derives the
/// symmetric key, initializes the ratchet with a deterministic initiator,
/// marks the session established, and queues the first "hi" message.
Future<void> _completeDh({
  required AppDatabase database,
  required String contactId,
  required String serverId,
  required Uint8List sharedSecret,
}) async {
  await _ensureConversation(database, contactId, serverId);

  await database.sessionsDao.setSymmetricKey(
    conversationId: contactId,
    symmetricKey: sharedSecret,
  );

  // Deterministic ratchet initiator: the smaller identity id starts.
  final identity = await database.identityDao.getCurrentIdentityOrNull();
  final initiator = identity != null &&
      identity.identityId.compareTo(contactId) < 0;

  final crypto = NullCrypto(
    identity: const IdentityCrypto(),
    ratchetStore: const RatchetStore(),
  );
  await crypto.establishConversation(
    conversationId: contactId,
    sharedSecret: sharedSecret,
    initiator: initiator,
  );

  await database.sessionsDao.markEstablished(contactId);

  final taskQueue = appTaskQueueRef;
  if (taskQueue == null) return;
  await taskQueue.queueTask(
    functionName: 'sendChatMessage',
    args: [contactId, 'hi', serverId, _uuid.v4(), _uuid.v4()],
    serverId: serverId,
  );
}

/// Seals our ephemeral public key to the contact's long-term public key and
/// drops it into the contact's server-side inbox.
Future<void> _dropEphemeralKeyTo({
  required String recipientId,
  required String recipientPublicKey,
  required Uint8List ephemeralPublicKey,
}) async {
  final payload = jsonEncode({
    'v': 1,
    'e': base64UrlEncode(ephemeralPublicKey),
  });
  final sealed = await encryptMessage(
    publicKey: recipientPublicKey,
    plaintext: payload,
  );
  await const DhDropService().dhDrop(
    recipientId: recipientId,
    dhEncKey: sealed,
    dhEncNonce: _randomNonce(),
  );
}

/// Unseals a drop addressed to us, returning the sender's ephemeral public
/// key, or null when it wasn't sealed to our current X25519 identity key.
Future<Uint8List?> _unsealEphemeralKey({required String sealed}) async {
  final myDhPrivate = await DhIdentityCrypto.loadPrivateKey();
  final myDhPublic = await DhIdentityCrypto.derivePublicKey(myDhPrivate);
  final recipientPair = SimpleKeyPairData(
    myDhPrivate,
    publicKey: SimplePublicKey(myDhPublic, type: KeyPairType.x25519),
    type: KeyPairType.x25519,
  );

  final plaintext = await decryptMessage(
    recipientKeyPair: recipientPair,
    packedMessage: sealed,
  );
  final decoded = jsonDecode(plaintext) as Map<String, dynamic>;
  return Uint8List.fromList(base64Url.decode(decoded['e'] as String));
}

/// Creates the conversation row for [contactId] if it doesn't exist yet
/// (sessions reference conversations, so this must happen first).
Future<void> _ensureConversation(
  AppDatabase database,
  String contactId,
  String serverId,
) async {
  final existing = await database.conversationsDao.getConversationById(
    contactId,
  );
  if (existing != null) return;

  final now = DateTime.now().millisecondsSinceEpoch;
  await database.conversationsDao.upsertConversation(
    Conversation(
      conversationId: contactId,
      conversationType: 0,
      lastMessageId: null,
      lastMessageTime: null,
      unreadCount: 0,
      muted: 0,
      pinned: 0,
      archived: 0,
      draft: null,
      serverId: serverId,
      createdAt: now,
      updatedAt: now,
      sound: null,
      badge: 0,
      vibration: 0,
    ),
  );
}

String _randomNonce() {
  final random = math.Random.secure();
  final bytes = Uint8List.fromList(
    List<int>.generate(12, (_) => random.nextInt(256)),
  );
  return base64UrlEncode(bytes);
}