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
import 'tables/sessions.dart';
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
import 'queries/sessions_queries.dart';

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
    Sessions,
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
    SessionsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();

          await customStatement(
            'PRAGMA foreign_keys = ON;',
          );
        },

        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(contacts, contacts.publicKey);
          }
          if (from < 3) {
            await m.addColumn(messages, messages.decryptedMessage);
          }
          if (from < 4) {
            await m.createTable(sessions);
          }
        },

        beforeOpen: (details) async {
          await customStatement(
            'PRAGMA foreign_keys = ON;',
          );

          await _createIndexes();
        },
      );

  Future<void> _createIndexes() async {
    // Drop indexes that no longer back any query (or reference columns that
    // do not exist) so existing installations actually shed them.

    // Conversations
    await customStatement(
      'DROP INDEX IF EXISTS idx_conversations_badge;',
    );
    await customStatement(
      'DROP INDEX IF EXISTS idx_conversations_pinned;',
    );
    await customStatement(
      'DROP INDEX IF EXISTS idx_conversations_archived;',
    );
    await customStatement(
      'DROP INDEX IF EXISTS idx_conversations_server;',
    );

    // Messages
    await customStatement(
      'DROP INDEX IF EXISTS idx_messages_conversation_timestamp;',
    );
    await customStatement(
      'DROP INDEX IF EXISTS idx_messages_logical_message;',
    );
    await customStatement(
      'DROP INDEX IF EXISTS idx_messages_sender_sequence;',
    );
    await customStatement(
      'DROP INDEX IF EXISTS idx_messages_chain_index;',
    );
    await customStatement(
      'DROP INDEX IF EXISTS idx_messages_reply_to;',
    );
    await customStatement(
      'DROP INDEX IF EXISTS idx_messages_protocol_version;',
    );

    // Groups
    await customStatement(
      'DROP INDEX IF EXISTS idx_groups_group_type;',
    );
    await customStatement(
      'DROP INDEX IF EXISTS idx_groups_owner_id;',
    );

    // Servers / ContactsNetwork
    await customStatement(
      'DROP INDEX IF EXISTS idx_servers_name;',
    );
    await customStatement(
      'DROP INDEX IF EXISTS idx_contacts_network_server;',
    );

    // Connection requests (recreated as group_id-only below).
    await customStatement(
      'DROP INDEX IF EXISTS idx_connection_requests_group_status;',
    );

    // ShamirsSecret has no `server_id` column.
    await customStatement(
      'DROP INDEX IF EXISTS idx_shamirs_secret_server;',
    );

    // SecretShare: `identity_id` is already the PK (auto-indexed) and there
    // is no `secret_id` column.
    await customStatement(
      'DROP INDEX IF EXISTS idx_secret_share_identity;',
    );
    await customStatement(
      'DROP INDEX IF EXISTS idx_secret_share_secret;',
    );

    // Create indexes that back real queries.

    // Conversations: chat list ordered by last message time.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_conversations_last_message_time '
      'ON conversations(last_message_time DESC);',
    );

    // Messages: per-conversation ordering and status lookups.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_messages_conversation_order '
      'ON messages(conversation_id, message_order);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_messages_status '
      'ON messages(conversation_id, _status);',
    );

    // Contacts
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_contacts_connection_status '
      'ON contacts(connection_status);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_contacts_conversation_id '
      'ON contacts(conversation_id);',
    );

    // Connection requests
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_connection_requests_recipient_status '
      'ON connection_requests(recipient_id, _status);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_connection_requests_group '
      'ON connection_requests(group_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_connection_requests_requester '
      'ON connection_requests(requester_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_connection_requests_status_expires '
      'ON connection_requests(_status, expires_at);',
    );

    // Tasks
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tasks_status '
      'ON tasks(task_status);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tasks_server_id '
      'ON tasks(server_id);',
    );

    // ContactNetworkMembers (junction table)
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_contact_network_members_network '
      'ON contact_network_members(network_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_contact_network_members_contact '
      'ON contact_network_members(contact_id);',
    );

    // GroupMembers: reverse lookup of groups for an identity.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_group_members_identity '
      'ON group_members(identity_id);',
    );

    // Sessions: pending/confirming handshake lookups.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sessions_status '
      'ON sessions(status);',
    );
  }
}