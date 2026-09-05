import 'package:flutter/material.dart';

class AppLogoIcon extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppLogoIcon({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final assetPath = isDark
        ? 'assets/images/dark_image_trans_icon.png'
        : 'assets/images/light_image_trans_icon.png';

    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
    );
  }
}