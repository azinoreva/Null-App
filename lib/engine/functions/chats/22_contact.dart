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
/// it as a contact — including the contact's public key, which is
/// supplied separately (from the invite/exchange step) since it isn't
/// part of the identity-card JSON itself.
Future<void> receiveContactDetails(
  ContactsDao contactsDao, {
  required String encryptedMessage,
  required SimpleKeyPair privateKeyPair,
  required String contactPublicKey,
}) async {
  final decryptedJson = await decryptMessage(
    recipientKeyPair: privateKeyPair,
    packedMessage: encryptedMessage,
  );

  final Map<String, dynamic> identityCard =
      jsonDecode(decryptedJson) as Map<String, dynamic>;

  final contactId = identityCard['contact_id'] as String;
  final nickname = identityCard['nickname'] as String?;
  final bio = identityCard['bio'] as String?;
  final avatarBase64 = identityCard['avatar'] as String?;
  final serverId = identityCard['server_id'] as String;

  Uint8List? avatarBlob;
  if (avatarBase64 != null) {
    avatarBlob = base64ToBlob(avatarBase64);
  }

  final now = DateTime.now().millisecondsSinceEpoch;

  final companion = ContactsCompanion.insert(
    contactId: contactId,
    nickname: Value(nickname),
    avatar: Value(avatarBlob),
    bio: Value(bio),
    publicKey: Value(contactPublicKey),
    serverId: serverId,
    connectionStatus: 1, // pending
    createdAt: now,
    updatedAt: now,
    conversationId: Value(contactId),
  );

  await contactsDao.db
      .into(contactsDao.db.contacts)
      .insertOnConflictUpdate(companion);
}