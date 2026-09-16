import 'package:flutter/material.dart';
import '../app_theme.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final AppTextType textType;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final int? maxLines;
  final Widget? suffixIcon;

  const CustomInputField({
    super.key,
    this.controller,
    this.hintText,
    this.textType = AppTextType.body,
    this.onChanged,
    this.obscureText = false,
    this.maxLines = 1,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final themeExtension = Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;
    
    // Dynamic text style according to screen context and orientation
    final textStyle = AppTypography.getTextStyle(
      context,
      textType,
      color: themeExtension.textInputColor,
    );

    final hintStyle = AppTypography.getTextStyle(
      context,
      textType,
      color: AppColors.darkSlate, // Fixed #6f7787 for placeholder
    );

    const borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)), // 4px curve radius
      borderSide: BorderSide(
        color: AppColors.darkSlate, // Fixed #6f7787 for border
        width: 1.0,
      ),
    );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      maxLines: maxLines,
      style: textStyle,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        suffixIcon: suffixIcon,
        filled: false, // Ensures transparent background
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 12.0,
        ),
        enabledBorder: borderStyle,
        focusedBorder: borderStyle.copyWith(
          borderSide: const BorderSide(
            color: AppColors.darkSlate,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}