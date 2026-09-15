import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'crypto/chat/identity_crypto.dart';
import 'crypto/chat/null_crypto.dart';
import 'crypto/chat/ratchet_store.dart';
import 'database/app_database.dart';
import 'database/queries/connection_requests_queries.dart';
import 'database/queries/contacts_queries.dart';
import 'database/queries/conversations_queries.dart';
import 'database/queries/group_members_queries.dart';
import 'database/queries/groups_queries.dart';
import 'database/queries/identity_queries.dart';
import 'database/queries/messages_queries.dart';
import 'database/queries/network_queries.dart';
import 'database/queries/servers_queries.dart';
import 'database/queries/sessions_queries.dart';
import 'database/queries/tasks_queries.dart';
import 'engine.dart';
import 'task_queue.dart';
import 'network/servers/servers.dart';
import 'crypto/shamirs/vault_secrets.dart';
import 'functions/auth/loginfxn.dart' as auth_login;
import 'functions/auth/registerfxn.dart' as auth_register;
import 'functions/chats/01_send_message.dart' as chat_send;
import 'functions/chats/22_contact.dart' as chat_contact;
import 'functions/chats/conversation_function.dart' as conversation;
import 'functions/chats/handshake.dart' as handshake;
import 'functions/chats/recieve_handshake.dart' as handshake_receive;
import 'functions/chats/recieve_message.dart' as chat_receive;
import 'functions/chats/message_types.dart';
import 'functions/people/connection_request.dart' as connection_request;
import 'functions/people/group_membersfxn.dart' as group_member;
import 'functions/people/groupsfxn.dart' as group;
import 'functions/people/networkfxn.dart' as network;
import 'functions/people/save_contacts.dart' as contacts;
import 'functions/people/save_user_details.dart' as profile;
import 'functions/people/sendmycontact.dart' as contact_details;
import 'functions/security/share_secret.dart' as secret;
import 'functions/servers/serverfxn.dart' as server;

const Map<int, String> incomingMessageTaskNames = {
  0: 'receiveExchangeMessage',
  1: 'receiveChatMessage',
  2: 'receiveMediaMessage',
  3: 'receivePingMessage',
  4: 'receivePongMessage',
  5: 'receiveJoinMessage',
  6: 'receiveLeaveMessage',
  7: 'receiveMetadataMessage',
  8: 'receiveErrorMessage',
  9: 'receiveKeysMessage',
  10: 'receiveReadReceipt',
  11: 'receiveReceivedReceipt',
  12: 'receivePollMessage',
  13: 'receivePollVoteMessage',
  14: 'receivePollCloseMessage',
  15: 'receivePinMessage',
  16: 'receiveUnpinMessage',
  17: 'receiveEditMessage',
  18: 'receiveDeleteMessage',
  19: 'receiveThreadReplyMessage',
  20: 'receiveLinkPreviewMessage',
  21: 'receiveLocationMessage',
  22: 'receiveContactCardMessage',
  23: 'receiveStickerMessage',
  24: 'receiveTypingStartMessage',
  25: 'receiveTypingStopMessage',
  26: 'receiveReactionAddMessage',
  27: 'receiveReactionRemoveMessage',
  28: 'receiveRoomRenameMessage',
  29: 'receiveRoomAvatarUpdateMessage',
  30: 'receiveUserMuteMessage',
  31: 'receiveUserKickMessage',
  32: 'receiveUserBanMessage',
  33: 'receiveCallStartMessage',
  34: 'receiveCallEndMessage',
  35: 'receiveWebrtcSignalMessage',
  36: 'receiveAnnotationMessage',
  37: 'receiveUpdatesMessage',
};

String incomingMessageTaskName(int messageType) {
  final taskName = incomingMessageTaskNames[messageType];
  if (taskName == null) {
    throw ArgumentError('Unknown message type $messageType.');
  }
  return taskName;
}

