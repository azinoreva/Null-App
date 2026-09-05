import 'package:flutter/material.dart';
import '../app_theme.dart';

enum IconPosition { left, right }

class TransparentButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final IconPosition iconPosition;
  final VoidCallback? onPressed;
  final AppTextType textType;

  const TransparentButton({
    super.key,
    required this.text,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.onPressed,
    this.textType = AppTextType.body,
  });

  @override
  Widget build(BuildContext context) {
    // #54D454 color used for text, icon, border, and translucent background
    const brandGreen = AppColors.haloRing;
    final backgroundColor = brandGreen.withOpacity(0.11);

    final baseFontSize = AppTypography.getFontSize(context, textType);

    final labelWidget = Text(
      text,
      textAlign: TextAlign.center,
      style: AppTypography.getTextStyle(
        context,
        textType,
        color: brandGreen,
      ),
    );

    final iconWidget = icon != null
        ? Icon(
            icon,
            size: baseFontSize * 1.2,
            color: brandGreen,
          )
        : null;

    final List<Widget> rowChildren = [];

    if (iconWidget != null && iconPosition == IconPosition.left) {
      rowChildren.addAll([iconWidget, const SizedBox(width: 8.0)]);
    }

    rowChildren.add(Flexible(child: labelWidget));

    if (iconWidget != null && iconPosition == IconPosition.right) {
      rowChildren.addAll([const SizedBox(width: 8.0), iconWidget]);
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(backgroundColor),
        side: WidgetStateProperty.all(
          BorderSide(
            color: brandGreen.withOpacity(0.35),
            width: 1.0,
          ),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(
            horizontal: baseFontSize * 1.2,
            vertical: baseFontSize * 0.8,
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.hovered)) {
            return brandGreen.withOpacity(0.08);
          }
          if (states.contains(WidgetState.pressed)) {
            return brandGreen.withOpacity(0.18);
          }
          return null;
        }),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: rowChildren,
      ),
    );
  }
}