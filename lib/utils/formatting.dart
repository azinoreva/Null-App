import 'package:flutter/material.dart';

/// Parses a colour stored as "0xRRGGBB" or "#RRGGBB" into a [Color].
Color parseHexColour(String value) {
  var hex = value.trim().replaceAll('#', '').replaceAll('0x', '');
  if (hex.length == 6) hex = 'FF$hex';
  final parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? Colors.transparent : Color(parsed);
}

/// Formats an epoch-millis timestamp into a short label for the UI.
String formatChatTime(int timestampMillis) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestampMillis);
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final startOfDay = DateTime(date.year, date.month, date.day);
  final daysAgo = startOfToday.difference(startOfDay).inDays;

  if (daysAgo == 0) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
  if (daysAgo == 1) {
    return 'Yesterday';
  }
  if (daysAgo < 7) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}