final Map<String, dynamic> functionRegistry = {
  'sendChatHandshakeDh': TaskDefinition(
    kind: TaskKind.network,
    databaseExecutor: (payload, database) =>
        handshake.sendDhHandshakeTask(payload.functionArgs, database),
  ),
  'sendChatHandshakeConfirmation': TaskDefinition(
    kind: TaskKind.network,
    databaseExecutor: (payload, database) =>
        handshake.sendHandshakeConfirmationTask(payload.functionArgs, database),
  ),
  'sendChatMessage': TaskDefinition(
    kind: TaskKind.network,
    databaseExecutor: _sendChatMessageTask,
  ),
  'receiveQueuedMessage': TaskDefinition(
    kind: TaskKind.nonNetwork,
    databaseExecutor: _receiveQueuedMessageTask,
  ),
  for (final taskName in incomingMessageTaskNames.values)
    taskName: TaskDefinition(
      kind: TaskKind.nonNetwork,
      databaseExecutor: _receiveQueuedMessageTask,
    ),
};

Future<void> _sendChatMessageTask(
  TaskPayload payload,
  AppDatabase database,
) => chat_send.sendQueuedChatMessage(payload.functionArgs, database);

Future<void> _receiveQueuedMessageTask(
  TaskPayload payload,
  AppDatabase database,
) async {
  final args = payload.functionArgs;
  final senderContactId = args[0] as String;
  final messageId = args[1] as String;
  final logicalId = args[2] as String;
  final messageType = args[3] as int;
  final rawMessage = args[4] as String;
  final expectedTaskName = incomingMessageTaskName(messageType);
  if (payload.taskData != null && payload.taskData != expectedTaskName) {
    throw StateError(
      'Task ${payload.taskId} has type $messageType but task name '
      '"${payload.taskData}".',
    );
  }
  final identityCrypto = const IdentityCrypto();

  if (messageType == 0) {
    await handshake_receive.handleIncomingHandshakeMessage(
      database.contactsDao,
      database.identityDao,
      database.messagesDao,
      database.sessionsDao,
      senderContactId: senderContactId,
      messageType: messageType,
      rawMessage: rawMessage,
      myIdentityCrypto: identityCrypto,
    );
    return;
  }

  if (messageType != MessageType.message.value) {
    throw StateError(
      'Receive handler for message type $messageType is not wired yet.',
    );
  }

  final crypto = NullCrypto(
    identity: identityCrypto,
    ratchetStore: const RatchetStore(),
  );
  await chat_receive.receiveChatMessage(
    crypto,
    database.contactsDao,
    database.messagesDao,
    senderContactId: senderContactId,
    messageId: messageId,
    logicalId: logicalId,
    rawMessage: rawMessage,
  );
}

class FunctionsList {
  //auth
  static Future<dynamic> login({
    required String phoneNumber,
    required String password,
  }) => auth_login.login(phoneNumber: phoneNumber, password: password);

  static Future<dynamic> registerNewUser({
    required String phoneNumber,
    required String pin,
    required String password,
    required AppDatabase database,
    bool forceOverwrite = false,
  }) => auth_register.registerNewUser(
    phoneNumber: phoneNumber,
    pin: pin,
    password: password,
    database: database,
    forceOverwrite: forceOverwrite,
  );

  static Future<dynamic> sendChatMessage(
    NullCrypto crypto,
    ContactsDao contactsDao,
    IdentityDao identityDao,
    MessagesDao messagesDao, {
    required String conversationId,
    required String plaintext,
    required String serverId,
  }) => chat_send.sendChatMessage(
    crypto,
    contactsDao,
    identityDao,
    messagesDao,
    conversationId: conversationId,
    plaintext: plaintext,
    serverId: serverId,
  );

  static Future<dynamic> receiveChatMessage(
    NullCrypto crypto,
    ContactsDao contactsDao,
    MessagesDao messagesDao, {
    required String senderContactId,
    required String messageId,
    required String logicalId,
    required String rawMessage,
  }) => chat_receive.receiveChatMessage(
    crypto,
    contactsDao,
    messagesDao,
    senderContactId: senderContactId,
    messageId: messageId,
    logicalId: logicalId,
    rawMessage: rawMessage,
  );

