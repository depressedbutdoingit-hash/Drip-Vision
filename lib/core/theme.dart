import 'package:flutter/material.dart';

/// DripVision Cinematic Studio — restrained premium design tokens.
class DripTheme {
  // Environment
  static const Color voidBlack = Color(0xFF050607);
  static const Color deepBlack = Color(0xFF0A0C0D);
  static const Color surface = Color(0xFF111415);
  static const Color surfaceRaised = Color(0xFF161A1B);
  static const Color surfaceLight = Color(0xFF1C2122);
  static const Color hairline = Color(0x14FFFFFF); // ~8% white

  // Accent — use sparingly
  static const Color cosmicTeal = Color(0xFF00D4AA);
  static const Color nebulaCyan = Color(0xFF4ECDC4);
  static const Color aquaGlow = Color(0xFF7CF0DE);

  // Type
  static const Color warmWhite = Color(0xFFF3F1EA);
  static const Color chrome = Color(0xFFB8BFBE);
  static const Color muted = Color(0xFF7A8280);

  // Typography styles
  static const TextStyle brandMark = TextStyle(
    fontSize: 12,
    letterSpacing: 4.5,
    fontWeight: FontWeight.w600,
    color: warmWhite,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    letterSpacing: 2.4,
    fontWeight: FontWeight.w600,
    color: cosmicTeal,
  );

  static const TextStyle display = TextStyle(
    fontSize: 28,
    height: 1.15,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.4,
    color: warmWhite,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: warmWhite,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: chrome,
  );

  static const TextStyle meta = TextStyle(
    fontSize: 11,
    letterSpacing: 0.3,
    color: muted,
  );

  static const TextStyle technical = TextStyle(
    fontSize: 9,
    letterSpacing: 1.6,
    fontWeight: FontWeight.w500,
    color: muted,
  );

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
        onPrimary: voidBlack,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: warmWhite,
        displayColor: warmWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: warmWhite,
        titleTextStyle: brandMark,
      ),
      dividerColor: hairline,
      dividerTheme: const DividerThemeData(color: hairline, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: cosmicTeal, width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceRaised,
        contentTextStyle: const TextStyle(color: warmWhite),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: cosmicTeal,
        thumbColor: warmWhite,
        inactiveTrackColor: Color(0x22FFFFFF),
        trackHeight: 2,
      ),
    );
  }
}

class DripColors {
  static Color get white10 => Colors.white.withOpacity(0.10);
  static Color get white20 => Colors.white.withOpacity(0.20);
  static Color get white30 => Colors.white.withOpacity(0.30);
  static Color get white40 => Colors.white.withOpacity(0.40);
  static Color get white50 => Colors.white.withOpacity(0.50);
  static Color get white60 => Colors.white.withOpacity(0.60);
  static Color get white70 => Colors.white.withOpacity(0.70);
}
