// module name: send_contact_details

import 'dart:convert';
import 'package:uuid/uuid.dart';

import '../../database/queries/identity_queries.dart';
import '../../database/queries/contacts_queries.dart';
import '../../network/chats/send_message.dart'; // SendMessageService, MessageRecipient, SendMessageResponse
import '../../crypto/chat/asymetric_encryption.dart';

const _uuid = Uuid();

/// Sends the current user's contact details (identity card) to another
/// user over the encrypted messaging protocol.
///
/// [recipientUserId] is who the identity card is being sent to.
/// [serverId] selects which server's ApiClient/SendMessageService to use.
Future<SendMessageResponse> sendContactDetails(
  IdentityDao identityDao,
  ContactsDao contactsDao, {
  required String recipientUserId,
  required String serverId,
}) async {
  final identity = await identityDao.getCurrentIdentityOrNull();
  if (identity == null) {
    throw StateError('No local identity found — cannot send contact details.');
  }

  final publicKey = identity.publicKey;
  if (publicKey == null) {
    throw StateError('Current identity has no public key set.');
  }

  // Build the identity card exactly as specified, then flatten to a JSON string.
  final identityCard = {
    'contact_id': identity.identityId,
    'nickname': identity.displayName,
    'bio': identity.bio,
    'avatar': identity.avatar, // assumed already stored as a base64 string
    'public_key': publicKey,
    'server_id': serverId,
  };
  final identityCardJson = jsonEncode(identityCard);

  // Encrypt the flattened identity card using the public key.
  final encryptedMessage = await encryptMessage(
    publicKey: publicKey,
    plaintext: identityCardJson,
  );

  // Look up a display name for the recipient, if we already know them
  // locally (falls back to the raw user id if not).
  final recipientContact = await contactsDao.getContactById(recipientUserId);
  final recipientUserName = recipientContact?.nickname ?? recipientUserId;

  final service = SendMessageService(serverId: serverId);

  final result = await service.sendMessage(
    recipientIds: [
      MessageRecipient(
        userId: recipientUserId,
        userName: recipientUserName,
      ),
    ],
    messageId: _uuid.v4(),
    logicalId: _uuid.v4(),
    conversationId: recipientUserId,
    messageType: 22, // vcard
    message: encryptedMessage,
    messageOrder: 0,
    nonce: 'none',
    senderSequence: 0,
  );

  return result;
}

// module name: send_contact_details (updated sendContactDetailsBack)

/// Completes the mutual-exchange handshake: sends OUR identity card back
/// to a contact, encrypted with THEIR public key — read from the
/// Contacts table (set previously by receiveContactDetails), not passed
/// in by the caller anymore.
Future<SendMessageResponse> sendContactDetailsBack(
  IdentityDao identityDao,
  ContactsDao contactsDao, {
  required String recipientUserId,
  required String serverId,
}) async {
  final identity = await identityDao.getCurrentIdentityOrNull();
  if (identity == null) {
    throw StateError('No local identity found — cannot send contact details.');
  }

  final recipientContact = await contactsDao.getContactById(recipientUserId);
  if (recipientContact == null) {
    throw StateError('Contact $recipientUserId not found locally.');
  }

  final contactPublicKey = recipientContact.publicKey;
  if (contactPublicKey == null) {
    throw StateError('Contact $recipientUserId has no public key on file.');
  }

  final identityCard = {
    'contact_id': identity.identityId,
    'nickname': identity.displayName,
    'bio': identity.bio,
    'avatar': identity.avatar,
    'server_id': serverId,
  };
  final identityCardJson = jsonEncode(identityCard);

  final encryptedMessage = await encryptMessage(
    publicKey: contactPublicKey,
    plaintext: identityCardJson,
  );

  final recipientUserName = recipientContact.nickname ?? recipientUserId;

  final service = SendMessageService(serverId: serverId);

  return service.sendMessage(
    recipientIds: [
      MessageRecipient(userId: recipientUserId, userName: recipientUserName),
    ],
    messageId: _uuid.v4(),
    logicalId: _uuid.v4(),
    conversationId: recipientUserId,
    messageType: 22, // vcard
    message: encryptedMessage,
    messageOrder: 0,
    nonce: 'none',
    senderSequence: 0,
  );
}