In this, the user sends a message with message type of 0. This is where the conversation starts and is created in the database. but that first message is not recorded as a message since it is just sending the public keys for the difiehelmen to make the symetric keys at both sides. Then to ensure that both sides actually got the correct symmetric key they should send the word "oknull" if both sides can see this message when decrypted then the ratchet wheel should begin with the first message which sends an empty message with message type of 1. then now you add it to the database as a message.


All the modules you would need to call

For the encryption of the message 0 and 1 you would need the public key in the contact of the user


import 'package:drift/drift.dart';
import 'dart:typed_data'; // for Uint8List

import '../tables/contacts.dart';

part 'contacts_queries.g.dart';

/// Data Access Object for the `Contacts` table.
@DriftAccessor(tables: [Contacts])
class ContactsDao extends DatabaseAccessor<AppDatabase>
    with _$ContactsDaoMixin {
  ContactsDao(super.db);

  // Get a single contact by ID.
  Future<Contacts?> getContactById(String id) => (select(
    db.contacts,
  )..where((t) => t.contactId.equals(id))).getSingleOrNull();

  // Get all contacts.
  Future<List<Contacts>> getAllContacts() => select(db.contacts).get();

  // Get contacts by connection status (1=Pending, 2=Connected, etc.).
  Future<List<Contacts>> getContactsByStatus(int status) => (select(
    db.contacts,
  )..where((t) => t.connectionStatus.equals(status))).get();

  // Get only connected contacts (status = 2).
  Future<List<Contacts>> getConnectedContacts() => getContactsByStatus(2);

  // Get contacts that are online and connected.
  Future<List<Contacts>> getOnlineConnectedContacts() => (select(
    db.contacts,
  )..where((t) => t.connectionStatus.equals(2) & t.isOnline.equals(1))).get();

  // Get a contact by its linked conversation ID.
  Future<Contacts?> getContactByConversationId(String conversationId) =>
      (select(db.contacts)
            ..where((t) => t.conversationId.equals(conversationId)))
          .getSingleOrNull();

  // Insert a new contact.
  Future<int> insertContact(Insertable<Contacts> contact) =>
      into(db.contacts).insert(contact);

  // Upsert (insert or update) a contact.
  Future<void> upsertContact(Contacts contact) =>
      into(db.contacts).insertOnConflictUpdate(contact);

  // Update an existing contact row.
  Future<bool> updateContact(Contacts contact) =>
      update(db.contacts).replace(contact);

  // Delete a contact by ID.
  Future<int> deleteContact(String id) =>
      (delete(db.contacts)..where((t) => t.contactId.equals(id))).go();

  // Update the online status of a contact.
  Future<void> setOnlineStatus(String contactId, int isOnline) async {
    await (update(db.contacts)..where((t) => t.contactId.equals(contactId)))
        .write(ContactsCompanion(isOnline: Value(isOnline)));
  }

  // Update the last seen timestamp of a contact.
  Future<void> updateLastSeen(String contactId, int timestamp) async {
    await (update(db.contacts)..where((t) => t.contactId.equals(contactId)))
        .write(ContactsCompanion(lastSeen: Value(timestamp)));
  }

  // Update the public key for a contact.
  Future<void> setPublicKey(String contactId, String? publicKey) async {
    await (update(db.contacts)..where((t) => t.contactId.equals(contactId)))
        .write(ContactsCompanion(publicKey: Value(publicKey)));
  }

  // Toggle the mute flag for a contact.
  Future<void> setMuted(String contactId, int muted) async {
    await (update(db.contacts)..where((t) => t.contactId.equals(contactId)))
        .write(ContactsCompanion(muted: Value(muted)));
  }

  // Toggle the pinned flag for a contact.
  Future<void> setPinned(String contactId, int pinned) async {
    await (update(db.contacts)..where((t) => t.contactId.equals(contactId)))
        .write(ContactsCompanion(pinned: Value(pinned)));
  }

  // Update the connection status (e.g., after accept/block/delete).
  Future<void> setConnectionStatus(String contactId, int status) async {
    await (update(db.contacts)..where((t) => t.contactId.equals(contactId)))
        .write(ContactsCompanion(connectionStatus: Value(status)));
  }

  // Link or update the conversation ID for a contact.
  Future<void> setConversationId(
    String contactId,
    String? conversationId,
  ) async {
    await (update(db.contacts)..where((t) => t.contactId.equals(contactId)))
        .write(ContactsCompanion(conversationId: Value(conversationId)));
  }

  // NEW: Update the avatar (binary image data) for a contact.
  Future<void> updateAvatar(String contactId, Uint8List? avatar) async {
    await (update(db.contacts)..where((t) => t.contactId.equals(contactId)))
        .write(ContactsCompanion(avatar: Value(avatar)));
  }

  // NEW: Retrieve contacts that have a non‑null avatar.
  Future<List<Contacts>> getContactsWithAvatar() => (select(db.contacts)
        ..where((t) => t.avatar.isNotNull()))
      .get();
}


