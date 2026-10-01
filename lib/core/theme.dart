import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// DripVision — luxury cinema OS tokens.
/// Dark, quiet, expensive. Teal is a signal, not decoration.
class DripTheme {
  // Environment — slightly lifted blacks (true pure black reads harsh on OLED)
  static const Color voidBlack = Color(0xFF070809);
  static const Color deepBlack = Color(0xFF0C0E0F);
  static const Color surface = Color(0xFF121516);
  static const Color surfaceRaised = Color(0xFF171B1C);
  static const Color surfaceLight = Color(0xFF1E2324);
  static const Color hairline = Color(0x12FFFFFF);
  static const Color hairlineStrong = Color(0x1FFFFFFF);

  // Accent — rare
  static const Color cosmicTeal = Color(0xFF00D4AA);
  static const Color nebulaCyan = Color(0xFF5EC4BC);
  static const Color aquaGlow = Color(0xFF9AE8DC);

  // Type
  static const Color warmWhite = Color(0xFFF5F3EC);
  static const Color chrome = Color(0xFFC2C7C6);
  static const Color muted = Color(0xFF6E7674);
  static const Color faint = Color(0xFF4A5250);

  // Radii — tighter = more “product”, less “toy”
  static const double radiusSm = 6;
  static const double radiusMd = 10;
  static const double radiusLg = 14;

  static const TextStyle brandMark = TextStyle(
    fontSize: 11,
    letterSpacing: 5.2,
    fontWeight: FontWeight.w500,
    color: warmWhite,
    height: 1.2,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    letterSpacing: 2.8,
    fontWeight: FontWeight.w500,
    color: cosmicTeal,
    height: 1.2,
  );

  static const TextStyle display = TextStyle(
    fontSize: 30,
    height: 1.12,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.6,
    color: warmWhite,
  );

  static const TextStyle title = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.25,
    color: warmWhite,
    height: 1.25,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    color: chrome,
  );

  static const TextStyle meta = TextStyle(
    fontSize: 12,
    letterSpacing: 0.15,
    height: 1.4,
    color: muted,
  );

  static const TextStyle technical = TextStyle(
    fontSize: 9,
    letterSpacing: 1.8,
    fontWeight: FontWeight.w500,
    color: muted,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    letterSpacing: 1.5,
    fontWeight: FontWeight.w600,
    color: warmWhite,
  );

  static ThemeData get theme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: voidBlack,
      primaryColor: cosmicTeal,
      splashFactory: InkRipple.splashFactory,
      colorScheme: const ColorScheme.dark(
        primary: cosmicTeal,
        secondary: nebulaCyan,
        surface: surface,
        onSurface: warmWhite,
        onPrimary: voidBlack,
        outline: hairline,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: warmWhite,
        displayColor: warmWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: warmWhite,
        titleTextStyle: brandMark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      dividerColor: hairline,
      dividerTheme: const DividerThemeData(
        color: hairline,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: hairline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x08FFFFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: muted, fontSize: 14),
        labelStyle: technical,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: cosmicTeal, width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceRaised,
        contentTextStyle: const TextStyle(color: warmWhite, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: hairline),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: cosmicTeal,
        thumbColor: warmWhite,
        inactiveTrackColor: Color(0x1AFFFFFF),
        trackHeight: 1.5,
        overlayColor: Color(0x2200D4AA),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: const Color(0x2200D4AA),
        disabledColor: surface,
        labelStyle: const TextStyle(fontSize: 11, color: warmWhite),
        secondaryLabelStyle: const TextStyle(fontSize: 11, color: cosmicTeal),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          side: const BorderSide(color: hairline),
        ),
        side: const BorderSide(color: hairline),
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
