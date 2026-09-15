import 'package:flutter/material.dart';

class DripTheme {
  static const Color voidBlack = Color(0xFF050607);
  static const Color deepBlack = Color(0xFF080A0B);
  static const Color surface = Color(0xFF101314);
  static const Color surfaceRaised = Color(0xFF15191A);
  static const Color surfaceLight = Color(0xFF1B2020);
  static const Color cosmicTeal = Color(0xFF00D4AA);
  static const Color nebulaCyan = Color(0xFF4ECDC4);
  static const Color chrome = Color(0xFFB8BFBE);
  static const Color warmWhite = Color(0xFFF3F1EA);
  static const Color muted = Color(0xFF858C8A);
  // Soft glow used for selected/active chrome accents (e.g. camera controls).
  static const Color aquaGlow = Color(0xFF7CF0DE);

  static ThemeData get theme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: voidBlack,
      primaryColor: cosmicTeal,
      colorScheme: const ColorScheme.dark(
        primary: cosmicTeal,
        secondary: nebulaCyan,
        surface: surface,
        onSurface: warmWhite,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: warmWhite,
        displayColor: warmWhite,
        fontFamily: 'sans',
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: warmWhite,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(.035),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cosmicTeal),
        ),
      ),
    );
  }
}

/// Opacity helpers so call-sites can write `DripDripDripColors.white20` etc.
class DripColors {
  static Color get white10 => Colors.white.withOpacity(0.10);
  static Color get white20 => Colors.white.withOpacity(0.20);
  static Color get white30 => Colors.white.withOpacity(0.30);
  static Color get white40 => Colors.white.withOpacity(0.40);
  static Color get white50 => Colors.white.withOpacity(0.50);
  static Color get white60 => Colors.white.withOpacity(0.60);
  static Color get white70 => Colors.white.withOpacity(0.70);
}
