import 'dart:convert';

import 'package:flutter/material.dart';

/// Resolves a stored avatar value into an [ImageProvider].
///
/// Stored avatars are either a base64 `data:` URI (see the `avatar` columns in
/// the contacts/groups tables), a plain `http(s)` URL, or empty. `NetworkImage`
/// cannot fetch `data:` URIs on mobile/desktop, so those are decoded here and
/// rendered with [MemoryImage]. When no avatar is available we fall back to a
/// deterministic DiceBear image seeded by [seed] so the same contact always
/// shows the same picture.
ImageProvider avatarImageProvider(String? avatar, {String seed = ''}) {
  final value = avatar?.trim() ?? '';

  if (value.startsWith('data:')) {
    final commaIndex = value.indexOf(',');
    if (commaIndex != -1) {
      try {
        final bytes = base64Decode(value.substring(commaIndex + 1));
        return MemoryImage(bytes);
      } on FormatException {
        // Fall through to the fallback below.
      }
    }
  } else if (value.isNotEmpty) {
    return NetworkImage(value);
  }

  return NetworkImage(
    'https://api.dicebear.com/7.x/avataaars/png?seed='
    '${Uri.encodeComponent(seed)}&size=128',
  );
}
