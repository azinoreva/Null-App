// module name: shrink_image.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Container class to hold the output data formats for SQLite.
class CompressedImageResult {
  /// The raw bytes ready for a SQLite BLOB column.
  final Uint8List blobBytes;

  /// The Base64 string prefixed with data URI scheme.
  /// Null if [toStringFlag] was set to false.
  final String? base64String;

  CompressedImageResult({
    required this.blobBytes,
    this.base64String,
  });
}

/// Isolate-transferable description of one compression job. Kept as a plain
/// value type (only bytes + scalars) so it can cross the isolate boundary.
class _ImageJob {
  const _ImageJob({
    required this.fileBytes,
    required this.targetBytes,
    required this.toStringFlag,
  });

  final Uint8List fileBytes;
  final int targetBytes;
  final bool toStringFlag;
}

/// Decode + cubic-resize + WebP-encode. All of this is CPU-bound, so it runs
/// on a background isolate (via [compute]) to keep the UI thread free. Must be
/// a top-level function for [compute].
CompressedImageResult? _compressImageBytes(_ImageJob job) {
  final img.Image? originalImage = img.decodeImage(job.fileBytes);
  if (originalImage == null) return null;

  final img.Image resizedImage = img.copyResize(
    originalImage,
    width: 96,
    height: 96,
    interpolation: img.Interpolation.cubic,
  );

  final compressedBytes = img.encodeWebP(resizedImage);
  if (compressedBytes.length > job.targetBytes) return null;

  return CompressedImageResult(
    blobBytes: Uint8List.fromList(compressedBytes),
    base64String: job.toStringFlag
        ? 'data:image/webp;base64,${base64Encode(compressedBytes)}'
        : null,
  );
}

class ContactImageCompressor {
  /// Processes an image from a given file path or direct File object.
  ///
  /// - [imageInput]: Can be a [String] file path or a [File] object.
  /// - [toStringFlag]: If true, generates and returns the Base64 string alongside the BLOB.
  /// - [targetKb]: Strict size constraint budget (Defaults to 4.0 KB).
  /// Returns `null` if the input is invalid, file does not exist, or the image
  /// cannot be compressed within the constraints even at the lowest WebP quality.
  static Future<CompressedImageResult?> processImage({
    required Object imageInput,
    bool toStringFlag = false,
    double targetKb = 4.0,
  }) async {
    try {
      File file;
      if (imageInput is String) {
        file = File(imageInput);
      } else if (imageInput is File) {
        file = imageInput;
      } else {
        throw ArgumentError('imageInput must be either a String path or a File object.');
      }

      if (!await file.exists()) {
        return null;
      }

      // File IO stays on this isolate; the decode/resize/encode work is
      // handed off to a background isolate below.
      final Uint8List fileBytes = await file.readAsBytes();

      // Calculate the maximum allowed binary size.
      final int totalAllowedBytes = (targetKb * 1024).round();
      int targetBytes = totalAllowedBytes;

      if (toStringFlag) {
        // Account for the data URI prefix and Base64 inflation.
        const String prefix = 'data:image/webp;base64,'; // WebP MIME type
        final int allowedBase64Chars = totalAllowedBytes - prefix.length;
        // Every 3 binary bytes become 4 Base64 characters.
        targetBytes = (allowedBase64Chars * 3 / 4).floor();
      }

      return await compute(
        _compressImageBytes,
        _ImageJob(
          fileBytes: fileBytes,
          targetBytes: targetBytes,
          toStringFlag: toStringFlag,
        ),
      );
    } catch (e) {
      return null;
    }
  }
}
