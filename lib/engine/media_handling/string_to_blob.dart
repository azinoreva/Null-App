//module name: string_to_blob

import 'dart:convert';
import 'dart:typed_data';

/// Converts a Base64-encoded string (optionally with data URI prefix) to a Uint8List blob.
/// Returns null if the input is invalid or empty.
Uint8List? base64ToBlob(String base64String) {
  if (base64String.isEmpty) return null;

  try {
    // Strip data URI prefix if present (e.g., "data:image/webp;base64,...")
    String cleanBase64 = base64String;
    if (base64String.contains(',')) {
      final parts = base64String.split(',');
      cleanBase64 = parts.length > 1 ? parts[1] : parts[0];
    }

    // Decode to bytes
    final bytes = base64Decode(cleanBase64);
    return Uint8List.fromList(bytes);
  } catch (e) {
    ('Error decoding Base64: $e');
    return null;
  }
}