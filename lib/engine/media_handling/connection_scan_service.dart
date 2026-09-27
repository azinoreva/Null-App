// module name: receive_contact_details
//
// Mirrors send_contact_details.dart's `sendMyContact()` - this is the
// *answering* side of the same QR/PIN pairing handshake:
//
//   sendMyContact() (inviter)          receiveContact() (scanner, here)
//   -------------------------          ---------------------------------
//   publishes card under `contactKey`  fetches card from `contactKey`
//   polls for peer under `${key}R`     publishes own card under `${key}R`
//   ratchet initiator: true            ratchet initiator: false
//
// This file has two pieces:
//   - scanImageFile()   - pure pixels-to-string QR decoding (no domain
//                          logic; also used for the "Import Image" tab).
//   - receiveContact()  - the actual handshake: takes whatever string
//                          scanImageFile() (or the live camera / manual
//                          PIN field) produced and completes the pairing.
//
// A few calls below are my best guess at API surface I can't actually
// see (only send_contact_details.dart's *call sites* were shared, not
// the SendContactService/GetContactService class definitions). Each
// guess is marked with a TODO - please check them against the real
// service signatures before relying on this.

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mobile_scanner/mobile_scanner.dart' hide ContactInfo;

import '../database/app_database.dart';
import '../network/people/recieve_contact.dart';
import '../network/people/share_contact_rebound.dart';
import '../task_queue.dart';

/// What a successfully-completed scan pairing leaves you with.
class ReceiveContactResult {
  final String contactId;
  final String nickname;

  const ReceiveContactResult({required this.contactId, required this.nickname});
}

/// Decodes a QR code from a still image file (e.g. one picked from the
/// gallery). Returns the raw decoded value, or null if no QR code was
/// found in the image. Pass the result into [receiveContact] as
/// [scannedValue] - this function only decodes pixels to a string, it
/// doesn't know anything about contacts/handshakes.
Future<String?> scanImageFile(String imagePath) async {
  try {
    final capture = await MobileScannerController().analyzeImage(imagePath);
    if (capture == null || capture.barcodes.isEmpty) return null;
    return capture.barcodes.first.rawValue;
  } catch (e) {
    // TODO: surface a "couldn't read a QR code from that image" error
    // upstream instead of silently returning null.
    return null;
  }
}

/// Answers a QR/PIN invite that AddConnectionScreen just decoded.
///
/// Fetches the inviter's contact card, persists it locally, sets up the
/// encrypted session as the *responder* (mirroring sendMyContact's
/// initiator flow, but on the other side of it), and publishes our own
/// card back so the inviter's poll resolves and their side completes too.
///
/// [scannedValue] is whatever AddConnectionScreen produced - either a
/// bare manually-typed PIN (already a `contactKey`) or a scanned QR
/// payload that needs the key pulled out of it first.
Future<ReceiveContactResult> receiveContact({
  required AppDatabase database,
  required TaskQueue taskQueue,
  String mainServerId = 'server_1',
  required String scannedValue,
  bool isManualPin = false,
}) async {
  final identity = await database.identityDao.getCurrentIdentityOrNull();
  if (identity == null) {
    throw StateError('No local identity found. Please retry after signing in.');
  }

  final publicKey = identity.publicKey;
  if (publicKey == null || publicKey.isEmpty) {
    throw StateError(
      'Current identity has no public key. Please retry after identity setup.',
    );
  }

  final contactKey = _extractContactKey(scannedValue);

  final received = await GetContactService()
      .getContact(contactKey: contactKey);

  await _saveReceivedContact(database, received, localServerId: mainServerId);

  final conversationId = received.contactId;
  final now = DateTime.now().millisecondsSinceEpoch;
  await database.conversationsDao.upsertConversation(
    Conversation(
      conversationId: conversationId,
      conversationType: 0,
      lastMessageId: null,
      lastMessageTime: null,
      unreadCount: 0,
      muted: 0,
      pinned: 0,
      archived: 0,
      draft: null,
      serverId: mainServerId,
      createdAt: now,
      updatedAt: now,
      sound: null,
      badge: 0,
      vibration: 0,
    ),
  );

  final nameParts = identity.displayName.split(' - ');
  final nickname = nameParts.first.trim();
  final title = nameParts.length > 1
      ? nameParts.skip(1).join(' - ').trim()
      : '';

  await SendContactReboundService().sendContact(
    nickname: nickname,
    title: title,
    bio: identity.bio ?? '',
    publicKey: publicKey,
    avatar: identity.avatar ?? '',
    contactKey: '${contactKey}R',
  );

  // Encrypted messaging is established through the main-server DH-drop flow
  // (seal our ephemeral key to the contact's X25519 public key, drop it,
  // pick up theirs, ratchet up). No QR session-state pass-through anymore.
  await taskQueue.queueTask(
    functionName: 'ensureDhFlow',
    args: [received.contactId, mainServerId],
    serverId: mainServerId,
  );

  return ReceiveContactResult(
    contactId: received.contactId,
    nickname: received.nickname,
  );
}

/// Pulls the invite contact key out of a scanned value — a bare manual PIN
/// (already the key), a URL, or the old JSON QR payload.
String _extractContactKey(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      final key = decoded['contact_key'];
      if (key is String && key.isNotEmpty) return key;
    }
  } on FormatException {
    // The value may be a URL or a manual PIN.
  }

  final uri = Uri.tryParse(raw);
  if (uri != null && uri.pathSegments.isNotEmpty) {
    return uri.pathSegments.last;
  }
  return raw;
}

// Duplicated from send_contact_details.dart's private `_saveReceivedContact`
// (can't import a `_`-prefixed function across files in Dart). Consider
// pulling this out into a shared, public helper both modules call, so the
// two copies can't drift apart later.
Future<void> _saveReceivedContact(
  AppDatabase database,
  ContactInfo contact, {
  required String localServerId,
}) async {
  Uint8List? avatar;
  if (contact.avatar != null && contact.avatar!.isNotEmpty) {
    avatar = Uint8List.fromList(base64Decode(contact.avatar!));
  }
  await database.contactsDao.db
      .into(database.contactsDao.db.contacts)
      .insertOnConflictUpdate(
        ContactsCompanion.insert(
          contactId: contact.contactId,
          nickname: Value(contact.nickname),
          avatar: Value(avatar),
          bio: Value(contact.bio),
          publicKey: Value(contact.publicKey),
          connectionStatus: 1,
          serverId: localServerId,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          conversationId: Value(contact.contactId),
        ),
      );
}
