import 'package:flutter/material.dart';
import '../app_theme.dart';

class SquareFeatureButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onPressed;
  final double size;

  const SquareFeatureButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onPressed,
    this.size = 160.0, // Default size to maintain the square ratio
  });

  @override
  Widget build(BuildContext context) {
    final themeExtension =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;
    
    // Determine the halo background color based on the current brightness
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final haloBgColor = isDark 
        ? const Color(0xFF23282F) // Dark grayish halo for dark mode
        : AppColors.neutralGray.withOpacity(0.6); // Light gray halo for light mode

    return Material(
      color: themeExtension.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: themeExtension.border,
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAlignment.center,
              children: [
                // Icon with Colored Halo
                Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: haloBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.haloRing,
                    size: 32.0,
                  ),
                ),
                const SizedBox(height: 16.0),
                
                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.body,
                    color: themeExtension.textInputColor,
                  ).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                
                // Explanation / Subtitle
                Text(
                  subtitle.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.tiny,
                    color: AppColors.mutedSlate,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}