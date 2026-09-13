// lib/services/message_sound.dart
import 'package:audioplayers/audioplayers.dart';

import '../functions/settings/settings.dart';

/// Optional hook for reporting audio failures (Crashlytics, logger, etc.).
/// Signature is intentionally narrow so callers can't leak internals.
typedef SoundErrorHandler = void Function(Object error, StackTrace stack);

/// Plays the short message notification sound from assets.
///
/// Respects [AppSettings.messageSound] — if the user has turned sounds off,
/// [play] is a no-op unless you pass `force: true`.
class MessageSound {
  MessageSound._({SoundErrorHandler? onError}) : _onError = onError;

  static final MessageSound instance = MessageSound._();

  static const String _assetPath = 'assets/message_sound.mp3';

  /// Reused player so rapid messages don't spawn new audio sessions.
  final AudioPlayer _player = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop)
    ..setPlayerMode(PlayerMode.lowLatency);

  /// Override in `main()` if you want failures reported somewhere.
  /// Default is a silent no-op so production never prints.
  SoundErrorHandler _onError = _ignore;

  static void _ignore(Object error, StackTrace stack) {}

  bool _ready = false;

  /// Set from `main()` (or a DI container) to wire up real error reporting.
  ///
  ///   MessageSound.instance.onError = (e, s) =>
  ///       FirebaseCrashlytics.instance.recordError(e, s);
  set onError(SoundErrorHandler handler) => _onError = handler;

  /// Optional: call once at startup to warm up the asset.
  Future<void> preload() async {
    if (_ready) return;
    try {
      await _player.setSource(AssetSource(_assetPath));
      _ready = true;
    } catch (e, st) {
      _onError(e, st);
    }
  }

  /// Plays the message sound.
  ///
  /// Set [force] to true to ignore the user's "message sound" setting
  /// (useful for previews in the settings screen).
  Future<void> play({bool force = false}) async {
    if (!force && !AppSettings.instance.messageSound) return;

    try {
      // Restart from the beginning if a play is already in flight.
      await _player.stop();
      await _player.play(AssetSource(_assetPath));
    } catch (e, st) {
      _onError(e, st);
    }
  }

  /// Call from app dispose / logout if you want to free resources.
  Future<void> dispose() async {
    await _player.dispose();
  }
}