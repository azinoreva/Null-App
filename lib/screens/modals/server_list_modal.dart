import 'package:flutter/material.dart';
import '../../utils/server_model.dart' as model;
import '../../widgets/app_theme.dart';
import '../../widgets/buttons/send_button.dart';

/// The modal's view of [model.ServerType], plus an `other` bucket so a server
/// whose type isn't one the backend is expected to send still appears in the
/// list instead of silently disappearing.
enum ServerType { public, private, other }

/// Which action the buttons on each server card should offer.
/// Passed in separately from the [ServerInfo] list, since it applies to
/// the whole modal rather than to any individual server.
enum ServerAction { connect, disconnect }

/// The fields this modal needs, read out of the server JSON. Both the
/// directory response and the locally persisted `ServerConfig` produce the
/// same keys, so the same factory works for either.
class ServerInfo {
  final String serverId;
  final String serverName;
  final String serverUrl;
  final ServerType serverType;

  /// Free-form description of the server.
  final String about;

  /// Whether the server is annotated.
  final bool annotated;

  /// Whether the server is switched off and shouldn't be contacted.
  final bool disabled;

  final String? location;

  /// Never null - an absent category list simply reads as empty.
  final List<String> categories;

  const ServerInfo({
    required this.serverId,
    required this.serverName,
    required this.serverUrl,
    required this.serverType,
    this.about = '',
    this.annotated = false,
    this.disabled = false,
    this.location,
    this.categories = const [],
  });

  /// Safe to call with the full server object; anything not listed here is
  /// ignored.
  factory ServerInfo.fromJson(Map<String, dynamic> json) {
    return ServerInfo(
      serverId: json['serverId'] as String? ?? '',
      serverName: json['serverName'] as String? ?? '',
      serverUrl: json['serverUrl'] as String? ?? '',
      serverType: _parseServerType(json['serverType']),
      about: json['about'] as String? ?? '',
      annotated: json['annotated'] as bool? ?? false,
      disabled: json['disabled'] as bool? ?? false,
      location: json['location'] as String?,
      categories: (json['categories'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
    );
  }

  static ServerType _parseServerType(Object? raw) =>
      switch (model.ServerType.tryFromJson(raw)) {
        model.ServerType.public => ServerType.public,
        model.ServerType.private => ServerType.private,
        null => ServerType.other,
      };
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

class _ServerCard extends StatefulWidget {
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
  State<_ServerCard> createState() => _ServerCardState();
}

class _ServerCardState extends State<_ServerCard> {
  /// Whether the details panel is showing. Kept per-card so opening one
  /// server doesn't collapse the rest.
  bool _expanded = false;

  AppColorScheme get theme => widget.theme;
  ServerInfo get server => widget.server;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: theme.border.withAlpha(70),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Icon(Icons.computer,
                    size: 18.0, color: theme.primaryGreen),
              ),
              const SizedBox(width: 12.0),
              // Tapping anywhere on the identity block reveals the rest of
              // what the server told us about itself.
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  borderRadius: BorderRadius.circular(8.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
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
                ),
              ),
              const SizedBox(width: 8.0),
              Align(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildExpandButton(),
                    const SizedBox(width: 8.0),
                    _buildActionButton(context),
                  ],
                ),
              ),
            ],
          ),
          if (_expanded) ...[
            const SizedBox(height: 12.0),
            Divider(color: theme.border, height: 1.0),
            const SizedBox(height: 12.0),
            _buildDetails(context),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandButton() {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Icon(
          _expanded ? Icons.expand_less : Icons.expand_more,
          size: 20.0,
          color: AppColors.mutedSlate,
        ),
      ),
    );
  }

  /// Everything the server directory reported beyond its name and address.
  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (server.about.trim().isNotEmpty)
          _DetailRow(
            label: 'About',
            value: server.about,
            valueStyle: AppTypography.getTextStyle(
              context,
              AppTextType.tiny,
              color: theme.textInputColor,
            ),
          ),
        if (server.location != null && server.location!.trim().isNotEmpty)
          _DetailRow(
            label: 'Location',
            value: server.location!,
            valueStyle: AppTypography.getTextStyle(
              context,
              AppTextType.tiny,
              color: theme.textInputColor,
            ),
          ),
        _DetailRow(
          label: 'Categories',
          child: server.categories.isEmpty
              ? Text(
                  'None',
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.tiny,
                    color: AppColors.mutedSlate,
                  ),
                )
              : Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: server.categories
                      .map((category) => _CategoryChip(
                            theme: theme,
                            label: category,
                          ))
                      .toList(),
                ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            _StatusFlag(
              theme: theme,
              label: 'Annotated',
              isOn: server.annotated,
            ),
            const SizedBox(width: 8.0),
            _StatusFlag(
              theme: theme,
              label: 'Disabled',
              isOn: server.disabled,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (widget.isBusy) {
      return SizedBox(
        width: 18.0,
        height: 18.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          color: theme.primaryGreen,
        ),
      );
    }

    final bool isConnect = widget.action == ServerAction.connect;
    final String label = isConnect ? 'Connect' : 'Disconnect';
    final IconData icon = isConnect ? Icons.link : Icons.link_off;

    // Connect = filled/primary, Disconnect = outlined/neutral, so the two
    // states are visually distinct at a glance.
    final Color fg = isConnect ? theme.background : theme.textInputColor;
    final Color bg = isConnect ? theme.primaryGreen : Colors.transparent;
    final Color border = isConnect ? Colors.transparent : theme.border;

    return InkWell(
      onTap: widget.onAction,
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

/// A label/value pair in the expanded details panel.
class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? child;
  final TextStyle? valueStyle;

  const _DetailRow({
    required this.label,
    this.value,
    this.child,
    this.valueStyle,
  }) : assert(value != null || child != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.getTextStyle(
              context,
              AppTextType.tiny,
              color: AppColors.mutedSlate,
            ).copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4.0),
          child ??
              Text(
                value!,
                style: valueStyle ??
                    AppTypography.getTextStyle(
                      context,
                      AppTextType.tiny,
                      color: Theme.of(context)
                          .extension<AppColorScheme>()
                          ?.textInputColor,
                    ),
              ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final AppColorScheme theme;
  final String label;

  const _CategoryChip({required this.theme, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: theme.primaryGreen.withAlpha(35),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        label,
        style: AppTypography.getTextStyle(
          context,
          AppTextType.tiny,
          color: theme.primaryGreen,
        ),
      ),
    );
  }
}

/// An on/off flag, e.g. Annotated / Disabled.
class _StatusFlag extends StatelessWidget {
  final AppColorScheme theme;
  final String label;
  final bool isOn;

  const _StatusFlag({
    required this.theme,
    required this.label,
    required this.isOn,
  });

  @override
  Widget build(BuildContext context) {
    final colour = isOn ? theme.primaryGreen : AppColors.mutedSlate;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: colour.withAlpha(35),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: colour.withAlpha(120)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOn ? Icons.check_circle : Icons.remove_circle_outline,
            size: 12.0,
            color: colour,
          ),
          const SizedBox(width: 4.0),
          Text(
            label,
            style: AppTypography.getTextStyle(
              context,
              AppTextType.tiny,
              color: colour,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}