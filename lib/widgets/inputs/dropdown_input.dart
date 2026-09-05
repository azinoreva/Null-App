import 'package:flutter/material.dart';
import '../app_theme.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final AppTextType textType;

  const CustomDropdownField({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.hintText,
    this.textType = AppTextType.body,
  });

  @override
  Widget build(BuildContext context) {
    final themeExtension = Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

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

    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      style: textStyle,
      dropdownColor: themeExtension.background, // Dropdown popup menu background
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.darkSlate,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        filled: false, // Ensures transparent input background
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