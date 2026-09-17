// module name: send_contact_details

import 'dart:async';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../crypto/chat/conversation_key_store.dart';
import '../../crypto/chat/crypto_types.dart';
import '../../crypto/chat/identity_crypto.dart';
import '../../crypto/chat/null_crypto.dart';
import '../../crypto/chat/ratchet_store.dart';
import '../../crypto/chat/symmetric_ratchet.dart';
import '../../crypto/chat/asymetric_encryption.dart';
import '../../database/app_database.dart';
import '../../database/queries/identity_queries.dart';
import '../../database/queries/contacts_queries.dart';
import '../../network/people/recieve_contact.dart';
import '../../network/server_error_exception.dart';
import '../../network/people/share_contact.dart';
import '../../task_queue.dart';
import '../../network/chats/send_message.dart';

const _uuid = Uuid();

class SendMyContactResult {
  final String displayQRSVG;
  final String manualCode;
  final String shareQRSVG;

  const SendMyContactResult({
    required this.displayQRSVG,
    required this.manualCode,
    required this.shareQRSVG,
  });
}

/// Process-memory cache for the active contact invite.
final Map<String, Map<String, dynamic>> temporaryContact = {};

/// Shares this identity and returns the invite as soon as the server creates it.
///
/// Completing the peer-side exchange happens in the background so a contact
/// that has not been claimed yet cannot block the share UI.
Future<SendMyContactResult> sendMyContact({
  required AppDatabase database,
  required TaskQueue taskQueue,
  required String mainServerId,
  Duration receiveDelay = const Duration(seconds: 2),
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

  final nameParts = identity.displayName.split(' - ');
  final nickname = nameParts.first.trim();
  final title = nameParts.length > 1
      ? nameParts.skip(1).join(' - ').trim()
      : '';

  final shared = await SendContactService(serverId: mainServerId).sendContact(
    nickname: nickname,
    title: title,
    bio: identity.bio ?? '',
    publicKey: publicKey,
    avatar: identity.avatar ?? '',
  );

  final secretKey = await AesGcm.with256bits().newSecretKey();
  final symmetricKey = Uint8List.fromList(await secretKey.extractBytes());
  final previewState = await SymmetricRatchet.initialize(
    sharedSecret: symmetricKey,
    initiator: true,
  );
  final temporary = <String, dynamic>{
    'contact_key': shared.contactKey,
    'symmetric_key': base64UrlEncode(symmetricKey),
    'ratchet_state': _ratchetStateJson(previewState),
  };
  temporaryContact['temporary contact'] = temporary;

  unawaited(
    _pollForReceivedContact(
      database: database,
      taskQueue: taskQueue,
      mainServerId: mainServerId,
      contactKey: '${shared.contactKey}R',
      symmetricKey: symmetricKey,
      previewState: previewState,
      firstDelay: receiveDelay,
    ),
  );

  return SendMyContactResult(
    displayQRSVG: jsonEncode(temporary),
    manualCode: shared.contactKey,
    shareQRSVG: shared.url,
  );
}

Future<void> _pollForReceivedContact({
  required AppDatabase database,
  required TaskQueue taskQueue,
  required String mainServerId,
  required String contactKey,
  required Uint8List symmetricKey,
  required RatchetState previewState,
  required Duration firstDelay,
}) async {
  const retryDelays = [
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 16),
    Duration(seconds: 25),
    Duration(seconds: 30),
  ];

  try {
    final delays = [firstDelay, ...retryDelays];
    ContactInfo? received;

    for (final delay in delays) {
      await Future<void>.delayed(delay);
      try {
        received = await GetContactService(serverId: mainServerId)
            .getContact(contactKey: contactKey);
        break;
      } on ServerErrorException catch (error) {
        if (error.statusCode != 404) rethrow;
      }
    }

    if (received == null) return;

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
    await database.sessionsDao.establishWithSymmetricKey(
      conversationId: conversationId,
      symmetricKey: symmetricKey,
    );

    final crypto = NullCrypto(
      identity: const IdentityCrypto(),
      ratchetStore: const RatchetStore(),
    );
    await crypto.establishConversation(
      conversationId: conversationId,
      sharedSecret: symmetricKey,
      initiator: true,
    );
    await const ConversationKeyStore().saveRootKey(
      conversationId,
      previewState.rootKey,
    );
    await const ConversationKeyStore().saveRatchetState(
      conversationId,
      previewState,
    );

    await taskQueue.queueTask(
      functionName: 'sendChatMessage',
      args: [conversationId, 'hi', mainServerId, _uuid.v4(), _uuid.v4()],
      serverId: mainServerId,
    );
  } catch (_) {
    // Background completion must never surface an error over the share UI.
  }
}

Map<String, dynamic> _ratchetStateJson(RatchetState state) => {
  'root': base64UrlEncode(state.rootKey),
  'send': base64UrlEncode(state.sendingChainKey),
  'receive': base64UrlEncode(state.receivingChainKey),
  'sendIndex': state.sendingIndex,
  'receiveIndex': state.receivingIndex,
};

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
