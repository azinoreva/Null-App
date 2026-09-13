import 'package:flutter/material.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/buttons/send_button.dart';

/// Everything needed to render one connected server row.
class ServerData {
  final String name;
  final String ipAddress;
  final String description;
  final bool isConnected;

  const ServerData({
    required this.name,
    required this.ipAddress,
    required this.description,
    this.isConnected = true,
  });
}

/// "Connected Servers" screen.
///
/// Full-bleed like the mockup (status bar visible, no rounded popup card)
/// rather than a dialog - built the same way as CreatePostScreen. No back
/// arrow, just a close "X" and a "Done" button, matching the design.
///
/// Decoupled: [onDeleteServer] is called (and the row removed optimistically)
/// when the trash icon is tapped; [onDone] fires when "Done" is pressed.
/// Both are left for the caller to actually implement.
class ConnectedServersModal extends StatefulWidget {
  final List<ServerData> servers;
  final Future<void> Function(ServerData server) onDeleteServer;
  final VoidCallback? onDone;
  final VoidCallback? onClose;

  const ConnectedServersModal({
    super.key,
    required this.servers,
    required this.onDeleteServer,
    this.onDone,
    this.onClose,
  });

  @override
  State<ConnectedServersModal> createState() => _ConnectedServersModalState();
}

class _ConnectedServersModalState extends State<ConnectedServersModal> {
  late List<ServerData> _servers;
  final Set<ServerData> _deleting = {};

  @override
  void initState() {
    super.initState();
    _servers = List<ServerData>.from(widget.servers);
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

  Future<void> _handleDelete(ServerData server) async {
    if (_deleting.contains(server)) return;
    setState(() => _deleting.add(server));
    await widget.onDeleteServer(server);
    if (!mounted) return;
    setState(() {
      _servers.remove(server);
      _deleting.remove(server);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

    return Container(
      color: theme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
              child: Row(
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
                    child: Icon(Icons.dns_outlined, size: 18.0, color: theme.primaryGreen),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connected Servers',
                          style: AppTypography.getTextStyle(
                            context,
                            AppTextType.body,
                            color: theme.textInputColor,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Servers you're currently connected to",
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
            ),
            Divider(color: theme.border, height: 1.0),

            Expanded(
              child: _servers.isEmpty
                  ? Center(
                      child: Text(
                        'No connected servers',
                        style: AppTypography.getTextStyle(
                          context,
                          AppTextType.body,
                          color: AppColors.mutedSlate,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _servers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                      itemBuilder: (context, index) {
                        final server = _servers[index];
                        return _ServerCard(
                          theme: theme,
                          server: server,
                          isDeleting: _deleting.contains(server),
                          onDelete: () => _handleDelete(server),
                        );
                      },
                    ),
            ),

            Divider(color: theme.border, height: 1.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: SendButton(
                  text: 'Done',
                  onPressed: _handleDone,
                  textType: AppTextType.body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerCard extends StatelessWidget {
  final AppColorScheme theme;
  final ServerData server;
  final bool isDeleting;
  final VoidCallback onDelete;

  const _ServerCard({
    required this.theme,
    required this.server,
    required this.isDeleting,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = server.isConnected ? AppColors.activeGreen : AppColors.mutedSlate;
    final statusLabel = server.isConnected ? 'NODE CONNECTION ACTIVE' : 'NODE DISCONNECTED';

    return Container(
      decoration: BoxDecoration(
        color: theme.border.withAlpha(70),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 10.0),
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
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              server.name,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.getTextStyle(
                                context,
                                AppTextType.body,
                                color: theme.textInputColor,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Container(
                            width: 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                          ),
                        ],
                      ),
                      Text(
                        server.ipAddress,
                        style: AppTypography.getTextStyle(
                          context,
                          AppTextType.tiny,
                          color: AppColors.mutedSlate,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        server.description,
                        style: AppTypography.getTextStyle(
                          context,
                          AppTextType.tiny,
                          color: AppColors.mutedSlate,
                        ).copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                isDeleting
                    ? SizedBox(
                        width: 18.0,
                        height: 18.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: theme.primaryGreen,
                        ),
                      )
                    : InkWell(
                        onTap: onDelete,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(Icons.delete_outline, size: 20.0, color: theme.textInputColor),
                        ),
                      ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: theme.background.withAlpha(150),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14.0),
                bottomRight: Radius.circular(14.0),
              ),
            ),
            child: Text(
              statusLabel,
              style: AppTypography.getTextStyle(
                context,
                AppTextType.tiny,
                color: AppColors.mutedSlate,
              ).copyWith(letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}