  static Future<dynamic> receiveContactDetails(
    ContactsDao contactsDao, {
    required String encryptedMessage,
    required SimpleKeyPair privateKeyPair,
    required String contactPublicKey,
  }) => chat_contact.receiveContactDetails(
    contactsDao,
    encryptedMessage: encryptedMessage,
    privateKeyPair: privateKeyPair,
    contactPublicKey: contactPublicKey,
  );

  static Future<dynamic> startEncryptedConversation(
    ContactsDao contactsDao,
    ConversationsDao conversationsDao,
    IdentityDao identityDao,
    SessionsDao sessionsDao, {
    required String contactId,
    required String serverId,
    required IdentityCrypto myIdentityCrypto,
    int maxAttempts = 5,
    Duration attemptTimeout = const Duration(seconds: 15),
  }) => handshake.startEncryptedConversation(
    contactsDao,
    conversationsDao,
    identityDao,
    sessionsDao,
    contactId: contactId,
    serverId: serverId,
    myIdentityCrypto: myIdentityCrypto,
    maxAttempts: maxAttempts,
    attemptTimeout: attemptTimeout,
  );

  static Future<dynamic> handleIncomingHandshakeMessage(
    ContactsDao contactsDao,
    IdentityDao identityDao,
    MessagesDao messagesDao,
    SessionsDao sessionsDao, {
    required String senderContactId,
    required int messageType,
    required String rawMessage,
    required IdentityCrypto myIdentityCrypto,
  }) => handshake_receive.handleIncomingHandshakeMessage(
    contactsDao,
    identityDao,
    messagesDao,
    sessionsDao,
    senderContactId: senderContactId,
    messageType: messageType,
    rawMessage: rawMessage,
    myIdentityCrypto: myIdentityCrypto,
  );

  static Future<dynamic> createConversation(
    ConversationsDao dao, {
    required String conversationId,
    required int conversationType,
    required String serverId,
    String? lastMessageId,
    int? lastMessageTime,
  }) => conversation.createConversation(
    dao,
    conversationId: conversationId,
    conversationType: conversationType,
    serverId: serverId,
    lastMessageId: lastMessageId,
    lastMessageTime: lastMessageTime,
  );

  static Future<dynamic> updateConversationFields(
    ConversationsDao dao,
    String conversationId, {
    int? conversationType,
    String? lastMessageId,
    int? lastMessageTime,
    int? unreadCount,
    int? muted,
    int? pinned,
    int? archived,
    String? draft,
    String? serverId,
    String? sound,
    int? badge,
    int? vibration,
  }) => conversation.updateConversationFields(
    dao,
    conversationId,
    conversationType: conversationType,
    lastMessageId: lastMessageId,
    lastMessageTime: lastMessageTime,
    unreadCount: unreadCount,
    muted: muted,
    pinned: pinned,
    archived: archived,
    draft: draft,
    serverId: serverId,
    sound: sound,
    badge: badge,
    vibration: vibration,
  );

  static Future<dynamic> deleteConversationById(
    ConversationsDao dao,
    String conversationId,
  ) => conversation.deleteConversationById(dao, conversationId);

  static Future<dynamic> createConnectionRequest(
    ConnectionRequestsDao dao, {
    required String requesterId,
    required String recipientId,
    required String groupId,
    required String introduction,
    int? expiresAt,
  }) => connection_request.createConnectionRequest(
    dao,
    requesterId: requesterId,
    recipientId: recipientId,
    groupId: groupId,
    introduction: introduction,
    expiresAt: expiresAt,
  );

  static Future<dynamic> acceptConnectionRequest(
    ConnectionRequestsDao dao,
    String requestId,
  ) => connection_request.acceptConnectionRequest(dao, requestId);

  static Future<dynamic> rejectConnectionRequest(
    ConnectionRequestsDao dao,
    String requestId,
  ) => connection_request.rejectConnectionRequest(dao, requestId);

