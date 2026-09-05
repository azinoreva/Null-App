import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
  late VideoPlayerController _videoController;
  late AnimationController _animationController;
  late Animation<Color> _colorAnimation;
  bool _showImage = false;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/splash_video.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
      });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _colorAnimation = _BackgroundColorTween().animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    _animationController.forward();

    // After 10 seconds, show image, set flag, and navigate
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showImage = true;
        });
        _videoController.pause();

        // Mark as launched
        widget.prefs.setBool('is_launched', true);

        // Navigate to DecisionScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => widget.destination,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _animationController.dispose();
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
          Center(
            child: _showImage
                ? Image.asset(
                    'assets/splash_image.png',
                    fit: BoxFit.contain,
                    width: size.width * 0.8,
                  )
                : _videoController.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: VideoPlayer(_videoController),
                      )
                    : const CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}

// Custom Tween for background color (works on all Flutter versions)
class _BackgroundColorTween extends Tween<Color> {
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