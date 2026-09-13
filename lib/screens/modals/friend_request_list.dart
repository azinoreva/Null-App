import 'package:flutter/material.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/buttons/send_button.dart';
import 'friend_request.dart';

/// Everything needed to render one row here AND to open the detailed
/// [FriendRequestModal] for it - so "View" can hand the full picture
/// straight over without re-fetching anything.
class FriendRequestData {
  final String avatarUrl;
  final String name;
  final String username;
  final String message;
  final String receivedLabel; // e.g. "2 hours ago" - shown in the list row
  final String messageTimeLabel; // e.g. "10:26 AM" - shown in the detail modal

  const FriendRequestData({
    required this.avatarUrl,
    required this.name,
    required this.username,
    required this.message,
    required this.receivedLabel,
    required this.messageTimeLabel,
  });
}

/// "Friend Requests" list modal.
///
/// Renders each request via a reusable [_FriendRequestRow] card. Tapping
/// "View" opens [FriendRequestModal] (built previously), passing along
/// everything from that request's [FriendRequestData] - no separate fetch,
/// no duplicated fields.
///
/// Decoupled from any data/settings module: [onAcceptRequest] /
/// [onDeclineRequest] handle a single request (called from inside the
/// detail modal), while [onAcceptAll] / [onDeclineAll] handle the bulk
/// actions at the bottom. All four are required callbacks the caller
/// implements.
class FriendRequestsListModal extends StatefulWidget {
  final List<FriendRequestData> requests;
  final Future<void> Function(FriendRequestData request) onAcceptRequest;
  final Future<void> Function(FriendRequestData request) onDeclineRequest;
  final Future<void> Function() onAcceptAll;
  final Future<void> Function() onDeclineAll;
  final VoidCallback? onClose;

  const FriendRequestsListModal({
    super.key,
    required this.requests,
    required this.onAcceptRequest,
    required this.onDeclineRequest,
    required this.onAcceptAll,
    required this.onDeclineAll,
    this.onClose,
  });

  @override
  State<FriendRequestsListModal> createState() => _FriendRequestsListModalState();
}

class _FriendRequestsListModalState extends State<FriendRequestsListModal> {
  late List<FriendRequestData> _requests;
  bool _isBulkActing = false;

  @override
  void initState() {
    super.initState();
    _requests = List<FriendRequestData>.from(widget.requests);
  }

  void _handleClose() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _handleView(FriendRequestData request) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16.0),
        child: FriendRequestModal(
          avatarUrl: request.avatarUrl,
          name: request.name,
          username: request.username,
          message: request.message,
          timeText: request.messageTimeLabel,
          onAccept: () async {
            await widget.onAcceptRequest(request);
            if (mounted) setState(() => _requests.remove(request));
          },
          onDecline: () async {
            await widget.onDeclineRequest(request);
            if (mounted) setState(() => _requests.remove(request));
          },
        ),
      ),
    );
  }

  Future<void> _handleAcceptAll() async {
    if (_isBulkActing) return;
    setState(() => _isBulkActing = true);
    await widget.onAcceptAll();
    if (!mounted) return;
    setState(() {
      _requests.clear();
      _isBulkActing = false;
    });
  }

  Future<void> _handleDeclineAll() async {
    if (_isBulkActing) return;
    setState(() => _isBulkActing = true);
    await widget.onDeclineAll();
    if (!mounted) return;
    setState(() {
      _requests.clear();
      _isBulkActing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

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
            children: [
              Container(
                width: 34.0,
                height: 34.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.primaryGreen.withAlpha(35),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.people_alt_outlined, size: 18.0, color: theme.primaryGreen),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Friend Requests',
                style: AppTypography.getTextStyle(
                  context,
                  AppTextType.body,
                  color: theme.textInputColor,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: theme.primaryGreen,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  '${_requests.length}',
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.tiny,
                    color: theme.buttonContentColor,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _handleClose,
                customBorder: const CircleBorder(),
                child: Icon(Icons.close, color: AppColors.mutedSlate),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Divider(color: theme.border, height: 1.0),

          // List
          Flexible(
            child: _requests.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(
                      child: Text(
                        'No pending requests',
                        style: AppTypography.getTextStyle(
                          context,
                          AppTextType.body,
                          color: AppColors.mutedSlate,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 4.0),
                    itemCount: _requests.length,
                    separatorBuilder: (context, index) => Divider(color: theme.border, height: 1.0),
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      return _FriendRequestRow(
                        theme: theme,
                        request: request,
                        onView: () => _handleView(request),
                      );
                    },
                  ),
          ),

          if (_requests.isNotEmpty) ...[
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isBulkActing ? null : _handleDeclineAll,
                    icon: Icon(Icons.cancel_outlined, size: 18.0, color: AppColors.pureWhite),
                    label: Text(
                      'Decline All',
                      style: AppTypography.getTextStyle(
                        context,
                        AppTextType.body,
                        color: AppColors.pureWhite,
                      ),
                    ),
                    style: ButtonStyle(
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(theme.border),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                      ),
                      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 14.0)),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: SendButton(
                    text: 'Accept All',
                    icon: Icons.check,
                    iconPosition: IconPosition.left,
                    isLocked: _isBulkActing,
                    onPressed: _handleAcceptAll,
                    textType: AppTextType.body,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FriendRequestRow extends StatelessWidget {
  final AppColorScheme theme;
  final FriendRequestData request;
  final VoidCallback onView;

  const _FriendRequestRow({
    required this.theme,
    required this.request,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.0,
            backgroundColor: AppColors.neutralGray,
            backgroundImage: NetworkImage(request.avatarUrl),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.name,
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.body,
                    color: theme.textInputColor,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  request.receivedLabel,
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.tiny,
                    color: AppColors.mutedSlate,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          SendButton(
            text: 'View',
            onPressed: onView,
            textType: AppTextType.tiny,
          ),
        ],
      ),
    );
  }
}