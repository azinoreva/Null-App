import 'package:flutter/material.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/buttons/send_button.dart';

enum ServerType { public, private, other }

/// Which action the buttons on each server card should offer.
/// Passed in separately from the [ServerInfo] list, since it applies to
/// the whole modal rather than to any individual server.
enum ServerAction { connect, disconnect }

/// Only the four fields this modal actually needs, pulled out of the
/// larger server object your app passes around.
class ServerInfo {
  final String serverId;
  final String serverName;
  final String serverUrl;
  final ServerType serverType;

  const ServerInfo({
    required this.serverId,
    required this.serverName,
    required this.serverUrl,
    required this.serverType,
  });

  /// Builds one from the raw JSON shape shown in the mockup - safe to
  /// call with the full server object; everything besides these four
  /// fields is ignored.
  factory ServerInfo.fromJson(Map<String, dynamic> json) {
    return ServerInfo(
      serverId: json['serverId'] as String? ?? '',
      serverName: json['serverName'] as String? ?? '',
      serverUrl: json['serverUrl'] as String? ?? '',
      serverType: _parseServerType(json['serverType'] as String?),
    );
  }

  static ServerType _parseServerType(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'public':
        return ServerType.public;
      case 'private':
        return ServerType.private;
      default:
        return ServerType.other;
    }
  }
}

/// "Connected Servers" modal - takes a list of [ServerInfo] and renders
/// it split into Public / Private sections (plus an "Other" section if
/// any entries don't match either, so nothing silently disappears).
///
/// Every card shows a single action button whose label/icon is driven by
/// [action] (Connect or Disconnect). Tapping it invokes
/// [onServerAction]; while that future is in flight the card shows a
/// spinner in place of the button. If the future completes successfully
/// the server is removed from the locally-rendered list.
class ServersListModal extends StatefulWidget {
  final List<ServerInfo> servers;

  /// Whether the cards should offer a "Connect" or a "Disconnect" button.
  final ServerAction action;

  /// Called when a card's action button is tapped. The returned future
  /// drives the per-card loading state.
  final Future<void> Function(ServerInfo server) onServerAction;

  final VoidCallback? onDone;
  final VoidCallback? onClose;

  /// Header text; the same modal is reused for "connected" and "add"
  /// flows, which want slightly different wording.
  final String title;
  final String subtitle;
  final String emptyMessage;

  const ServersListModal({
    super.key,
    required this.servers,
    required this.action,
    required this.onServerAction,
    this.onDone,
    this.onClose,
    this.title = 'Connected Servers',
    this.subtitle = "Servers you're currently connected to",
    this.emptyMessage = 'No connected servers',
  });

  @override
  State<ServersListModal> createState() => _ServersListModalState();
}

class _ServersListModalState extends State<ServersListModal> {
  late List<ServerInfo> _servers;
  final Set<ServerInfo> _busy = {};

  @override
  void initState() {
    super.initState();
    _servers = List<ServerInfo>.from(widget.servers);
  }

