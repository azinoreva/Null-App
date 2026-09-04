import 'package:flutter/material.dart';

enum AppTextType {
  largeTitle,
  title,
  body,
  tiny,
}

abstract class AppColors {
  // Base Colors
  static const Color haloRing = Color(0xFF54D454);
  static const Color activeGreen = Color(0xFF32FF32);

  // Light Mode Base
  static const Color lightGreen = Color(0xFF21A521);
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightBorder = Color(0xFF343842);

  // Dark Mode Base
  static const Color darkGreen = Color(0xFF5CE75C);
  static const Color darkBackground = Color(0xFF171A1F);
  static const Color darkBorder = Color(0xFF31383F);

  // Chat Colors
  static const Color lightChatMeBg = Color(0xFF99FF99);
  static const Color lightChatMeText = Color(0xFF000000);
  static const Color lightChatOtherBg = Color(0xFF000000);
  static const Color lightChatOtherText = Color(0xFFFFFFFF);

  static const Color darkChatMeBg = Color(0xFF99FF99);
  static const Color darkChatMeText = Color(0xFF000000);
  static const Color darkChatOtherBg = Color(0xFFF3F4F6);
  static const Color darkChatOtherText = Color(0xFF000000);

  // Named Text & UI Colors
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color neutralGray = Color(0xFFDEE1E6);
  static const Color offWhite = Color(0xFFF9F9FA);
  static const Color accentGreen = Color(0xFF26D962);
  static const Color mutedSlate = Color(0xFF9095A1);
  static const Color darkSlate = Color(0xFF6F7787); // Input Border & Placeholder Color
  static const Color popPink = Color(0xFFEA61AA);
  static const Color alertRed = Color(0xFFEF4343);
  static const Color disabledGray = Color(0xFF435843);
}

abstract class AppTypography {
  static const String fontRoboto = 'Roboto';
  static const String fontInter = 'Inter';

  // Responsive Font Size based on Platform (Desktop vs Mobile) and Orientation
  static double getFontSize(BuildContext context, AppTextType type) {
    final mediaQuery = MediaQuery.of(context);
    final isDesktop = mediaQuery.size.width >= 600;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // Adjust scale factor slightly for landscape view on mobile devices
    final double orientationScale = (!isDesktop && isLandscape) ? 0.9 : 1.0;

    switch (type) {
      case AppTextType.largeTitle:
        return (isDesktop ? 36.0 : 32.0) * orientationScale;
      case AppTextType.title:
        return (isDesktop ? 28.0 : 24.0) * orientationScale;
      case AppTextType.body:
        return (isDesktop ? 18.0 : 14.0) * orientationScale;
      case AppTextType.tiny:
        return (isDesktop ? 14.0 : 12.0) * orientationScale;
    }
  }

  static String getFontFamily(AppTextType type) {
    switch (type) {
      case AppTextType.largeTitle:
      case AppTextType.title:
        return fontRoboto;
      case AppTextType.body:
      case AppTextType.tiny:
        return fontInter;
    }
  }

  static TextStyle getTextStyle(
    BuildContext context, 
    AppTextType type, {
    Color? color,
  }) {
    return TextStyle(
      fontFamily: getFontFamily(type),
      fontSize: getFontSize(context, type),
      color: color,
    );
  }
}

class AppColorScheme extends ThemeExtension<AppColorScheme> {
  final Color primaryGreen;
  final Color background;
  final Color border;
  final Color haloRing;
  final Color chatMeBg;
  final Color chatMeText;
  final Color chatOtherBg;
  final Color chatOtherText;
  final Color buttonContentColor;
  final Color textInputColor;

  const AppColorScheme({
    required this.primaryGreen,
    required this.background,
    required this.border,
    required this.haloRing,
    required this.chatMeBg,
    required this.chatMeText,
    required this.chatOtherBg,
    required this.chatOtherText,
    required this.buttonContentColor,
    required this.textInputColor,
  });

  static const AppColorScheme light = AppColorScheme(
    primaryGreen: AppColors.lightGreen,
    background: AppColors.lightBackground,
    border: AppColors.lightBorder,
    haloRing: AppColors.haloRing,
    chatMeBg: AppColors.lightChatMeBg,
    chatMeText: AppColors.lightChatMeText,
    chatOtherBg: AppColors.lightChatOtherBg,
    chatOtherText: AppColors.lightChatOtherText,
    buttonContentColor: AppColors.pureWhite,
    textInputColor: AppColors.pureBlack,
  );

  static const AppColorScheme dark = AppColorScheme(
    primaryGreen: AppColors.darkGreen,
    background: AppColors.darkBackground,
    border: AppColors.darkBorder,
    haloRing: AppColors.haloRing,
    chatMeBg: AppColors.darkChatMeBg,
    chatMeText: AppColors.darkChatMeText,
    chatOtherBg: AppColors.darkChatOtherBg,
    chatOtherText: AppColors.darkChatOtherText,
    buttonContentColor: AppColors.pureBlack,
    textInputColor: AppColors.pureWhite,
  );

  @override
  AppColorScheme copyWith({
    Color? primaryGreen,
    Color? background,
    Color? border,
    Color? haloRing,
    Color? chatMeBg,
    Color? chatMeText,
    Color? chatOtherBg,
    Color? chatOtherText,
    Color? buttonContentColor,
    Color? textInputColor,
  }) {
    return AppColorScheme(
      primaryGreen: primaryGreen ?? this.primaryGreen,
      background: background ?? this.background,
      border: border ?? this.border,
      haloRing: haloRing ?? this.haloRing,
      chatMeBg: chatMeBg ?? this.chatMeBg,
      chatMeText: chatMeText ?? this.chatMeText,
      chatOtherBg: chatOtherBg ?? this.chatOtherBg,
      chatOtherText: chatOtherText ?? this.chatOtherText,
      buttonContentColor: buttonContentColor ?? this.buttonContentColor,
      textInputColor: textInputColor ?? this.textInputColor,
    );
  }

  @override
  AppColorScheme lerp(ThemeExtension<AppColorScheme>? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      primaryGreen: Color.lerp(primaryGreen, other.primaryGreen, t)!,
      background: Color.lerp(background, other.background, t)!,
      border: Color.lerp(border, other.border, t)!,
      haloRing: Color.lerp(haloRing, other.haloRing, t)!,
      chatMeBg: Color.lerp(chatMeBg, other.chatMeBg, t)!,
      chatMeText: Color.lerp(chatMeText, other.chatMeText, t)!,
      chatOtherBg: Color.lerp(chatOtherBg, other.chatOtherBg, t)!,
      chatOtherText: Color.lerp(chatOtherText, other.chatOtherText, t)!,
      buttonContentColor: Color.lerp(buttonContentColor, other.buttonContentColor, t)!,
      textInputColor: Color.lerp(textInputColor, other.textInputColor, t)!,
    );
  }
}