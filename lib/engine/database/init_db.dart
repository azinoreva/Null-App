
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';

/// Creates and opens the application's encrypted SQLite database.
///
/// Responsibilities:
/// - Generate the database encryption key on first installation.
/// - Store the database encryption key in platform secure storage.
/// - Reuse the same key on subsequent launches.
/// - Configure SQLite encryption before Drift performs database work.
/// - Create the [AppDatabase] instance.
///
/// The rest of the application does not need to know anything about
/// SQLite encryption.
final class DatabaseInitializer {
  DatabaseInitializer._();

  static const _databaseFileName = 'null.db';
  static const _databaseKeyName = 'null.database.encryption.key';

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      // Uses Android Keystore-backed encrypted storage.
      resetOnError: false,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static AppDatabase? _database;

  /// Initializes the database.
  ///
  /// Calling this multiple times returns the same database instance.
  static Future<AppDatabase> initialize() async {
    final existing = _database;

    if (existing != null) {
      return existing;
    }

    final key = await _loadOrCreateDatabaseKey();
    final databaseFile = await _databaseFile();

    final executor = NativeDatabase.createInBackground(
      databaseFile,
      setup: (database) {
        _configureDatabaseEncryption(database, key);
        applyConcurrencyPragmas(database);
      },
    );

    final database = AppDatabase(executor);

    await database.customStatement('SELECT 1');

    _database = database;

    return database;
  }

  /// Closes the database and clears the in-process reference.
  ///
  /// The persistent database encryption key is intentionally NOT deleted.
  static Future<void> close() async {
    final database = _database;

    if (database == null) {
      return;
    }

    _database = null;

    await database.close();
  }

  /// Returns the path to the application's private database directory.
  static Future<String> _databasePath() async {
    final directory = await getApplicationSupportDirectory();

    final databaseDirectory = Directory(
      path.join(directory.path, 'database'),
    );

    if (!await databaseDirectory.exists()) {
      await databaseDirectory.create(
        recursive: true,
      );
    }

    return path.join(
      databaseDirectory.path,
      _databaseFileName,
    );
  }

  static Future<File> _databaseFile() async {
    final databasePath = await _databasePath();

    return File(databasePath);
  }

  /// Retrieves the existing database key or generates it on first launch.
  static Future<Uint8List> _loadOrCreateDatabaseKey() async {
    final storedKey = await _secureStorage.read(
      key: _databaseKeyName,
    );

    if (storedKey != null) {
      return _decodeKey(storedKey);
    }

    final key = await _generateDatabaseKey();
    final encodedKey = _encodeKey(key);

    await _secureStorage.write(
      key: _databaseKeyName,
      value: encodedKey,
    );

    // Verify persistence immediately. This prevents continuing with a key
    // that was generated successfully but could not actually be stored.
    final persistedKey = await _secureStorage.read(
      key: _databaseKeyName,
    );

    if (persistedKey == null) {
      throw StateError(
        'Unable to persist the database encryption key.',
      );
    }

    final persistedBytes = _decodeKey(persistedKey);

    if (!_constantTimeEquals(key, persistedBytes)) {
      throw StateError(
        'Database encryption key verification failed.',
      );
    }

    return key;
  }

  /// Generates a cryptographically secure 256-bit database key.
  static Future<Uint8List> _generateDatabaseKey() async {
    final algorithm = AesGcm.with256bits();

    final secretKey = await algorithm.newSecretKey();

    final bytes = await secretKey.extractBytes();

    if (bytes.length != 32) {
      throw StateError(
        'Generated database key must contain exactly 32 bytes.',
      );
    }

    return Uint8List.fromList(bytes);
  }

  /// Stores the key as hexadecimal text.
  ///
  /// The actual key is 32 bytes. Hex encoding is only used because secure
  /// storage stores strings.
  static String _encodeKey(Uint8List key) {
    if (key.length != 32) {
      throw ArgumentError.value(
        key.length,
        'key',
        'Database key must contain exactly 32 bytes.',
      );
    }

    const alphabet = '0123456789abcdef';
    final output = StringBuffer();

    for (final byte in key) {
      output.write(alphabet[(byte >> 4) & 0x0f]);
      output.write(alphabet[byte & 0x0f]);
    }

    return output.toString();
  }

  static Uint8List _decodeKey(String value) {
    if (value.length != 64) {
      throw StateError(
        'Stored database encryption key is invalid.',
      );
    }

    final output = Uint8List(32);

    for (var i = 0; i < 32; i++) {
      final high = _hexValue(value.codeUnitAt(i * 2));
      final low = _hexValue(value.codeUnitAt(i * 2 + 1));

      output[i] = (high << 4) | low;
    }

    return output;
  }

  static int _hexValue(int value) {
    if (value >= 0x30 && value <= 0x39) {
      return value - 0x30;
    }

    if (value >= 0x41 && value <= 0x46) {
      return value - 0x41 + 10;
    }

    if (value >= 0x61 && value <= 0x66) {
      return value - 0x61 + 10;
    }

    throw StateError(
      'Stored database encryption key contains invalid characters.',
    );
  }

  /// Configures SQLite encryption before Drift interacts with the database.
  ///
  /// SQLite3MultipleCiphers accepts the key through `PRAGMA hexkey`.
  ///
  /// The key is never stored in the SQLite database itself.
  static void _configureDatabaseEncryption(
    dynamic database,
    Uint8List key,
  ) {
    final encodedKey = _encodeKey(key);

    database.execute(
      "PRAGMA hexkey = '$encodedKey';",
    );
  }

  /// Applies the pragmas that keep concurrent SQLite writes from surfacing
  /// transient contention as errors.
  ///
  /// Drift opens the database in its own background isolate, and any other
  /// connection touching the same file has to contend for the single write
  /// lock SQLite allows. Without these settings a write that lands while
  /// another connection is mid-write fails immediately with `SQLITE_BUSY`
  /// ("database is locked", code 5).
  ///
  /// - `journal_mode = WAL` lets readers proceed while a writer holds the
  ///   write lock, instead of blocking on a rollback journal.
  /// - `busy_timeout` makes a writer wait for the lock to free up rather than
  ///   throwing the instant it is taken.
  /// - `synchronous = NORMAL` is the recommended durability pairing for WAL.
  ///
  /// Must run after [hexkey] has been set, since `journal_mode` touches the
  /// database file.
  static void applyConcurrencyPragmas(dynamic database) {
    database.execute('PRAGMA busy_timeout = 5000;');
    database.select('PRAGMA journal_mode = WAL;');
    database.execute('PRAGMA synchronous = NORMAL;');
  }

  static bool _constantTimeEquals(
    Uint8List a,
    Uint8List b,
  ) {
    if (a.length != b.length) {
      return false;
    }

    var difference = 0;

    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }

    return difference == 0;
  }
}
