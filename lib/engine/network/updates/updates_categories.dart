import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main_server_client.dart';

/// Fetches and locally caches the sub-category list exposed by Null Service.
/// The list changes infrequently, so the network is checked at most once
/// every 30 days. Cached data remains available if a refresh fails.
class UpdatesCategoriesService {
  UpdatesCategoriesService._();

  static final UpdatesCategoriesService instance =
      UpdatesCategoriesService._();

  static const String boxName = 'updates_categories';
  static const String categoriesKey = 'categories_online_list';
  static const String _lastFetchKey = 'updates_categories_last_fetch';
  static const Duration refreshInterval = Duration(days: 30);

  Box<String>? _box;
  bool _refreshInProgress = false;

  Future<void> init() async {
    _box ??= await Hive.openBox<String>(boxName);
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('is_logged_in') ?? false) {
      await refreshIfDue();
    }
  }

  /// Returns the cached raw category JSON, or null before the first fetch.
  String? get categoriesOnlineList {
    final box = _box;
    if (box == null || !box.isOpen) return null;
    return box.get(categoriesKey);
  }

  /// Decoded route response, suitable for reading as a list of maps.
  List<dynamic>? get categories => categoriesOnlineList == null
      ? null
      : jsonDecode(categoriesOnlineList!) as List<dynamic>;

  /// Top-level category IDs in the route response, preserving backend order.
  List<String> get categoryIds {
    return categoryEntries.keys.toList(growable: false);
  }

  /// Backend category IDs mapped to their subcategory IDs.
  Map<String, List<String>> get categoryEntries {
    final result = <String, List<String>>{};
    for (final entry in categories ?? const <dynamic>[]) {
      if (entry is! Map) continue;
      for (final category in entry.entries) {
        final subcategories = category.value is List
            ? (category.value as List).map((item) => item.toString()).toList()
            : const <String>[];
        result[category.key.toString()] = subcategories;
      }
    }
    return result;
  }

  Future<void> refreshIfDue({DateTime? now}) async {
    if (_refreshInProgress) return;
    _refreshInProgress = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetchMillis = prefs.getInt(_lastFetchKey);
      final currentTime = now ?? DateTime.now();
      final isDue = lastFetchMillis == null ||
          currentTime.difference(
                DateTime.fromMillisecondsSinceEpoch(lastFetchMillis),
              ) >=
              refreshInterval;
      if (!isDue) return;

      try {
        final response = await MainServerClient.dio.get('/api/sub-categories');
        final data = response.data;
        if (data is! List) {
          throw const FormatException(
            'Expected /api/sub-categories to return a list.',
          );
        }
        final box = _box ??= await Hive.openBox<String>(boxName);
        await box.put(categoriesKey, jsonEncode(data));
        await prefs.setInt(_lastFetchKey, currentTime.millisecondsSinceEpoch);
      } on DioException {
        // Keep the previous cache and retry on a later app launch.
      } on FormatException {
        // Do not replace good cached data with an unexpected response.
      }
    } finally {
      _refreshInProgress = false;
    }
  }
}
