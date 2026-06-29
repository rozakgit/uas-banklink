import 'package:flutter/material.dart';

class AppColors {
  // Primary Lime/Neon
  static const Color primary = Color(0xFFBDF510);
  static const Color primaryLight = Color(0xFFD3F000);
  static const Color primaryDark = Color(0xFFA5D700);
  static const Color primarySurface = Color(0xFF152315);
  static const Color primaryBorder = Color(0xFF444935);
  
  // Custom Dribbble Colors
  static const Color neonGreen = Color(0xFFDFF26E);
  static const Color darkGreen = Color(0xFFAACF31);

  // Semantic
  static const Color green = Color(0xFFBDF510); // Using neon lime as green
  static const Color greenSurface = Color(0xFF11210D);
  static const Color amber = Color(0xFFFACC15);
  static const Color amberSurface = Color(0xFF2A2307);
  static const Color red = Color(0xFFFFB4AB);
  static const Color redSurface = Color(0xFF3B0909);
  static const Color violet = Color(0xFFD0BCFF);
  static const Color violetSurface = Color(0xFF211047);

  // Neutral (Dark Theme)
  static const Color ink = Color(0xFFD6E7D2); // on-surface
  static const Color slate600 = Color(0xFFC5C9AF); // on-surface-variant
  static const Color slate500 = Color(0xFF8E937B); // outline
  static const Color slate400 = Color(0xFF444935); // outline-variant
  static const Color slate300 = Color(0xFF2A3829); // surface-variant
  static const Color line = Color(0xFF1F2D1F); // surface-container-high
  static const Color line2 = Color(0xFF152315); // surface-container
  static const Color bg = Color(0xFF09160A); // background
  static const Color white = Color(0xFF111F11); // surface-container-low

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
    colors: [primaryLight, primary, primaryDark],
  );

  // Shadows
  static List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: Color(0x4DBDF510), // Lime glow
      blurRadius: 30,
      spreadRadius: 0,
      offset: Offset(0, 10),
    ),
  ];

  static List<BoxShadow> glowLime = [
    BoxShadow(
      color: Color(0x66BDF510),
      blurRadius: 15,
      spreadRadius: 0,
      offset: Offset(0, 0),
    ),
  ];

  // Tone map for FeatureIcon
  static Map<String, List<Color>> tones = {
    'blue': [primarySurface, primary], // Replacing blue with primary lime
    'green': [greenSurface, green],
    'amber': [amberSurface, amber],
    'red': [redSurface, red],
    'violet': [violetSurface, violet],
    'slate': [line2, slate500],
  };

  static List<Color> tone(String name) => tones[name] ?? tones['blue']!;
}
