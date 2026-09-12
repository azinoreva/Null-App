// module name: shrink_image.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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
        ('Error: File does not exist at specified directory.');
        return null;
      }

      // 1. Read raw file bytes and decode into an Image object
      final Uint8List fileBytes = await file.readAsBytes();
      img.Image? originalImage = img.decodeImage(fileBytes);
      if (originalImage == null) {
        ('Error: Unable to decode image file.');
        return null;
      }

      // 2. Resize image to standard contact resolution (96x96 px)
      img.Image resizedImage = img.copyResize(
        originalImage,
        width: 96,
        height: 96,
        interpolation: img.Interpolation.cubic,
      );

      // 3. Calculate the maximum allowed binary size
      final int totalAllowedBytes = (targetKb * 1024).round();
      int targetBytes = totalAllowedBytes;

      if (toStringFlag) {
        // Account for the data URI prefix and Base64 inflation.
        const String prefix = 'data:image/webp;base64,'; // WebP MIME type
        final int allowedBase64Chars = totalAllowedBytes - prefix.length;
        // Every 3 binary bytes become 4 Base64 characters.
        targetBytes = (allowedBase64Chars * 3 / 4).floor();
      }

      // 4. Compress using WebP.
      final compressedBytes = img.encodeWebP(resizedImage);

      // 5. If even the lowest quality does not fit, fail gracefully
      if (compressedBytes.length > targetBytes) {
        ('Error: Could not compress image to the required size budget of $targetKb KB.');
        return null;
      }

      // 6. Build output results
      final Uint8List finalBlob = Uint8List.fromList(compressedBytes);
      String? finalBase64;

      if (toStringFlag) {
        finalBase64 = 'data:image/webp;base64,${base64Encode(compressedBytes)}';
      }

      return CompressedImageResult(
        blobBytes: finalBlob,
        base64String: finalBase64,
      );
    } catch (e) {
      ('Exception occurred during image processing: $e');
      return null;
    }
  }
}