import 'package:flutter/material.dart';

class AppColors {
  static const Color dynamicBg = Colors.white;
  static const Color dynamicCardBg = Color(0xFFF8FAFC);
  static const Color dynamicText = Colors.black;
  static const Color dynamicBorder = Color(0xFFD4D4D4);
  static const Color dynamicSubtitle = Color(0xFF757575);
  static const Color buttonDisabled = Color(0xFFF0F0F0);
  static const Color buttonDisabledText = Color(0xFFFFFFFF);

  static const Color gradientStart = Color(0xFF001951);
  static const Color gradientEnd = Color(0xFF0038B7);

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientStart, gradientEnd],
    stops: [0.0, 0.7],
  );

  static const Color secondary_color = Color(0xFF64748B);

  static const Color primary = Color(0xFF2563EB);

  static const Color secondary = Color(0xFF60A5FA);

  static const Color textDark = Color(0xFF1E1E1E);

  static const Color black = Color(0xFF1E1E1E);

  static const Color textSubtitle = Color(0xCC575757);

  static const Color border = Color(0xFFEBEBEB);

  static const Color grey = Color(0xFFBDBDBD);

  static const Color iconGreen = Color(0xFF1B824B);

  static const Color red = Color(0xFFBE000C);

  static const Color primaryLight = Color(0xFFFBE9F7);
}
