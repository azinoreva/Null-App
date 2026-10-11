import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TEMPORARY PURGE — call once from `main()`, then delete this file and the
/// call site. Wipes every trace of local state for this app.
Future<void> nukeAllLocalData() async {
  print('💥 OBLITERATING ALL LOCAL DATA...');

  // 1. Shared preferences (is_logged_in, has_signed_up, servers, ...).
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  // 2. Secure storage (tokens, vault, and the database encryption key).
  const secureStorage = FlutterSecureStorage();
  await secureStorage.deleteAll();

  // 3. Hive boxes (updates_cache, pending_contacts) plus their lock files.
  await Hive.initFlutter();
  await Hive.deleteFromDisk();

  // 4. Encrypted Drift database: <app support>/database/null.db (+ -wal/-shm).
  final supportDir = await getApplicationSupportDirectory();
  final databaseDir = Directory(path.join(supportDir.path, 'database'));
  if (await databaseDir.exists()) {
    await databaseDir.delete(recursive: true);
  }

  // 5. Media copied into the app's internal storage.
  final documentsDir = await getApplicationDocumentsDirectory();
  final mediaDir = Directory(path.join(documentsDir.path, 'media'));
  if (await mediaDir.exists()) {
    await mediaDir.delete(recursive: true);
  }

  print('✅ ALL DATA PURGED. REMOVE THESE LINES NOW!');
}
