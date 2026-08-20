import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'app_database.dart';

/// Initializes and returns the application database.
///
/// This uses the native SQLite backend and stores the database file
/// in the app's documents directory.
Future<AppDatabase> initDatabase() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'null_app_database.sqlite'));
  return AppDatabase(NativeDatabase(file));
}