// lib/services/media_storage_service.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Handles copying user-selected media into the app's own internal
/// "media" folder, so the app owns a private, durable copy instead of
/// depending on a path/URL that might disappear later (a temp picker
/// cache file, a remote link that expires, etc).
///
/// Requires the `path_provider` package - add it to pubspec.yaml if it
/// isn't already a dependency.
class MediaStorageService {
  MediaStorageService._();

  /// Copies whatever is at [sourceUrl] into the app's internal media
  /// folder and returns the new local path.
  ///
  /// [sourceUrl] can be either:
  ///  - a local file path (e.g. what an image/file picker returns), or
  ///  - an http(s) URL, which will be downloaded first.
  ///
  /// Callers should treat the returned string as the new "url" for this
  /// media going forward - store that, not the original [sourceUrl].
  static Future<String> copyMediaToInternalStorage(String sourceUrl) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDir.path}/media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final destinationPath = '${mediaDir.path}/${_newFileName(sourceUrl)}';
    final isRemote = sourceUrl.startsWith('http://') || sourceUrl.startsWith('https://');

    if (isRemote) {
      await _downloadToFile(sourceUrl, destinationPath);
    } else {
      final sourceFile = File(sourceUrl);
      if (!await sourceFile.exists()) {
        throw FileSystemException('Source media not found', sourceUrl);
      }
      await sourceFile.copy(destinationPath);
    }

    return destinationPath;
  }

  /// Saves downloaded media bytes into the app's internal media folder.
  static Future<String> saveBytesToInternalStorage(
    Uint8List bytes, {
    String extension = '.bin',
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDir.path}/media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final destinationPath =
        '${mediaDir.path}/${DateTime.now().microsecondsSinceEpoch}$extension';
    await File(destinationPath).writeAsBytes(bytes);
    return destinationPath;
  }

  /// Deletes a file previously returned by [copyMediaToInternalStorage].
  /// Safe to call even if the file no longer exists.
  static Future<void> deleteInternalMedia(String internalPath) async {
    final file = File(internalPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> _downloadToFile(String url, String destinationPath) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      final bytes = await response.fold<List<int>>(
        <int>[],
        (buffer, chunk) => buffer..addAll(chunk),
      );
      await File(destinationPath).writeAsBytes(bytes);
    } finally {
      client.close();
    }
  }

  static String _newFileName(String sourceUrl) {
    final cleanPath = sourceUrl.split('?').first; // strip any query string
    final originalName = cleanPath.split(RegExp(r'[\\/]')).last;
    final dotIndex = originalName.lastIndexOf('.');
    final extension = dotIndex == -1 ? '' : originalName.substring(dotIndex);
    return '${DateTime.now().microsecondsSinceEpoch}$extension';
  }
}