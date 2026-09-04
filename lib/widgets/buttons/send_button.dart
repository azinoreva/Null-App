import 'package:flutter/material.dart';
import '../app_theme.dart';

enum IconPosition { left, right }

class SendButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final IconPosition iconPosition;
  final VoidCallback? onPressed;
  final bool isLocked;
  final AppTextType textType;

  const SendButton({
    super.key,
    required this.text,
    this.icon,
    this.iconPosition = IconPosition.right,
    this.onPressed,
    this.isLocked = false,
    this.textType = AppTextType.body,
  });

  @override
  Widget build(BuildContext context) {
    final themeExtension = Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

    final contentColor = isLocked
        ? themeExtension.buttonContentColor.withAlpha(128)
        : themeExtension.buttonContentColor;

    final baseFontSize = AppTypography.getFontSize(context, textType);

    final List<Widget> rowChildren = [];

    final labelWidget = Text(
      text,
      textAlign: TextAlign.center,
      style: AppTypography.getTextStyle(
        context,
        textType,
        color: contentColor,
      ),
    );

    final iconWidget = icon != null
        ? Icon(
            icon,
            size: baseFontSize * 1.2,
            color: contentColor,
          )
        : null;

    if (iconWidget != null && iconPosition == IconPosition.left) {
      rowChildren.addAll([iconWidget, const SizedBox(width: 8.0)]);
    }

    rowChildren.add(Flexible(child: labelWidget));

    if (iconWidget != null && iconPosition == IconPosition.right) {
      rowChildren.addAll([const SizedBox(width: 8.0), iconWidget]);
    }

    return ElevatedButton(
      onPressed: isLocked ? null : onPressed,
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(0),
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
        backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (isLocked || states.contains(WidgetState.disabled)) {
            return AppColors.disabledGray;
          }
          if (states.contains(WidgetState.pressed)) {
            return AppColors.activeGreen;
          }
          return themeExtension.primaryGreen;
        }),
        overlayColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.hovered)) {
            return Colors.white.withAlpha(38);
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