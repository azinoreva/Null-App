import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _bgAnimationController;
  late Animation<Color?> _bgColorAnimation;
  bool _showImage = false;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/splash_video.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
      });

    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _bgColorAnimation = ColorTweenSequence<Color?>([
      ColorTweenSequenceItem(
        tween: ColorTween(begin: Colors.black, end: Colors.black),
        weight: 20,
      ),
      ColorTweenSequenceItem(
        tween: ColorTween(begin: Colors.black, end: Colors.white),
        weight: 10,
      ),
      ColorTweenSequenceItem(
        tween: ColorTween(begin: Colors.white, end: Colors.white),
        weight: 40,
      ),
      ColorTweenSequenceItem(
        tween: ColorTween(begin: Colors.white, end: Colors.black),
        weight: 10,
      ),
      ColorTweenSequenceItem(
        tween: ColorTween(begin: Colors.black, end: Colors.black),
        weight: 20,
      ),
    ]).animate(_bgAnimationController)
      ..addListener(() {
        setState(() {});
      });

    _bgAnimationController.forward();

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showImage = true;
        });
        _videoController.pause();
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: _bgColorAnimation.value ?? Colors.black,
          ),
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
          Positioned(
            top: size.height * 0.12,
            left: 0,
            right: 0,
            child: Text(
              'Stay in Control',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: size.width * 0.08,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black45,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.10,
            left: 0,
            right: 0,
            child: Text(
              'Made with V',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w300,
                shadows: const [
                  Shadow(
                    blurRadius: 8,
                    color: Colors.black45,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}