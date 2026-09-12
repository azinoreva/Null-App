import 'package:flutter/material.dart';
import '../../widgets/app_theme.dart';
import '../../engine/media_handling/storage_stat_service.dart';

enum MediaCategory { videos, audio, images }

/// "Storage" modal.
///
/// Loads its data by calling `StorageStatsService.computeAppStorageUsage()`
/// itself on open (that's the "different module" function that walks the
/// app's media folder and reads device storage). [onDeleteCategory] is an
/// empty stub you can wire up later to actually clear out a category's
/// files (and re-run the scan afterward).
class StorageModal extends StatefulWidget {
  final void Function(MediaCategory category)? onDeleteCategory;
  final VoidCallback? onClose;

  const StorageModal({
    super.key,
    this.onDeleteCategory,
    this.onClose,
  });

  @override
  State<StorageModal> createState() => _StorageModalState();
}

class _StorageModalState extends State<StorageModal> {
  late Future<StorageBreakdown> _breakdownFuture;

  @override
  void initState() {
    super.initState();
    _breakdownFuture = StorageStatsService.computeAppStorageUsage();
  }

  // ---- Stub: wire up actual file deletion later ----
  void _handleDelete(MediaCategory category) {
    // TODO: delete the files for `category` (e.g. via
    // MediaStorageService), then call `_refresh()` to re-scan.
    widget.onDeleteCategory?.call(category);
  }
  // ----------------------------------------------------

  void _refresh() {
    setState(() {
      _breakdownFuture = StorageStatsService.computeAppStorageUsage();
    });
  }

  void _handleClose() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  String _formatGB(double gb) => '${gb.toStringAsFixed(1)} GB';

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
              Expanded(
                child: Text(
                  'Storage',
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.title,
                    color: theme.textInputColor,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              InkWell(
                onTap: _handleClose,
                customBorder: const CircleBorder(),
                child: Icon(Icons.close, color: AppColors.mutedSlate),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Divider(color: theme.border, height: 1.0),
          const SizedBox(height: 16.0),

          FutureBuilder<StorageBreakdown>(
            future: _breakdownFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: CircularProgressIndicator(color: theme.primaryGreen),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    "Couldn't read storage usage.",
                    style: AppTypography.getTextStyle(
                      context,
                      AppTextType.body,
                      color: AppColors.mutedSlate,
                    ),
                  ),
                );
              }

              final breakdown = snapshot.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total used
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Used',
                        style: AppTypography.getTextStyle(
                          context,
                          AppTextType.body,
                          color: theme.textInputColor,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        breakdown.deviceTotalBytes > 0
                            ? '${_formatGB(breakdown.totalUsedGB)} / ${_formatGB(breakdown.deviceTotalGB)}'
                            : _formatGB(breakdown.totalUsedGB),
                        style: AppTypography.getTextStyle(
                          context,
                          AppTextType.tiny,
                          color: AppColors.mutedSlate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: LinearProgressIndicator(
                      value: breakdown.usedFraction,
                      minHeight: 8.0,
                      backgroundColor: theme.border,
                      color: theme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  _StorageRow(
                    theme: theme,
                    icon: Icons.videocam_outlined,
                    title: 'Videos',
                    sizeLabel: _formatGB(breakdown.videosGB),
                    onDelete: () => _handleDelete(MediaCategory.videos),
                  ),
                  const SizedBox(height: 10.0),
                  _StorageRow(
                    theme: theme,
                    icon: Icons.music_note_outlined,
                    title: 'Audio',
                    sizeLabel: _formatGB(breakdown.audioGB),
                    onDelete: () => _handleDelete(MediaCategory.audio),
                  ),
                  const SizedBox(height: 10.0),
                  _StorageRow(
                    theme: theme,
                    icon: Icons.image_outlined,
                    title: 'Images',
                    sizeLabel: _formatGB(breakdown.imagesGB),
                    onDelete: () => _handleDelete(MediaCategory.images),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StorageRow extends StatelessWidget {
  final AppColorScheme theme;
  final IconData icon;
  final String title;
  final String sizeLabel;
  final VoidCallback onDelete;

  const _StorageRow({
    required this.theme,
    required this.icon,
    required this.title,
    required this.sizeLabel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.border.withAlpha(70),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Row(
        children: [
          Container(
            width: 36.0,
            height: 36.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.primaryGreen.withAlpha(35),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, size: 18.0, color: theme.primaryGreen),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.body,
                    color: theme.textInputColor,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  sizeLabel,
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
            onTap: onDelete,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Icon(Icons.delete_outline, size: 20.0, color: theme.textInputColor),
            ),
          ),
        ],
      ),
    );
  }
}