  static Future<dynamic> createGroupMember(
    GroupMembersDao dao, {
    required String groupId,
    required String identityId,
    String? publicKey,
    String? bio,
    Uint8List? avatar,
    String? name,
    int? joinedAt,
  }) => group_member.createGroupMember(
    dao,
    groupId: groupId,
    identityId: identityId,
    publicKey: publicKey,
    bio: bio,
    avatar: avatar,
    name: name,
    joinedAt: joinedAt,
  );

  static Future<dynamic> editGroupMember(
    GroupMembersDao dao, {
    required String groupId,
    required String identityId,
    String? publicKey,
    String? bio,
    Uint8List? avatar,
    String? name,
    int? joinedAt,
  }) => group_member.editGroupMember(
    dao,
    groupId: groupId,
    identityId: identityId,
    publicKey: publicKey,
    bio: bio,
    avatar: avatar,
    name: name,
    joinedAt: joinedAt,
  );

  static Future<dynamic> deleteGroupMember(
    GroupMembersDao dao, {
    required String groupId,
    required String identityId,
  }) => group_member.deleteGroupMember(
    dao,
    groupId: groupId,
    identityId: identityId,
  );

  static Future<dynamic> createGroup(
    GroupsDao groupsDao,
    IdentityDao identityDao, {
    required String groupName,
    required int groupType,
    String? groupDesc,
    String? avatarFileUrl,
  }) => group.createGroup(
    groupsDao,
    identityDao,
    groupName: groupName,
    groupType: groupType,
    groupDesc: groupDesc,
    avatarFileUrl: avatarFileUrl,
  );

  static Future<dynamic> saveGroup(
    GroupsDao groupsDao, {
    required String groupId,
    required String ownerId,
    required String groupName,
    required int groupType,
    String? privateKey,
    String? groupDesc,
    String? avatarBase64,
  }) => group.saveGroup(
    groupsDao,
    groupId: groupId,
    ownerId: ownerId,
    groupName: groupName,
    groupType: groupType,
    privateKey: privateKey,
    groupDesc: groupDesc,
    avatarBase64: avatarBase64,
  );

  static Future<dynamic> updateGroupFields(
    GroupsDao groupsDao, {
    required String groupId,
    String? groupName,
    String? ownerId,
    String? privateKey,
    String? newPrivateKey,
    int? swapTime,
    String? groupDesc,
  }) => group.updateGroupFields(
    groupsDao,
    groupId: groupId,
    groupName: groupName,
    ownerId: ownerId,
    privateKey: privateKey,
    newPrivateKey: newPrivateKey,
    swapTime: swapTime,
    groupDesc: groupDesc,
  );

  static Future<dynamic> createContactNetwork(
    ContactsNetworkDao networkDao, {
    required String networkName,
    required String serverId,
  }) => network.createContactNetwork(
    networkDao,
    networkName: networkName,
    serverId: serverId,
  );

  static Future<dynamic> addContactsToNetwork(
    ContactNetworkMembersDao membersDao, {
    required String networkId,
    required List<String> contactIds,
  }) => network.addContactsToNetwork(
    membersDao,
    networkId: networkId,
    contactIds: contactIds,
  );

  static Future<dynamic> deleteNetworkAndMembers(
    ContactsNetworkDao networkDao,
    ContactNetworkMembersDao membersDao,
    String networkId,
  ) => network.deleteNetworkAndMembers(networkDao, membersDao, networkId);

  static Future<dynamic> removeContactFromNetwork(
    ContactNetworkMembersDao membersDao, {
    required String networkId,
    required String contactId,
  }) => network.removeContactFromNetwork(
    membersDao,
    networkId: networkId,
    contactId: contactId,
  );

