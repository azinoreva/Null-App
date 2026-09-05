import 'package:flutter/material.dart';
import '../app_theme.dart';

class ConversationListItem extends StatelessWidget {
  final String displayName;
  final String lastMessage;
  final String time;
  final String avatarUrl;
  final Color colour; // Outer ring color
  final int unreadCount;
  final int mentions;
  final bool isMuted;
  final bool isPinned;
  final int status; // 0: offline, 1: online, 2: away, 3: busy

  const ConversationListItem({
    super.key,
    this.displayName = 'Unknown',
    required this.lastMessage,
    required this.time,
    required this.avatarUrl,
    required this.colour,
    this.unreadCount = 0,
    this.mentions = 0,
    this.isMuted = false,
    this.isPinned = false,
    this.status = 0,
  });

  @override
  Widget build(BuildContext context) {
    final themeExtension =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

    return Container(
      width: double.infinity,
      height: 85.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvatarStack(themeExtension),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: AppTypography.getTextStyle(
                          context,
                          AppTextType.body,
                          color: themeExtension.textInputColor,
                        ).copyWith(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    _buildStatusIcons(),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  lastMessage,
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.body,
                    color: AppColors.mutedSlate,
                  ).copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          _buildTrailingData(context, themeExtension),
        ],
      ),
    );
  }

  Widget _buildAvatarStack(AppColorScheme themeExtension) {
    return SizedBox(
      width: 64.0,
      height: 64.0,
      child: Stack(
        children: [
          // Outer colored ring
          Container(
            width: 64.0,
            height: 64.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colour,
                width: 3.0,
              ),
            ),
            padding: const EdgeInsets.all(2.0), // Space between ring and image
            child: ClipOval(
              child: Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.neutralGray,
                  child: Icon(
                    Icons.person,
                    color: themeExtension.textInputColor,
                  ),
                ),
              ),
            ),
          ),
          // Status Indicator
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 16.0,
              height: 16.0,
              decoration: BoxDecoration(
                color: _getStatusColor(),
                shape: BoxShape.circle,
                border: Border.all(
                  color: themeExtension.background, // Match background to cut out
                  width: 2.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case 1:
        return const Color(0xFF2EB82E); // Online (Green)
      case 2:
        return const Color(0xFFFFC107); // Away (Yellow)
      case 3:
        return const Color(0xFFF44336); // Busy (Red)
      case 0:
      default:
        return const Color(0xFFDEE1E6); // Offline (Grey)
    }
  }

  Widget _buildStatusIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isPinned) ...[
          const Icon(
            Icons.push_pin_outlined,
            color: AppColors.haloRing, // #00BD00
            size: 16.0,
          ),
          const SizedBox(width: 6.0),
        ],
        if (isMuted) ...[
          const Icon(
            Icons.notifications_off_outlined,
            color: AppColors.haloRing,
            size: 16.0,
          ),
          const SizedBox(width: 6.0),
        ],
        if (mentions > 0) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '@',
                style: TextStyle(
                  color: AppColors.haloRing,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -2),
                child: Text(
                  mentions.toString(),
                  style: const TextStyle(
                    color: AppColors.haloRing,
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6.0),
        ],
      ],
    );
  }

  Widget _buildTrailingData(
      BuildContext context, AppColorScheme themeExtension) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          time,
          style: AppTypography.getTextStyle(
            context,
            AppTextType.tiny,
            color: AppColors.mutedSlate,
          ).copyWith(fontSize: 11.0),
        ),
        const SizedBox(height: 6.0),
        if (unreadCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: const Color(0xFF2EB82E), // Green success color
              borderRadius: BorderRadius.circular(10.0),
            ),
            constraints: const BoxConstraints(
              minWidth: 20.0,
              minHeight: 20.0,
            ),
            child: Center(
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        else
          const SizedBox(height: 20.0), // Placeholder to maintain alignment
      ],
    );
  }
}