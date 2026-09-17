import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF4834D4);

  // Secondary & Accents
  static const Color secondary = Color(0xFF00CEC9);
  static const Color accentGreen = Color(0xFF00B894);
  static const Color accentRed = Color(0xFFFF7675);
  static const Color accentYellow = Color(0xFFFDCB6E);

  // Call Specific Colors
  static const Color endCallRed = Color(0xFFD63031);
  static const Color acceptCallGreen = Color(0xFF00B894);
  static const Color activeIconBlue = Color(0xFF0984E3);

  // Backgrounds - Light Mode
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F2F6);
  static const Color lightTextPrimary = Color(0xFF2D3436);
  static const Color lightTextSecondary = Color(0xFF636E72);

  // Backgrounds - Dark Mode
  static const Color darkBackground = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1E1E2E);
  static const Color darkCard = Color(0xFF252538);
  static const Color darkTextPrimary = Color(0xFFF5F6FA);
  static const Color darkTextSecondary = Color(0xFFA4B0BE);

  // Status Colors
  static const Color onlineGreen = Color(0xFF2ECC71);
  static const Color offlineGrey = Color(0xFFB2BEC3);
  static const Color missedRed = Color(0xFFE74C3C);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF8E44AD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient callBackgroundGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
