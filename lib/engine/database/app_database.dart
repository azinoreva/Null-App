import 'package:drift/drift.dart';

// Import all table model files
import 'tables/identity.dart';
import 'tables/servers.dart';
import 'tables/conversations.dart';
import 'tables/messages.dart';
import 'tables/contacts.dart';
import 'tables/networks.dart';
import 'tables/groups.dart';
import 'tables/group_members.dart';
import 'tables/connection_requests.dart';
import 'tables/tasks.dart';
import 'tables/shamirs_secret.dart';
import 'tables/secret_share.dart';
import 'tables/sync_state.dart';

// Import all DAO files
import 'queries/identity_queries.dart';
import 'queries/servers_queries.dart';
import 'queries/conversations_queries.dart';
import 'queries/messages_queries.dart';
import 'queries/contacts_queries.dart';
import 'queries/network_queries.dart';
import 'queries/groups_queries.dart';
import 'queries/group_members_queries.dart';
import 'queries/connection_requests_queries.dart';
import 'queries/tasks_queries.dart';
import 'queries/shamirs_secret_queries.dart';
import 'queries/secret_share_queries.dart';
import 'queries/sync_state_queries.dart';

part 'app_database.g.dart';

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
    ConnectionRequests,
    Tasks,
    ShamirsSecret,
    SecretShare,
    SyncState,
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
    ConnectionRequestsDao,
    TasksDao,
    ShamirsSecretDao,
    SecretShareDao,
    SyncStateDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();

          await customStatement(
            'PRAGMA foreign_keys = ON;',
          );

          await _createIndexes();
        },

        onUpgrade: (Migrator m, int from, int to) async {
          // Add version-specific migrations here.
        },

        beforeOpen: (details) async {
          await customStatement(
            'PRAGMA foreign_keys = ON;',
          );
        },
      );

  Future<void> _createIndexes() async {
    // Conversations

    await customStatement(
      'CREATE INDEX idx_conversations_last_message_time '
      'ON conversations(last_message_time DESC);',
    );

    await customStatement(
      'CREATE INDEX idx_conversations_badge '
      'ON conversations(badge);',
    );

    await customStatement(
      'CREATE INDEX idx_conversations_pinned '
      'ON conversations(pinned);',
    );

    await customStatement(
      'CREATE INDEX idx_conversations_archived '
      'ON conversations(archived);',
    );

    await customStatement(
      'CREATE INDEX idx_conversations_server '
      'ON conversations(server_id);',
    );

    // Messages

    await customStatement(
      'CREATE INDEX idx_messages_conversation_order '
      'ON messages(conversation_id, message_order);',
    );

    await customStatement(
      'CREATE INDEX idx_messages_conversation_timestamp '
      'ON messages(conversation_id, _timestamp);',
    );

    await customStatement(
      'CREATE INDEX idx_messages_logical_message '
      'ON messages(conversation_id, logical_message_id);',
    );

    await customStatement(
      'CREATE INDEX idx_messages_sender_sequence '
      'ON messages(conversation_id, sender_id, sender_sequence);',
    );

    await customStatement(
      'CREATE INDEX idx_messages_chain_index '
      'ON messages(conversation_id, sender_id, chain_index);',
    );

    await customStatement(
      'CREATE INDEX idx_messages_status '
      'ON messages(conversation_id, _status);',
    );

    await customStatement(
      'CREATE INDEX idx_messages_reply_to '
      'ON messages(reply_to);',
    );

    await customStatement(
      'CREATE INDEX idx_messages_protocol_version '
      'ON messages(protocol_version);',
    );

    // Contacts

    await customStatement(
      'CREATE INDEX idx_contacts_connection_status '
      'ON contacts(connection_status);',
    );

    await customStatement(
      'CREATE INDEX idx_contacts_conversation_id '
      'ON contacts(conversation_id);',
    );

    // Groups

    await customStatement(
      'CREATE INDEX idx_groups_group_type '
      'ON groups(group_type);',
    );

    await customStatement(
      'CREATE INDEX idx_groups_owner_id '
      'ON groups(owner_id);',
    );

    // Connection requests

    await customStatement(
      'CREATE INDEX idx_connection_requests_recipient_status '
      'ON connection_requests(recipient_id, _status);',
    );

    await customStatement(
      'CREATE INDEX idx_connection_requests_group_status '
      'ON connection_requests(group_id, _status);',
    );

    // Tasks

    await customStatement(
      'CREATE INDEX idx_tasks_status '
      'ON tasks(task_status);',
    );

    await customStatement(
      'CREATE INDEX idx_tasks_server_id '
      'ON tasks(server_id);',
    );

    // Identity

    await customStatement(
      'CREATE INDEX idx_identity_server_id '
      'ON identity(server_id);',
    );

    // Servers

    await customStatement(
      'CREATE INDEX idx_servers_name '
      'ON servers(server_name);',
    );

    // ContactsNetwork

    await customStatement(
      'CREATE INDEX idx_contacts_network_server '
      'ON contacts_network(server_id);',
    );

    // ContactNetworkMembers

    await customStatement(
      'CREATE INDEX idx_contact_network_members_network '
      'ON contact_network_members(network_id);',
    );

    await customStatement(
      'CREATE INDEX idx_contact_network_members_contact '
      'ON contact_network_members(contact_id);',
    );

    // Shamir's Secret

    await customStatement(
      'CREATE INDEX idx_shamirs_secret_server '
      'ON shamirs_secret(server_id);',
    );

    // Secret shares

    await customStatement(
      'CREATE INDEX idx_secret_share_identity '
      'ON secret_share(identity_id);',
    );

    await customStatement(
      'CREATE INDEX idx_secret_share_secret '
      'ON secret_share(secret_id);',
    );
  }
}