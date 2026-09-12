// lib/settings/app_settings.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'categories.dart';

/// Theme options for the app.
enum AppThemeMode { light, dark }

/// Central place for every default value.
class SettingsDefaults {
  static const AppThemeMode themeMode = AppThemeMode.dark;

  static const bool autoSync = true;
  static const bool typingIndicator = true;
  static const bool pushNotifications = true;
  static const bool messageSound = true;
  static const bool vibration = false;

  static const String? automaticMessage = null;
  static const bool allowFriendRequests = true;
  static const List<Categories> feedControl = <Categories>[];

  static const String? profilePicture = null;
  static const String nickname = 'User';
  static const String? title = null;
  static const String? bio = null;

  static const bool useBiometrics = false;
  static const bool appLock = false;
  static const int? lockTimer = null; // seconds

  static const bool ephemeralUpdates = false;
}

/// Persisted, observable app settings backed by SharedPreferences.
///
/// Usage:
///   await AppSettings.init();
///   final settings = AppSettings.instance;
///   settings.setNickname('Ada');
///   settings.addListener(() => ...);           // or ListenableBuilder
class AppSettings extends ChangeNotifier {
  AppSettings._(this._prefs);

  // ---- Keys ----
  static const _kTheme = 'settings.theme_mode';
  static const _kAutoSync = 'settings.auto_sync';
  static const _kTypingIndicator = 'settings.typing_indicator';
  static const _kPushNotifications = 'settings.push_notifications';
  static const _kMessageSound = 'settings.message_sound';
  static const _kVibration = 'settings.vibration';
  static const _kAutomaticMessage = 'settings.automatic_message';
  static const _kAutomaticMedia = 'settings.automatic_media';
  static const _kAllowFriendRequests = 'settings.allow_friend_requests';
  static const _kFeedControl = 'settings.feed_control';
  static const _kProfilePicture = 'settings.profile_picture';
  static const _kNickname = 'settings.nickname';
  static const _kTitle = 'settings.title';
  static const _kBio = 'settings.bio';
  static const _kUseBiometrics = 'settings.use_biometrics';
  static const _kAppLock = 'settings.app_lock';
  static const _kLockTimer = 'settings.lock_timer';
  static const _kEphemeralUpdates = 'settings.ephemeral_updates';

  static AppSettings? _instance;
  final SharedPreferences _prefs;

