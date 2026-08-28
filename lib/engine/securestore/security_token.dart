// Requires the `flutter_secure_storage` package — see vault_secure_storage.dart
// for the pubspec entry, same dependency covers both.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage key under which the post-registration security token is kept.
const String kSecurityTokenStorageKey = 'securityToken';

const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

/// Saves [token] to secure storage under [storageKey].
Future<void> saveSecurityToken(
  String token, {
  String storageKey = kSecurityTokenStorageKey,
}) {
  return _secureStorage.write(key: storageKey, value: token);
}

/// Reads the security token from secure storage, or null if unset.
Future<String?> getSecurityToken({
  String storageKey = kSecurityTokenStorageKey,
}) {
  return _secureStorage.read(key: storageKey);
}

/// True if a security token is currently stored under [storageKey].
Future<bool> hasSecurityToken({
  String storageKey = kSecurityTokenStorageKey,
}) {
  return _secureStorage.containsKey(key: storageKey);
}

/// Deletes the security token from secure storage, if any.
Future<void> deleteSecurityToken({
  String storageKey = kSecurityTokenStorageKey,
}) {
  return _secureStorage.delete(key: storageKey);
}