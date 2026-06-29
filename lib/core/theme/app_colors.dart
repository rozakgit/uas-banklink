import 'package:flutter/material.dart';

class AppColors {
  // Finance App Blue Brand Colors
  static const Color bluePrimary = Color(0xFF5A58FF);
  static const Color blueGradientStart = Color(0xFF6C63FF);
  static const Color blueGradientEnd = Color(0xFF4A40FF);
  static const Color blueLight = Color(0xFFE2E4FF);
  
  // Light Theme Colors
  static const Color lightBg = Color(0xFFF8F9FE);
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1E1E2D);
  static const Color lightTextSecondary = Color(0xFF8A8A9E);
  static const Color lightLine = Color(0xFFEAEAF4);
  static const Color lightCardActionBg = Color(0xFFEDEEF8); // For quick actions like Topup, Bills

  // Dark Theme Colors
  static const Color darkBg = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFA0A0B2);
  static const Color darkLine = Color(0xFF2A2A3E);
  static const Color darkCardActionBg = Color(0xFF24243D);

  // Semantic
  static const Color success = Color(0xFF34C759);
  static const Color danger = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);

  // Gradients
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blueGradientStart, blueGradientEnd],
  );

  // Shadows
  static List<BoxShadow> shadowCardLight = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 10),
    ),
  ];
  
  static List<BoxShadow> shadowCardDark = [
    BoxShadow(
      color: Color(0x20000000),
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 10),
    ),
  ];

  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: bluePrimary.withOpacity(0.4),
      blurRadius: 15,
      spreadRadius: 0,
      offset: Offset(0, 5),
    ),
  ];

  // Old semantic compatibility (if needed by other pages)
  static const Color primary = bluePrimary;
  static const Color primaryLight = blueLight;
  static const Color primaryDark = blueGradientStart;
  static const Color primarySurface = Color(0xFF152315);
  static const Color neonGreen = Color(0xFFDFF26E);
  static const Color darkGreen = Color(0xFFAACF31);
  static const Color red = danger;
  static const Color green = success;
  static const Color amber = warning;
  static const Color violet = Color(0xFFD0BCFF);
  
  static const Color bg = lightBg; // Default
  static const Color ink = lightTextPrimary;
  static const Color line = lightLine;
  static const Color line2 = lightLine;
  static const Color slate600 = Color(0xFFC5C9AF);
  static const Color slate500 = lightTextSecondary;
  static const Color slate400 = Color(0xFF444935);
  static const Color slate300 = Color(0xFF2A3829);
  static const Color white = Colors.white;

  static List<BoxShadow> shadowCard = shadowCardLight;
  static List<BoxShadow> shadowSoft = shadowCardLight;

  // Tone map for FeatureIcon (Legacy)
  static Map<String, List<Color>> tones = {
    'blue': [primarySurface, primary],
    'green': [Color(0xFF11210D), green],
    'amber': [Color(0xFF2A2307), amber],
    'red': [Color(0xFF3B0909), red],
    'violet': [Color(0xFF211047), violet],
    'slate': [line2, slate500],
  };

  static List<Color> tone(String name) => tones[name] ?? tones['blue']!;
}
