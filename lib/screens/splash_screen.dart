import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final Widget destination;

  const SplashScreen({
    super.key,
    required this.prefs,
    required this.destination,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const String _videoAsset = 'asset:///assets/splash_video.mp4';
  static const String _imageAsset = 'assets/splash_image.png';

  /// How long the launch video plays.
  static const Duration _videoDuration = Duration(seconds: 10);

  /// How long the still image is held before routing onward.
  static const Duration _imageHoldDuration = Duration(seconds: 2);

  final Player _player = Player();
  late final VideoController _videoController;
  late final AnimationController _animationController;
  late final Animation<Color> _colorAnimation;

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Timer? _transitionTimer;
  Timer? _imageTimer;

  bool _videoReady = false;
  bool _showImage = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // Must be created eagerly: the controller wires up the video output, and
    // the `Video` widget below renders through it. Creating it lazily inside
    // `build()` deadlocks readiness detection.
    _videoController = VideoController(_player);

    _animationController = AnimationController(
      vsync: this,
      duration: _videoDuration,
    );
    _colorAnimation = _BackgroundColorTween().animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    _animationController.forward();

    // Reveal the video once the decoder reports real dimensions.
    _subscriptions.add(
      _player.stream.videoParams.listen((params) {
        final bool ready = (params.w ?? 0) > 0 && (params.h ?? 0) > 0;
        if (ready && !_videoReady && mounted) {
          setState(() => _videoReady = true);
        }
      }),
    );

    // Fall back to the still image if the video cannot be played.
    _subscriptions.add(
      _player.stream.error.listen((_) => _fallBackToImage()),
    );

    _player.open(Media(_videoAsset), play: true).catchError((_) {
      _fallBackToImage();
    });

    _scheduleTransition();
  }

  void _fallBackToImage() {
    if (_showImage || _navigated || !mounted) return;
    setState(() => _showImage = true);
  }

  void _scheduleTransition() {
    _transitionTimer = Timer(_videoDuration, () {
      if (!mounted || _navigated) return;
      setState(() {
        _showImage = true;
        _videoReady = false;
      });
      _player.pause();
      _imageTimer = Timer(_imageHoldDuration, _finish);
    });
  }

  void _finish() {
    if (!mounted || _navigated) return;
    _navigated = true;
    widget.prefs.setBool('is_launched', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => widget.destination),
    );
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    _imageTimer?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _animationController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: _colorAnimation.value),
          if (_showImage)
            Center(
              child: Image.asset(
                _imageAsset,
                fit: BoxFit.contain,
                width: size.width * 0.8,
              ),
            )
          else ...[
            Video(
              controller: _videoController,
              fit: BoxFit.contain,
              controls: NoVideoControls,
            ),
            if (!_videoReady)
              const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}

// Custom Tween for background color (works on all Flutter versions)
class _BackgroundColorTween extends Tween<Color> {
  // `begin`/`end` must be non-null: Tween.transform returns them directly at
  // t == 0.0 / 1.0 and would otherwise throw on the `as Color` cast.
  _BackgroundColorTween() : super(begin: Colors.black, end: Colors.black);

  @override
  Color lerp(double t) {
    if (t <= 0.2) return Colors.black;
    if (t <= 0.3) {
      final localT = (t - 0.2) / 0.1;
      return Color.lerp(Colors.black, Colors.white, localT)!;
    }
    if (t <= 0.7) return Colors.white;
    if (t <= 0.8) {
      final localT = (t - 0.7) / 0.1;
      return Color.lerp(Colors.white, Colors.black, localT)!;
    }
    return Colors.black;
  }
}