For the asymetric key locking use the module:
// module name: encryption

import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

/// Asymmetric ("sealed box" style) encryption using X25519 + AES-GCM.
///
/// This encrypts [plaintext] so that only the holder of the private key
/// matching [publicKey] can decrypt it — the sender doesn't need a
/// keypair of their own, since a fresh ephemeral keypair is generated
/// per message (this mirrors libsodium's crypto_box_seal / NaCl sealed
/// box pattern):
///
///   1. Generate a fresh ephemeral X25519 keypair for this message only.
///   2. Do an X25519 key exchange between the ephemeral private key and
///      the recipient's public key to get a shared secret.
///   3. Use that shared secret as an AES-256-GCM key to encrypt the
///      plaintext, with a random 12-byte nonce.
///   4. Package [ephemeral public key | nonce | ciphertext | MAC] together
///      and Base64-encode it as the single output string.
///
/// [publicKey] must be the recipient's X25519 public key, Base64-encoded
/// (32 raw bytes before encoding) — matching the format your app already
/// uses for stored public keys.
///
/// Returns a single Base64 string containing everything needed to
/// decrypt on the recipient's side, safe to drop straight into the
/// `message` field of SendMessageService.sendMessage.
Future<String> encryptMessage({
  required String publicKey,
  required String plaintext,
}) async {
  final x25519 = X25519();
  final aesGcm = AesGcm.with256bits();

  // 1. Ephemeral keypair, unique to this message.
  final ephemeralKeyPair = await x25519.newKeyPair();
  final ephemeralPublicKey = await ephemeralKeyPair.extractPublicKey();

  // 2. Recipient's public key, from the Base64 string passed in.
  final recipientPublicKeyBytes = base64Decode(publicKey);
  if (recipientPublicKeyBytes.length != 32) {
    throw FormatException('Recipient public key must be 32 bytes.');
  }
  final recipientPublicKey = SimplePublicKey(
    recipientPublicKeyBytes,
    type: KeyPairType.x25519,
  );

  // 3. ECDH shared secret -> AES-256-GCM key.
  final sharedSecret = await x25519.sharedSecretKey(
    keyPair: ephemeralKeyPair,
    remotePublicKey: recipientPublicKey,
  );

  // 4. Encrypt the plaintext.
  final plaintextBytes = utf8.encode(plaintext);
  final secretBox = await aesGcm.encrypt(
    plaintextBytes,
    secretKey: sharedSecret,
  );

  // 5. Package everything the recipient needs: ephemeral pub key + nonce +
  // ciphertext + MAC, all concatenated then Base64-encoded as one string.
  final ephemeralPublicKeyBytes = ephemeralPublicKey.bytes;
  final packed = BytesBuilder()
    ..add(ephemeralPublicKeyBytes) // 32 bytes
    ..add(secretBox.nonce) // 12 bytes
    ..add(secretBox.cipherText) // variable length
    ..add(secretBox.mac.bytes); // 16 bytes

  return base64Encode(packed.toBytes());
}

/// The matching decrypt function, for reference / for whoever implements
/// the receiving side. Requires the recipient's own X25519 KeyPair (the
/// private key matching the publicKey that was encrypted to).
Future<String> decryptMessage({
  required SimpleKeyPair recipientKeyPair,
  required String packedMessage,
}) async {
  final x25519 = X25519();
  final aesGcm = AesGcm.with256bits();

  final packed = base64Decode(packedMessage);

  const pubKeyLen = 32;
  const nonceLen = 12;
  const macLen = 16;

  if (packed.length < pubKeyLen + nonceLen + macLen) {
    throw FormatException('Encrypted message is malformed or truncated.');
  }

  final ephemeralPublicKeyBytes = packed.sublist(0, pubKeyLen);
  final nonce = packed.sublist(pubKeyLen, pubKeyLen + nonceLen);
  final cipherText = packed.sublist(
    pubKeyLen + nonceLen,
    packed.length - macLen,
  );
  final macBytes = packed.sublist(packed.length - macLen);

  final ephemeralPublicKey = SimplePublicKey(
    ephemeralPublicKeyBytes,
    type: KeyPairType.x25519,
  );

  final sharedSecret = await x25519.sharedSecretKey(
    keyPair: recipientKeyPair,
    remotePublicKey: ephemeralPublicKey,
  );

  final secretBox = SecretBox(
    cipherText,
    nonce: nonce,
    mac: Mac(macBytes),
  );

  final plaintextBytes = await aesGcm.decrypt(
    secretBox,
    secretKey: sharedSecret,
  );

  return utf8.decode(plaintextBytes);
}

