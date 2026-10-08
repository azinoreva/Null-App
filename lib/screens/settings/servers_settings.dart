import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/functions/servers/connect_serverfxn.dart'
    as server_connect;
import '../../engine/network/api_client.dart';
import '../../engine/network/auth_failure_handler.dart';
import '../../engine/network/servers/servers.dart' as server_directory;
import '../../state/providers.dart';
import '../../utils/server_list.dart';
import '../../widgets/app_theme.dart';
import '../modals/server_list_modal.dart';
import 'settings_widgets.dart';

/// "Servers" leaf page: the networks and groups you are connected to.
class ServersSettingsScreen extends ConsumerWidget {
  const ServersSettingsScreen({super.key});

  Future<void> _showConnectedServers(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final serverList = ref.read(serverListProvider);
    await serverList.init();
    if (!context.mounted) return;

    final servers = [
      for (final server in serverList.servers)
        ServerInfo.fromJson(server.toJson()),
      // Extras are full peers too — same cards, same disconnect flow; the
      // only difference is they're never given a websocket.
      for (final server in serverList.extraServers)
        ServerInfo.fromJson(server.toJson(), isExtra: true),
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServersListModal(
        servers: servers,
        action: ServerAction.disconnect,
        onServerAction: (server) => _disconnectServer(ref, server),
      ),
    );
  }

  Future<void> _disconnectServer(WidgetRef ref, ServerInfo server) async {
    final serverList = ref.read(serverListProvider);
    // Whichever list it lives in — normal first, then extra.
    if (!await serverList.removeServer(server.serverId)) {
      await serverList.removeExtraServer(server.serverId);
    }
    await ApiClient.unregisterServer(server.serverId);

    // The shared server list notifies the SSE supervisor, which drops that
    // server's subscription (see ServerConnectionService._syncToServerList).
  }

  Future<void> _showAddServer(BuildContext context, WidgetRef ref) async {
    try {
      final directory = server_directory.ServerDirectoryService();
      final response = await directory.getServers();

      final byId = {for (final s in response.servers) s.serverId: s};
      final servers = response.servers
          .map((s) => ServerInfo.fromJson(s.toJson()))
          .toList();

      if (!context.mounted) return;
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ServersListModal(
          servers: servers,
          action: ServerAction.connect,
          title: 'Add a Server',
          subtitle: 'Servers available to connect',
          emptyMessage: 'No servers available',
          onServerAction: (server) =>
              _connectServer(context, ref, server, full: byId[server.serverId]),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not load servers: $error')));
    }
  }

  Future<void> _connectServer(
    BuildContext context,
    WidgetRef ref,
    ServerInfo server, {
    server_directory.ServerInfo? full,
  }) async {
    // The modal only carries the four display fields; pull the full config
    // from the directory response so nothing is lost when persisting.
    if (full == null) return;

    final serverList = ref.read(serverListProvider);
    await serverList.init();

    // Join the normal list while there's room; once it's full the server is
    // joined as an extra one. Either way it is a real peer from here on —
    // ApiClient registration and the passport exchange below are identical,
    // and only ServerConnectionService skips the websocket for extras.
    var joinedAsExtra = serverList.getExtraServer(full.serverId) != null;
    if (!joinedAsExtra && serverList.getServer(full.serverId) == null) {
      final config = full.toConfig();
      try {
        if (serverList.canJoinExtraServers) {
          await serverList.addExtraServer(config);
          joinedAsExtra = true;
        } else {
          await serverList.addServer(config);
        }
      } on ServerListException catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
        return;
      }
    }

    await ApiClient.registerServer(
      serverId: full.serverId,
      // A server added here is a peer with its own token pair; the passport
      // exchange below is what earns it one. Refusing us must not log the
      // user out of the app.
      onAuthFailure: serverAuthFailureCallbackFor(full.serverId),
    );

    // Exchange the passport saved at signup for this server's token pair.
    final result = await server_connect.connectServerUsingPassport(
      serverId: full.serverId,
      database: ref.read(appDatabaseProvider),
    );

    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final message = switch (result.outcome) {
      server_connect.ServerConnectOutcome.success =>
        joinedAsExtra
            ? 'Connected to ${full.serverName} as an extra server '
                  '(updates only, no websocket).'
            : 'Connected to ${full.serverName}.',
      server_connect.ServerConnectOutcome.noPassport =>
        'No passport found. Sign up again to obtain one.',
      server_connect.ServerConnectOutcome.noIdentity =>
        'No local identity found. Sign up again.',
      server_connect.ServerConnectOutcome.noIdentityKey =>
        'Your identity key is missing, so the server could not verify you. '
            'Sign up again.',
      server_connect.ServerConnectOutcome.challengeExpired =>
        'The server challenge expired before it could be answered. Try again.',
      server_connect.ServerConnectOutcome.passportRejected =>
        result.errorMessage != null
            ? 'Could not connect: ${result.errorMessage}'
            : 'The server rejected your passport.',
      server_connect.ServerConnectOutcome.failed =>
        result.errorMessage != null
            ? 'Could not connect: ${result.errorMessage}'
            : 'Could not connect to the server.',
    };
    messenger.showSnackBar(SnackBar(content: Text(message)));

    // Adding to the shared server list notifies the SSE supervisor, which
    // registers the connection automatically (ServerConnectionService).
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

    return SettingsScaffold(
      icon: Icons.dns_outlined,
      title: 'Servers',
      children: [
        SettingsNavRow(
          theme: theme,
          icon: Icons.dns_outlined,
          title: 'Connected Servers',
          subtitle: 'View your active server connections.',
          onTap: () => unawaited(_showConnectedServers(context, ref)),
        ),
        SettingsNavRow(
          theme: theme,
          icon: Icons.add_circle_outline,
          title: 'Add a Server',
          subtitle: 'Join a new network or group.',
          onTap: () => unawaited(_showAddServer(context, ref)),
          isAccent: true,
        ),
      ],
    );
  }
}
