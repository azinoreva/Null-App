// module name: receive_contact_details

import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';

import '../../database/queries/contacts_queries.dart';
import '../../crypto/chat/asymetric_encryption.dart'; // decryptMessage
import '../../image_handling/string_to_blob.dart';

/// Takes an incoming encrypted identity-card message, decrypts it with
/// the current user's private key, parses the resulting JSON, and saves
/// it as a contact.
///
/// Expects the decrypted JSON to have the shape:
///   {
///     "contact_id": "...",
///     "nickname": "...",
///     "bio": "...",
///     "avatar": "<base64>",
///     "public_key": "<base64url>",
///     "server_id": "..."
///   }
Future<void> receiveContactDetails(
  ContactsDao contactsDao, {
  required String encryptedMessage,
  required SimpleKeyPair privateKeyPair,
}) async {
  // 1. Decrypt using the private key.
  final decryptedJson = await decryptMessage(
    recipientKeyPair: privateKeyPair,
    packedMessage: encryptedMessage,
  );

  // 2. Parse the decrypted string into JSON.
  final Map<String, dynamic> identityCard =
      jsonDecode(decryptedJson) as Map<String, dynamic>;

  final contactId = identityCard['contact_id'] as String;
  final nickname = identityCard['nickname'] as String?;
  final bio = identityCard['bio'] as String?;
  final avatarBase64 = identityCard['avatar'] as String?;
  final publicKey = identityCard['public_key'] as String?;
  final serverId = identityCard['server_id'] as String;

  Uint8List? avatarBlob;
  if (avatarBase64 != null) {
    avatarBlob = base64ToBlob(avatarBase64);
  }

  final now = DateTime.now().millisecondsSinceEpoch;

  // 3. Add it to the contacts database.
  final companion = ContactsCompanion.insert(
    contactId: contactId,
    nickname: Value(nickname),
    avatar: Value(avatarBlob),
    bio: Value(bio),
    publicKey: Value(publicKey),
    serverId: serverId,
    connectionStatus: 1, // pending, matching the convention used earlier
    createdAt: now,
    updatedAt: now,
    conversationId: Value(contactId), // conversationId == contact_id
  );

  await contactsDao.db
      .into(contactsDao.db.contacts)
      .insertOnConflictUpdate(companion);
}