Sending the message: import 'package:dio/dio.dart';

import '../api_client.dart';

/// Represents a single recipient in the "recipient_ids" list.
class MessageRecipient {
  final String userId;
  final String userName;

  MessageRecipient({
    required this.userId,
    required this.userName,
  });

  factory MessageRecipient.fromJson(Map<String, dynamic> json) {
    return MessageRecipient(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
    };
  }
}

/// Represents the response of POST /api/message
class SendMessageResponse {
  final int messageSent;

  SendMessageResponse({required this.messageSent});

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      messageSent: json['message_sent'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_sent': messageSent,
    };
  }

  /// `message_sent` is a Unix timestamp (seconds) of when the server
  /// accepted the message.
  DateTime get messageSentDate =>
      DateTime.fromMillisecondsSinceEpoch(messageSent * 1000);

  @override
  String toString() => 'SendMessageResponse(messageSentDate: $messageSentDate)';
}

class SendMessageService {
  final String serverId;

  Dio get _dio => ApiClient.instance(serverId);

  const SendMessageService({required this.serverId});

  /// Sends a message to one or more recipients within a conversation.
  ///
  /// Auth (Bearer access token) and refresh-on-401 are handled automatically
  /// by ApiClient's interceptors.
  Future<SendMessageResponse> sendMessage({
    required List<MessageRecipient> recipientIds,
    required String messageId,
    required String logicalId,
    required String conversationId,
    required int messageType,
    required String message,
    required int messageOrder,
    required String nonce,
    required int senderSequence,
  }) async {
    final response = await _dio.post(
      '/api/message',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'recipient_ids': recipientIds.map((r) => r.toJson()).toList(),
        'messageId': messageId,
        'logicalId': logicalId,
        'conversationId': conversationId,
        'messageType': messageType,
        'message': message,
        'messageOrder': messageOrder,
        'nonce': nonce,
        'senderSequence': senderSequence,
      },
    );

    return SendMessageResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}

Note that message order is 0 nonce is "none"
sendersequence is 0 
make the message d and logical id and messge order is 0 but the recipient id is that of the user 
Now ensure you create the conversation in the db using:

import 'package:drift/drift.dart';
import '../tables/conversations.dart';

part 'conversations_queries.g.dart';

/// Data Access Object for the `Conversations` table.
@DriftAccessor(tables: [Conversations])
class ConversationsDao extends DatabaseAccessor<AppDatabase>
    with _$ConversationsDaoMixin {
  ConversationsDao(super.db);

  // Get a single conversation by ID.
  Future<Conversations?> getConversationById(String id) =>
      (select(db.conversations)..where((t) => t.conversationId.equals(id)))
          .getSingleOrNull();

  // Get all conversations (optionally filter by archived/pinned later).
  Future<List<Conversations>> getAllConversations() =>
      select(db.conversations).get();

  // Get conversations ordered by last message time (descending).
  Future<List<Conversations>> getConversationsByLastMessage() =>
      (select(db.conversations)..orderBy([
        (t) => OrderingTerm(expression: t.lastMessageTime, mode: OrderingMode.desc),
      ])).get();

  // Insert a new conversation.
  Future<int> insertConversation(Insertable<Conversations> conversation) =>
      into(db.conversations).insert(conversation);

  // Upsert (insert or update) a conversation.
  Future<void> upsertConversation(Conversations conversation) =>
      into(db.conversations).insertOnConflictUpdate(conversation);

  // Update an existing conversation.
  Future<bool> updateConversation(Conversations conversation) =>
      update(db.conversations).replace(conversation);

  // Delete a conversation.
  Future<int> deleteConversation(String id) =>
      (delete(db.conversations)..where((t) => t.conversationId.equals(id))).go();

  // Update the draft text for a conversation.
  Future<void> updateDraft(String conversationId, String? draft) async {
    await (update(db.conversations)
          ..where((t) => t.conversationId.equals(conversationId)))
        .write(ConversationsCompanion(draft: Value(draft)));
  }

  // Increment the unread count by a given delta (can be negative).
  Future<void> incrementUnread(String conversationId, int delta) async {
    final conversation = await getConversationById(conversationId);
    if (conversation != null) {
      final newCount = conversation.unreadCount + delta;
      await (update(db.conversations)
            ..where((t) => t.conversationId.equals(conversationId)))
          .write(ConversationsCompanion(unreadCount: Value(newCount)));
    }
  }

  // Set the badge state (0 = not processed, 1 = processed, 2 = hide).
  Future<void> setBadge(String conversationId, int badge) async {
    await (update(db.conversations)
          ..where((t) => t.conversationId.equals(conversationId)))
        .write(ConversationsCompanion(badge: Value(badge)));
  }
}


