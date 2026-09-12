// lib/services/storage_stats_service.dart
import 'dart:io';

import 'package:path_provider/path_provider.dart';
// Reading total/free *device* storage isn't something dart:io exposes on
// its own - it needs a plugin. `disk_space_plus` is a reasonable, actively
// maintained option; swap for whatever your project already uses if it's
// different. Add it to pubspec.yaml if it isn't there yet.
import 'package:disk_space_plus/disk_space_plus.dart';

const _videoExtensions = {'mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v', '3gp'};
const _audioExtensions = {'mp3', 'wav', 'aac', 'm4a', 'ogg', 'flac', 'wma'};
const _imageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'bmp'};

/// Breakdown of how much internal app storage is used, by media type, plus
/// how that compares to the device's total storage capacity.
class StorageBreakdown {
  final int videosBytes;
  final int audioBytes;
  final int imagesBytes;
  final int otherBytes;
  final int deviceTotalBytes;

  const StorageBreakdown({
    required this.videosBytes,
    required this.audioBytes,
    required this.imagesBytes,
    required this.otherBytes,
    required this.deviceTotalBytes,
  });

  /// Everything the app is using, across all categories.
  int get totalUsedBytes => videosBytes + audioBytes + imagesBytes + otherBytes;

  double get totalUsedGB => totalUsedBytes / (1024 * 1024 * 1024);
  double get videosGB => videosBytes / (1024 * 1024 * 1024);
  double get audioGB => audioBytes / (1024 * 1024 * 1024);
  double get imagesGB => imagesBytes / (1024 * 1024 * 1024);
  double get otherGB => otherBytes / (1024 * 1024 * 1024);
  double get deviceTotalGB => deviceTotalBytes / (1024 * 1024 * 1024);

  /// 0.0-1.0, clamped, for driving a progress bar.
  double get usedFraction =>
      deviceTotalBytes <= 0 ? 0.0 : (totalUsedBytes / deviceTotalBytes).clamp(0.0, 1.0);
}

class StorageStatsService {
  StorageStatsService._();

  /// Walks the app's internal `media/` folder (the same one
  /// `MediaStorageService` copies files into), sizes everything up by
  /// type, and pairs that with the device's total storage capacity.
  static Future<StorageBreakdown> computeAppStorageUsage() async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDir.path}/media');

    int videos = 0;
    int audio = 0;
    int images = 0;
    int other = 0;

    if (await mediaDir.exists()) {
      await for (final entity in mediaDir.list(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        int size;
        try {
          size = await entity.length();
        } catch (_) {
          continue; // file might've been deleted mid-scan; skip it.
        }

        final ext = entity.path.contains('.') ? entity.path.split('.').last.toLowerCase() : '';
        if (_videoExtensions.contains(ext)) {
          videos += size;
        } else if (_audioExtensions.contains(ext)) {
          audio += size;
        } else if (_imageExtensions.contains(ext)) {
          images += size;
        } else {
          other += size;
        }
      }
    }

    final deviceTotalBytes = await _getDeviceTotalBytes();

    return StorageBreakdown(
      videosBytes: videos,
      audioBytes: audio,
      imagesBytes: images,
      otherBytes: other,
      deviceTotalBytes: deviceTotalBytes,
    );
  }

  static Future<int> _getDeviceTotalBytes() async {
    try {
      final totalMB = await DiskSpacePlus.getTotalDiskSpace; // MB, per disk_space_plus
      if (totalMB == null) return 0;
      return (totalMB * 1024 * 1024).round();
    } catch (_) {
      // TODO: if `disk_space_plus`'s API differs from what's assumed here
      // (or you're using a different plugin), fix this call. Falling back
      // to 0 rather than throwing so the rest of the modal still renders.
      return 0;
    }
  }
}