  /// Loads SharedPreferences and creates the singleton. Safe to call twice.
  static Future<AppSettings> init() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = AppSettings._(prefs);
    return _instance!;
  }

  static AppSettings get instance {
    final i = _instance;
    if (i == null) {
      throw StateError(
        'AppSettings not initialized. Call `await AppSettings.init()` first.',
      );
    }
    return i;
  }

  // =====================================================================
  // 1. App theme
  // =====================================================================
  AppThemeMode get themeMode {
    final raw = _prefs.getString(_kTheme);
    return raw == AppThemeMode.light.name
        ? AppThemeMode.light
        : SettingsDefaults.themeMode;
  }

  Future<void> setThemeMode(AppThemeMode value) async {
    await _prefs.setString(_kTheme, value.name);
    notifyListeners();
  }

  bool get isDarkMode => themeMode == AppThemeMode.dark;

  Future<void> setIsDarkMode(bool dark) =>
      setThemeMode(dark ? AppThemeMode.dark : AppThemeMode.light);

  // =====================================================================
  // 2. Auto sync
  // =====================================================================
  bool get autoSync =>
      _prefs.getBool(_kAutoSync) ?? SettingsDefaults.autoSync;

  Future<void> setAutoSync(bool value) async {
    await _prefs.setBool(_kAutoSync, value);
    notifyListeners();
  }

  // =====================================================================
  // 3. Typing indicator
  // =====================================================================
  bool get typingIndicator =>
      _prefs.getBool(_kTypingIndicator) ?? SettingsDefaults.typingIndicator;

  Future<void> setTypingIndicator(bool value) async {
    await _prefs.setBool(_kTypingIndicator, value);
    notifyListeners();
  }

  // =====================================================================
  // 4. Push notifications
  // =====================================================================
  bool get pushNotifications =>
      _prefs.getBool(_kPushNotifications) ??
      SettingsDefaults.pushNotifications;

  Future<void> setPushNotifications(bool value) async {
    await _prefs.setBool(_kPushNotifications, value);
    notifyListeners();
  }

  // =====================================================================
  // 5. Message sound
  // =====================================================================
  bool get messageSound =>
      _prefs.getBool(_kMessageSound) ?? SettingsDefaults.messageSound;

  Future<void> setMessageSound(bool value) async {
    await _prefs.setBool(_kMessageSound, value);
    notifyListeners();
  }

  // =====================================================================
  // 6. Vibration
  // =====================================================================
  bool get vibration =>
      _prefs.getBool(_kVibration) ?? SettingsDefaults.vibration;

  Future<void> setVibration(bool value) async {
    await _prefs.setBool(_kVibration, value);
    notifyListeners();
  }

  // =====================================================================
  // 7. Automatic message (text or none)
  // =====================================================================
  String? get automaticMessage =>
      _prefs.getString(_kAutomaticMessage) ?? SettingsDefaults.automaticMessage;

  Future<void> setAutomaticMessage(String? value) async {
    final v = value?.trim();
    if (v == null || v.isEmpty) {
      await _prefs.remove(_kAutomaticMessage);
    } else {
      await _prefs.setString(_kAutomaticMessage, v);
    }
    notifyListeners();
  }

  List<String> get automaticMedia =>
      _prefs.getStringList(_kAutomaticMedia) ?? const <String>[];

  Future<void> setAutomaticMedia(List<String> value) async {
    await _prefs.setStringList(_kAutomaticMedia, value);
    notifyListeners();
  }

  // =====================================================================
  // 8. Allow friend requests
  // =====================================================================
  bool get allowFriendRequests =>
      _prefs.getBool(_kAllowFriendRequests) ??
      SettingsDefaults.allowFriendRequests;

  Future<void> setAllowFriendRequests(bool value) async {
    await _prefs.setBool(_kAllowFriendRequests, value);
    notifyListeners();
  }

  // =====================================================================
  // 9. Feed control (list of Categories)
  // =====================================================================
  List<Categories> get feedControl {
    final raw = _prefs.getStringList(_kFeedControl);
    if (raw == null) return List.of(SettingsDefaults.feedControl);
    return raw
        .map(Categories.fromId)
        .whereType<Categories>()
        .toList(growable: false);
  }

  Future<void> setFeedControl(List<Categories> value) async {
    final ids = value.map((c) => c.id).toList(growable: false);
    await _prefs.setStringList(_kFeedControl, ids);
    notifyListeners();
  }

  bool isFeedCategoryEnabled(Categories c) => feedControl.contains(c);

  Future<void> toggleFeedCategory(Categories c) async {
    final current = feedControl.toSet();
    current.contains(c) ? current.remove(c) : current.add(c);
    await setFeedControl(current.toList(growable: false));
  }

  /// Categories the user has chosen, in enum-declaration order.
  List<Categories> get feedControlOrdered {
    final selected = feedControl.toSet();
    return Categories.values.where(selected.contains).toList(growable: false);
  }

  // =====================================================================
  // 10. Profile picture (internal URL / path)
  // =====================================================================
  String? get profilePicture =>
      _prefs.getString(_kProfilePicture) ?? SettingsDefaults.profilePicture;

  Future<void> setProfilePicture(String? value) async {
    final v = value?.trim();
    if (v == null || v.isEmpty) {
      await _prefs.remove(_kProfilePicture);
    } else {
      await _prefs.setString(_kProfilePicture, v);
    }
    notifyListeners();
  }

  // =====================================================================
  // 11. Nickname
  // =====================================================================
  String get nickname =>
      _prefs.getString(_kNickname) ?? SettingsDefaults.nickname;

  Future<void> setNickname(String value) async {
    final v = value.trim();
    await _prefs.setString(
      _kNickname,
      v.isEmpty ? SettingsDefaults.nickname : v,
    );
    notifyListeners();
  }

  // =====================================================================
  // 12. Title
  // =====================================================================
  String? get title => _prefs.getString(_kTitle) ?? SettingsDefaults.title;

  Future<void> setTitle(String? value) async {
    final v = value?.trim();
    if (v == null || v.isEmpty) {
      await _prefs.remove(_kTitle);
    } else {
      await _prefs.setString(_kTitle, v);
    }
    notifyListeners();
  }

  // =====================================================================
  // 13. Bio
  // =====================================================================
  String? get bio => _prefs.getString(_kBio) ?? SettingsDefaults.bio;

  Future<void> setBio(String? value) async {
    final v = value?.trim();
    if (v == null || v.isEmpty) {
      await _prefs.remove(_kBio);
    } else {
      await _prefs.setString(_kBio, v);
    }
    notifyListeners();
  }

  // =====================================================================
  // 14. Use biometrics
  // =====================================================================
  bool get useBiometrics =>
      _prefs.getBool(_kUseBiometrics) ?? SettingsDefaults.useBiometrics;

  Future<void> setUseBiometrics(bool value) async {
    await _prefs.setBool(_kUseBiometrics, value);
    notifyListeners();
  }

  // =====================================================================
  // 15. App lock
  // =====================================================================
  bool get appLock => _prefs.getBool(_kAppLock) ?? SettingsDefaults.appLock;

  Future<void> setAppLock(bool value) async {
    await _prefs.setBool(_kAppLock, value);
    notifyListeners();
  }

  /// True when the app should actually gate the UI.
  bool get isLockEnabled => appLock && (useBiometrics || lockTimer != null);

  // =====================================================================
  // 16. Lock timer (seconds; null = disabled)
  // =====================================================================
  int? get lockTimer => _prefs.getInt(_kLockTimer) ?? SettingsDefaults.lockTimer;

  Future<void> setLockTimer(int? seconds) async {
    if (seconds == null || seconds <= 0) {
      await _prefs.remove(_kLockTimer);
    } else {
      await _prefs.setInt(_kLockTimer, seconds);
    }
    notifyListeners();
  }

  /// Convenience for timers.
  Duration? get lockTimerDuration {
    final s = lockTimer;
    return (s == null || s <= 0) ? null : Duration(seconds: s);
  }

  // =====================================================================
  // 17. Ephemeral updates
  // =====================================================================
  bool get ephemeralUpdates =>
      _prefs.getBool(_kEphemeralUpdates) ?? SettingsDefaults.ephemeralUpdates;

  Future<void> setEphemeralUpdates(bool value) async {
    await _prefs.setBool(_kEphemeralUpdates, value);
    notifyListeners();
  }

  // =====================================================================
  // Bulk operations
  // =====================================================================

  /// Clears every setting and restores defaults.
  Future<void> resetAll() async {
    final keys = <String>[
      _kTheme,
      _kAutoSync,
      _kTypingIndicator,
      _kPushNotifications,
      _kMessageSound,
      _kVibration,
      _kAutomaticMessage,
      _kAutomaticMedia,
      _kAllowFriendRequests,
      _kFeedControl,
      _kProfilePicture,
      _kNickname,
      _kTitle,
      _kBio,
      _kUseBiometrics,
      _kAppLock,
      _kLockTimer,
      _kEphemeralUpdates,
    ];
    for (final k in keys) {
      await _prefs.remove(k);
    }
    notifyListeners();
  }

  /// Snapshot of all current values (handy for debug screens / tests).
  Map<String, Object?> toMap() => <String, Object?>{
        'themeMode': themeMode.name,
        'autoSync': autoSync,
        'typingIndicator': typingIndicator,
        'pushNotifications': pushNotifications,
        'messageSound': messageSound,
        'vibration': vibration,
        'automaticMessage': automaticMessage,
        'automaticMedia': automaticMedia,
        'allowFriendRequests': allowFriendRequests,
        'feedControl': feedControl.map((c) => c.id).toList(),
        'profilePicture': profilePicture,
        'nickname': nickname,
        'title': title,
        'bio': bio,
        'useBiometrics': useBiometrics,
        'appLock': appLock,
        'lockTimer': lockTimer,
        'ephemeralUpdates': ephemeralUpdates,
      };
}