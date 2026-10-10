import 'package:drift/drift.dart';

// Import all table model files
import 'tables/identity.dart';
import 'tables/servers.dart';
import 'tables/conversations.dart';
import 'tables/messages.dart';
import 'tables/contacts.dart';
import 'tables/servers_converter.dart';
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

/// A reference to the `servers.media_size_limit` column as it existed at
/// schema version 5, used to carry its value into the renamed `media_size`
/// column. See [_migrateServersToApiShape].
final _legacyMediaSizeLimit = GeneratedColumn<int>(
  'media_size_limit',
  'servers',
  false,
  type: DriftSqlType.int,
);

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

  /// Removes all account-scoped data while keeping the encrypted database
  /// open and preserving its schema and encryption key.
  Future<void> clearAllUserData() async {
    await transaction(() async {
      await delete(tasks).go();
      await delete(syncState).go();
      await delete(messages).go();
      await delete(groupMembers).go();
      await delete(connectionRequests).go();
      await delete(contactNetworkMembers).go();
      await delete(contactsNetwork).go();
      await delete(conversations).go();
      await delete(contacts).go();
      await delete(groups).go();
      await delete(secretShare).go();
      await delete(shamirsSecret).go();
      await delete(sessions).go();
      await delete(servers).go();
      await delete(identity).go();
    });
  }

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();

      await customStatement('PRAGMA foreign_keys = ON;');
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
      if (from < 5) {
        await m.addColumn(sessions, sessions.dropSent);
      }
      if (from < 6) {
        await _migrateServersToApiShape(m);
      }
      if (from < 7) {
        await customStatement(
          'ALTER TABLE identity DROP COLUMN invitation_count;',
        );
      }
      if (from < 8) {
        // contacts.server_id (one server) became contacts.servers (a JSON
        // list of up to 8 servers), and the unused main_server_id column is
        // gone. Existing single-id values stay readable because
        // ServersConverter falls back to wrapping a bare string.
        await customStatement(
          'ALTER TABLE contacts RENAME COLUMN server_id TO servers;',
        );
        await customStatement(
          'ALTER TABLE contacts DROP COLUMN main_server_id;',
        );
      }
      if (from < 9) {
        // conversations.server_id (a single server) became
        // conversations.servers (a JSON list of up to 8 servers), mirroring
        // contacts.servers. The column stays TEXT; ServersConverter reads the
        // old single id back as a one-element list.
        await customStatement(
          'ALTER TABLE conversations RENAME COLUMN server_id TO servers;',
        );
      }
    },

    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');

      await _createIndexes();
    },
  );

  /// Rebuilds `servers` so its columns match the backend `Server` payload.
  ///
  /// `alterTable` recreates the table from the new definition, so columns
  /// missing from [Servers] any more (`capabilities`, `media_size_limit`) are
  /// dropped and the remaining ones are copied across. Three values need
  /// explicit handling:
  /// - `colour` changes from the old locally-picked INTEGER to the API's
  ///   string, so it is reset rather than copied. Its local equivalent now
  ///   lives in `accent_colour`, which also starts from the default.
  /// - `media_size` is the API's `media.size`, which the old table stored as
  ///   `media_size_limit`, so the value is carried across under its new name.
  /// - the columns the API added take their declared defaults.
  Future<void> _migrateServersToApiShape(Migrator m) async {
    await m.alterTable(
      TableMigration(
        servers,
        columnTransformer: {
          servers.colour: const Constant(''),
          servers.accentColour: const Constant(65280),
          servers.mediaSize: _legacyMediaSizeLimit,
        },
        newColumns: [
          servers.serverType,
          servers.about,
          servers.categories,
          servers.annotated,
          servers.disabled,
          servers.location,
          servers.mediaType,
        ],
      ),
    );
  }

  Future<void> _createIndexes() async {
    // Drop indexes that no longer back any query (or reference columns that
    // do not exist) so existing installations actually shed them.

    // Conversations
    await customStatement('DROP INDEX IF EXISTS idx_conversations_badge;');
    await customStatement('DROP INDEX IF EXISTS idx_conversations_pinned;');
    await customStatement('DROP INDEX IF EXISTS idx_conversations_archived;');
    await customStatement('DROP INDEX IF EXISTS idx_conversations_server;');

    // Messages
    await customStatement(
      'DROP INDEX IF EXISTS idx_messages_conversation_timestamp;',
    );
    await customStatement('DROP INDEX IF EXISTS idx_messages_logical_message;');
    await customStatement('DROP INDEX IF EXISTS idx_messages_sender_sequence;');
    await customStatement('DROP INDEX IF EXISTS idx_messages_chain_index;');
    await customStatement('DROP INDEX IF EXISTS idx_messages_reply_to;');
    await customStatement(
      'DROP INDEX IF EXISTS idx_messages_protocol_version;',
    );

    // Groups
    await customStatement('DROP INDEX IF EXISTS idx_groups_group_type;');
    await customStatement('DROP INDEX IF EXISTS idx_groups_owner_id;');

    // Servers / ContactsNetwork
    await customStatement('DROP INDEX IF EXISTS idx_servers_name;');
    await customStatement('DROP INDEX IF EXISTS idx_contacts_network_server;');

    // Connection requests (recreated as group_id-only below).
    await customStatement(
      'DROP INDEX IF EXISTS idx_connection_requests_group_status;',
    );

    // ShamirsSecret has no `server_id` column.
    await customStatement('DROP INDEX IF EXISTS idx_shamirs_secret_server;');

    // SecretShare: `identity_id` is already the PK (auto-indexed) and there
    // is no `secret_id` column.
    await customStatement('DROP INDEX IF EXISTS idx_secret_share_identity;');
    await customStatement('DROP INDEX IF EXISTS idx_secret_share_secret;');

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
