// module name: base64_tolerant
//
// The Null wire carries urlsafe base64 with no padding (the Python harness
// strips the trailing '='), but Dart's [base64Url.decode] rejects unpadded
// input with "Invalid length, must be multiple of four". Every value we read
// off the wire funnels through here so a 43-char key (or a ciphertext/nonce/
// mac) decodes instead of throwing.

import 'dart:convert';
import 'dart:typed_data';

/// Decodes [value] as base64 or base64url, tolerating missing padding and
/// either alphabet.
///
/// Throws [FormatException] when the input cannot be a base64 string.
Uint8List base64DecodeTolerant(String value) {
  final trimmed = value.trim();
  var normalized = trimmed.replaceAll('-', '+').replaceAll('_', '/');

  final remainder = normalized.length % 4;
  if (remainder == 1) {
    throw FormatException('Invalid base64 length', trimmed);
  }
  if (remainder != 0) {
    normalized = normalized.padRight(
      normalized.length + (4 - remainder),
      '=',
    );
  }

  return Uint8List.fromList(base64.decode(normalized));
}

/// Whether [value] looks like a base64/base64url string (padded or not).
bool isTolerantBase64(String value) {
  try {
    base64DecodeTolerant(value);
    return true;
  } on FormatException {
    return false;
  }
}