  void _handleClose() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _handleDone() {
    if (widget.onDone != null) {
      widget.onDone!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _handleAction(ServerInfo server) async {
    if (_busy.contains(server)) return;
    setState(() => _busy.add(server));

    await widget.onServerAction(server);

    if (!mounted) return;
    setState(() {
      // A successful disconnect means the server is no longer connected,
      // so drop it from the list. A successful connect just clears the
      // spinner (the caller can rebuild with a new list if it wants).
      if (widget.action == ServerAction.disconnect) {
        _servers.remove(server);
      }
      _busy.remove(server);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

    final publicServers =
        _servers.where((s) => s.serverType == ServerType.public).toList();
    final privateServers =
        _servers.where((s) => s.serverType == ServerType.private).toList();
    final otherServers =
        _servers.where((s) => s.serverType == ServerType.other).toList();

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34.0,
                height: 34.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.primaryGreen.withAlpha(35),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.dns_outlined,
                    size: 18.0, color: theme.primaryGreen),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTypography.getTextStyle(
                        context,
                        AppTextType.body,
                        color: theme.textInputColor,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.subtitle,
                      style: AppTypography.getTextStyle(
                        context,
                        AppTextType.tiny,
                        color: AppColors.mutedSlate,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _handleClose,
                customBorder: const CircleBorder(),
                child: Icon(Icons.close, color: AppColors.mutedSlate),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          Flexible(
            child: _servers.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(
                      child: Text(
                        widget.emptyMessage,
                        style: AppTypography.getTextStyle(
                          context,
                          AppTextType.body,
                          color: AppColors.mutedSlate,
                        ),
                      ),
                    ),
                  )
                : ListView(
                    shrinkWrap: true,
                    children: [
                      if (publicServers.isNotEmpty)
                        _ServerSection(
                          theme: theme,
                          title: 'Public Servers',
                          servers: publicServers,
                          action: widget.action,
                          busy: _busy,
                          onAction: _handleAction,
                        ),
                      if (privateServers.isNotEmpty)
                        _ServerSection(
                          theme: theme,
                          title: 'Private Servers',
                          servers: privateServers,
                          action: widget.action,
                          busy: _busy,
                          onAction: _handleAction,
                        ),
                      if (otherServers.isNotEmpty)
                        _ServerSection(
                          theme: theme,
                          title: 'Other Servers',
                          servers: otherServers,
                          action: widget.action,
                          busy: _busy,
                          onAction: _handleAction,
                        ),
                    ],
                  ),
          ),

          const SizedBox(height: 12.0),
          Divider(color: theme.border, height: 1.0),
          const SizedBox(height: 12.0),
          Align(
            alignment: Alignment.centerRight,
            child: SendButton(
              text: 'Done',
              onPressed: _handleDone,
              textType: AppTextType.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServerSection extends StatelessWidget {
  final AppColorScheme theme;
  final String title;
  final List<ServerInfo> servers;
  final ServerAction action;
  final Set<ServerInfo> busy;
  final Future<void> Function(ServerInfo server) onAction;

  const _ServerSection({
    required this.theme,
    required this.title,
    required this.servers,
    required this.action,
    required this.busy,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              title.toUpperCase(),
              style: AppTypography.getTextStyle(
                context,
                AppTextType.tiny,
                color: AppColors.mutedSlate,
              ).copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
          ...servers.map(
            (server) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _ServerCard(
                theme: theme,
                server: server,
                action: action,
                isBusy: busy.contains(server),
                onAction: () => onAction(server),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServerCard extends StatelessWidget {
  final AppColorScheme theme;
  final ServerInfo server;
  final ServerAction action;
  final bool isBusy;
  final VoidCallback onAction;

  const _ServerCard({
    required this.theme,
    required this.server,
    required this.action,
    required this.isBusy,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: theme.border.withAlpha(70),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.0,
            height: 36.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.primaryGreen.withAlpha(35),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(Icons.computer, size: 18.0, color: theme.primaryGreen),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  server.serverName,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.body,
                    color: theme.textInputColor,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2.0),
                Text(
                  server.serverUrl,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.tiny,
                    color: AppColors.mutedSlate,
                  ),
                ),
                Text(
                  server.serverId,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.tiny,
                    color: AppColors.mutedSlate,
                  ).copyWith(fontSize: 10.0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Align(
            alignment: Alignment.topRight,
            child: _buildActionButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (isBusy) {
      return SizedBox(
        width: 18.0,
        height: 18.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          color: theme.primaryGreen,
        ),
      );
    }

    final bool isConnect = action == ServerAction.connect;
    final String label = isConnect ? 'Connect' : 'Disconnect';
    final IconData icon = isConnect ? Icons.link : Icons.link_off;

    // Connect = filled/primary, Disconnect = outlined/neutral, so the two
    // states are visually distinct at a glance.
    final Color fg = isConnect ? theme.background : theme.textInputColor;
    final Color bg = isConnect ? theme.primaryGreen : Colors.transparent;
    final Color border = isConnect ? Colors.transparent : theme.border;

    return InkWell(
      onTap: onAction,
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.0, color: fg),
            const SizedBox(width: 4.0),
            Text(
              label,
              style: AppTypography.getTextStyle(
                context,
                AppTextType.tiny,
                color: fg,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}