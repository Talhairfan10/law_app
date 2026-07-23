import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary dark backgrounds
  static const Color backgroundDark = Color(0xFF0D0B1A);
  static const Color backgroundMedium = Color(0xFF1A1530);
  static const Color backgroundLight = Color(0xFF241E3D);
  static const Color surfaceDark = Color(0xFF15122A);

  // Gold / Amber accent palette
  static const Color goldPrimary = Color(0xFFD4A843);
  static const Color goldLight = Color(0xFFE8C96A);
  static const Color goldDark = Color(0xFFB8892E);
  static const Color goldMuted = Color(0xFF9A7530);
  static const Color goldShimmer = Color(0xFFF5E1A4);

  // Text colors
  static const Color textPrimary = Color(0xFFF5F0E8);
  static const Color textSecondary = Color(0xFFB8B0C8);
  static const Color textMuted = Color(0xFF8A8098);
  static const Color textGold = Color(0xFFD4A843);

  // Accent colors
  static const Color purpleAccent = Color(0xFF6B4FA0);
  static const Color purpleLight = Color(0xFF8B6FC0);
  static const Color purpleDark = Color(0xFF3D2D6B);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1530), Color(0xFF0D0B1A), Color(0xFF0A0816)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFD4A843), Color(0xFFE8C96A), Color(0xFFD4A843)],
  );

  static const LinearGradient goldShieldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE8C96A), Color(0xFFD4A843), Color(0xFFB8892E)],
  );

  static const LinearGradient heroOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC0D0B1A), Color(0xFF0D0B1A)],
    stops: [0.0, 0.6, 1.0],
  );
}