Now to save the message to the db: 

import 'package:drift/drift.dart';

import '../tables/messages.dart';

part 'messages_queries.g.dart';

/// Data Access Object for the `Messages` table.
@DriftAccessor(tables: [Messages])
class MessagesDao extends DatabaseAccessor<AppDatabase>
    with _$MessagesDaoMixin {
  MessagesDao(super.db);

  // Get a single message by its ID.
  Future<Messages?> getMessageById(String id) => (select(
    db.messages,
  )..where((t) => t.messageId.equals(id))).getSingleOrNull();

  // Get all messages in a conversation, ordered by message_order.
  Future<List<Messages>> getMessagesForConversation(String conversationId) =>
      (select(db.messages)
            ..where((t) => t.conversationId.equals(conversationId))
            ..orderBy([(t) => OrderingTerm(expression: t.messageOrder)]))
          .get();

  // Get messages for a conversation with pagination.
  Future<List<Messages>> getMessagesForConversationPaginated(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  }) =>
      (select(db.messages)
            ..where((t) => t.conversationId.equals(conversationId))
            ..orderBy([(t) => OrderingTerm(expression: t.messageOrder)])
            ..limit(limit, offset: offset))
          .get();

  // Insert a new message.
  Future<int> insertMessage(Insertable<Messages> message) =>
      into(db.messages).insert(message);

  // Insert multiple messages in a batch (atomic).
  Future<void> insertMessages(List<Insertable<Messages>> messages) =>
      batch((batch) {
        batch.insertAll(db.messages, messages);
      });

  // Update an existing message row.
  Future<bool> updateMessage(Messages message) =>
      update(db.messages).replace(message);

  // Update only the status of a message.
  Future<void> updateMessageStatus(String messageId, int newStatus) async {
    await (update(db.messages)..where((t) => t.messageId.equals(messageId)))
        .write(MessagesCompanion(status: Value(newStatus)));
  }

  // Delete a message by ID.
  Future<int> deleteMessage(String id) =>
      (delete(db.messages)..where((t) => t.messageId.equals(id))).go();

  // Get the latest message in a conversation (ordered by message_order desc).
  Future<Messages?> getLatestMessage(String conversationId) =>
      (select(db.messages)
            ..where((t) => t.conversationId.equals(conversationId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.messageOrder,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(1))
          .getSingleOrNull();

  // Find messages with a specific status (useful for sync).
  Future<List<Messages>> getMessagesByStatus(
    String conversationId,
    int status,
  ) =>
      (select(db.messages)
            ..where(
              (t) =>
                  t.conversationId.equals(conversationId) &
                  t.status.equals(status),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.messageOrder)]))
          .get();
}


For the empty message use the following structure:
TextColumn get messageId => text()();
  TextColumn get logicalMessageId => text()();

  // Foreign key to Conversations with cascade delete.
  TextColumn get conversationId => text().references(
    Conversations,
    #conversationId,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get senderId => text()();

  IntColumn get senderSequence => integer()();
  IntColumn get messageOrder => integer()();
  IntColumn get chainIndex => integer()();

  // Column name `_timestamp` (reserved in Dart, so we use `timestamp` getter).
  IntColumn get timestamp => integer().named('_timestamp')();

  BlobColumn get ciphertext => blob()();
  BlobColumn get nonce => blob()();

  IntColumn get messageType => integer()();

  // Column name `_status`.
  IntColumn get status => integer().named('_status')();
  BlobColumn get mac => blob()();

  IntColumn get keyVersion => integer()();

  TextColumn get replyTo => text().nullable()();

  IntColumn get edited =>
      integer().withDefault(const Constant(0)).check(edited.isIn([0, 1]))();

  IntColumn get protocolVersion => integer().withDefault(const Constant(1))();

  IntColumn get receivedAt => integer().nullable()();
  IntColumn get readAt => integer().nullable()();
