import 'package:drift/drift.dart';

import '../tables/identity_model.dart';
import '../tables/servers_model.dart';
import '../tables/conversations_model.dart';
import '../tables/messages_model.dart';
import 'identity_queries.dart';
import 'servers_queries.dart';
import 'conversations_queries.dart';
import 'messages_queries.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Identity, Servers, Conversations, Messages],
  daos: [IdentityDao, ServersDao, ConversationsDao, MessagesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();

      // Indexes for Conversations
      await customStatement(
        'CREATE INDEX idx_conversations_last_message_time ON conversations(last_message_time DESC);',
      );
      await customStatement(
        'CREATE INDEX idx_conversations_badge ON conversations(badge);',
      );
      await customStatement(
        'CREATE INDEX idx_conversations_pinned ON conversations(pinned);',
      );
      await customStatement(
        'CREATE INDEX idx_conversations_archived ON conversations(archived);',
      );
      await customStatement(
        'CREATE INDEX idx_conversations_server ON conversations(server_id);',
      );

      // Indexes for Messages
      await customStatement(
        'CREATE INDEX idx_messages_conversation_order ON messages(conversation_id, message_order);',
      );
      await customStatement(
        'CREATE INDEX idx_messages_conversation_timestamp ON messages(conversation_id, _timestamp);',
      );
      await customStatement(
        'CREATE INDEX idx_messages_logical_message ON messages(conversation_id, logical_message_id);',
      );
      await customStatement(
        'CREATE INDEX idx_messages_sender_sequence ON messages(conversation_id, sender_id, sender_sequence);',
      );
      await customStatement(
        'CREATE INDEX idx_messages_chain_index ON messages(conversation_id, sender_id, chain_index);',
      );
      await customStatement(
        'CREATE INDEX idx_messages_status ON messages(conversation_id, _status);',
      );
      await customStatement(
        'CREATE INDEX idx_messages_reply_to ON messages(reply_to);',
      );
      await customStatement(
        'CREATE INDEX idx_messages_protocol_version ON messages(protocol_version);',
      );
    },
  );
}


import '../tables/contacts_model.dart';
import 'contacts_queries.dart';

@DriftDatabase(
  tables: [Identity, Servers, Conversations, Messages, Contacts],
  daos: [IdentityDao, ServersDao, ConversationsDao, MessagesDao, ContactsDao],
)
class AppDatabase extends _$AppDatabase {
  // ... existing code
}

import '../tables/contacts_network_model.dart';
import 'contacts_network_queries.dart';

@DriftDatabase(
  tables: [
    Identity,
    Servers,
    Conversations,
    Messages,
    Contacts,
    ContactsNetwork,
    ContactNetworkMembers,
  ],
  daos: [
    IdentityDao,
    ServersDao,
    ConversationsDao,
    MessagesDao,
    ContactsDao,
    ContactsNetworkDao,
    ContactNetworkMembersDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  // ... existing code
}

import '../tables/groups_model.dart';
import 'groups_queries.dart';

@DriftDatabase(
  tables: [
    Identity,
    Servers,
    Conversations,
    Messages,
    Contacts,
    ContactsNetwork,
    ContactNetworkMembers,
    Groups,
  ],
  daos: [
    IdentityDao,
    ServersDao,
    ConversationsDao,
    MessagesDao,
    ContactsDao,
    ContactsNetworkDao,
    ContactNetworkMembersDao,
    GroupsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  // ... existing code
}

import '../tables/group_members_model.dart';
import 'group_members_queries.dart';

@DriftDatabase(
  tables: [
    Identity,
    Servers,
    Conversations,
    Messages,
    Contacts,
    ContactsNetwork,
    ContactNetworkMembers,
    Groups,
    GroupMembers,
  ],
  daos: [
    IdentityDao,
    ServersDao,
    ConversationsDao,
    MessagesDao,
    ContactsDao,
    ContactsNetworkDao,
    ContactNetworkMembersDao,
    GroupsDao,
    GroupMembersDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  // ... existing code
}