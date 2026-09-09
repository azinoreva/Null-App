import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Contact card component.
///
///  - [avatarUrl]   : network image url for the avatar
///  - [displayName] : e.g. "Alice Johnson - Product Designer". If it
///                    contains a "-", everything before it is shown as the
///                    name and everything after as the subtitle/title. If
///                    there's no "-", the whole string is shown as the name
///                    with no subtitle.
///  - [isOnline]    : 0 = offline (grey dot), 1 = online (green dot)
class ContactCard extends StatelessWidget {
  final String avatarUrl;
  final String displayName;
  final int isOnline;

  const ContactCard({
    super.key,
    required this.avatarUrl,
    required this.displayName,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;
    final online = isOnline == 1;
    final statusColor = online ? AppColors.activeGreen : AppColors.mutedSlate;

    final dashIndex = displayName.indexOf('-');
    final String name;
    final String? title;
    if (dashIndex != -1) {
      name = displayName.substring(0, dashIndex).trim();
      final rawTitle = displayName.substring(dashIndex + 1).trim();
      title = rawTitle.isEmpty ? null : rawTitle;
    } else {
      name = displayName.trim();
      title = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22.0,
                backgroundColor: AppColors.neutralGray,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.background, width: 2.0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.body,
                    color: theme.textInputColor,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                if (title != null) ...[
                  const SizedBox(height: 2.0),
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.getTextStyle(
                      context,
                      AppTextType.tiny,
                      color: AppColors.mutedSlate,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}