  static Future<dynamic> saveContact(
    ContactsDao contactsDao, {
    required String contactId,
    String? nickname,
    Uint8List? avatar,
    String? bio,
    String? publicKey,
    required String serverId,
    int connectionStatus = 1,
  }) => contacts.saveContact(
    contactsDao,
    contactId: contactId,
    nickname: nickname,
    avatar: avatar,
    bio: bio,
    publicKey: publicKey,
    serverId: serverId,
    connectionStatus: connectionStatus,
  );

  static Future<dynamic> saveProfile(
    IdentityDao identityDao, {
    String? displayName,
    String? bio,
    String? avatar,
  }) => profile.saveProfile(
    identityDao,
    displayName: displayName,
    bio: bio,
    avatar: avatar,
  );

  static Future<dynamic> sendContactDetails(
    IdentityDao identityDao,
    ContactsDao contactsDao, {
    required String recipientUserId,
    required String serverId,
  }) => contact_details.sendContactDetails(
    identityDao,
    contactsDao,
    recipientUserId: recipientUserId,
    serverId: serverId,
  );

  static Future<contact_details.SendMyContactResult> sendMyContact({
    required AppDatabase database,
    required TaskQueue taskQueue,
    required String mainServerId,
    Duration receiveDelay = const Duration(seconds: 2),
  }) => contact_details.sendMyContact(
    database: database,
    taskQueue: taskQueue,
    mainServerId: mainServerId,
    receiveDelay: receiveDelay,
  );

  static Future<dynamic> sendContactDetailsBack(
    IdentityDao identityDao,
    ContactsDao contactsDao, {
    required String recipientUserId,
    required String serverId,
  }) => contact_details.sendContactDetailsBack(
    identityDao,
    contactsDao,
    recipientUserId: recipientUserId,
    serverId: serverId,
  );

  static Future<dynamic> shareSecretWithUser({
    required String identityId,
    required AppDatabase database,
    String storageKey = kShamirSecretStorageKey,
  }) => secret.shareSecretWithUser(
    identityId: identityId,
    database: database,
    storageKey: storageKey,
  );

  static Future<dynamic> reverseShareSecretForUser({
    required String identityId,
    required AppDatabase database,
    String storageKey = kShamirSecretStorageKey,
  }) => secret.reverseShareSecretForUser(
    identityId: identityId,
    database: database,
    storageKey: storageKey,
  );

  static Future<dynamic> createServer(
    ServersDao serversDao, {
    required String serverId,
    required String serverName,
    required String serverUrl,
    required String mediaUrl,
    required int mediaSizeLimit,
    required int mediaTimer,
    required int maxPayload,
    required int capabilities,
  }) => server.createServer(
    serversDao,
    serverId: serverId,
    serverName: serverName,
    serverUrl: serverUrl,
    mediaUrl: mediaUrl,
    mediaSizeLimit: mediaSizeLimit,
    mediaTimer: mediaTimer,
    maxPayload: maxPayload,
    capabilities: capabilities,
  );

  static Future<dynamic> updateServerFields(
    ServersDao serversDao, {
    required String serverId,
    String? serverName,
    String? serverUrl,
    String? mediaUrl,
    int? mediaSizeLimit,
    int? mediaTimer,
    int? maxPayload,
    int? capabilities,
    int? colour,
    int? totalMediaSent,
    DateTime? mediaLastReset,
  }) => server.updateServerFields(
    serversDao,
    serverId: serverId,
    serverName: serverName,
    serverUrl: serverUrl,
    mediaUrl: mediaUrl,
    mediaSizeLimit: mediaSizeLimit,
    mediaTimer: mediaTimer,
    maxPayload: maxPayload,
    capabilities: capabilities,
    colour: colour,
    totalMediaSent: totalMediaSent,
    mediaLastReset: mediaLastReset,
  );

  static Future<dynamic> deleteServerById(
    ServersDao serversDao,
    String serverId,
  ) => server.deleteServerById(serversDao, serverId);

  static Future<dynamic> refreshServers(
    ServersDao serversDao,
    ServerDirectoryService directoryService,
  ) => server.refreshServers(serversDao, directoryService);

  //other
}
