import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// DripVision — luxury cinema OS tokens.
/// Gunmetal environment. Teal is a signal, never decoration.
class DripTheme {
  // Gunmetal environment (not pure black — reads richer on OLED)
  static const Color voidBlack = Color(0xFF121416); // was harsh pure black
  static const Color deepBlack = Color(0xFF16191C);
  static const Color surface = Color(0xFF1A1E22);
  static const Color surfaceRaised = Color(0xFF22272C);
  static const Color surfaceLight = Color(0xFF2A3036);
  static const Color hairline = Color(0x14FFFFFF);
  static const Color hairlineStrong = Color(0x22FFFFFF);

  // Accent — rare, liquid teal
  static const Color cosmicTeal = Color(0xFF00D4AA);
  static const Color nebulaCyan = Color(0xFF5EC4BC);
  static const Color aquaGlow = Color(0xFF9AE8DC);

  // Type
  static const Color warmWhite = Color(0xFFF4F2EC);
  static const Color chrome = Color(0xFFB8BEC0);
  static const Color muted = Color(0xFF7A8288);
  static const Color faint = Color(0xFF555C62);

  // Radii — product, not toy
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
    fontSize: 28,
    height: 1.12,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.5,
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
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
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
        fillColor: const Color(0x0AFFFFFF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      sliderTheme: SliderThemeData(
        activeTrackColor: cosmicTeal,
        inactiveTrackColor: hairlineStrong,
        thumbColor: warmWhite,
        overlayColor: cosmicTeal.withOpacity(0.12),
        trackHeight: 2,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        selectedColor: cosmicTeal.withOpacity(0.18),
        labelStyle: const TextStyle(fontSize: 11, color: chrome),
        side: const BorderSide(color: hairline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: deepBlack,
        selectedItemColor: cosmicTeal,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}


/// Legacy color aliases used across older screens.
class DripColors {
  static const white10 = Color(0x1AFFFFFF);
  static const white20 = Color(0x33FFFFFF);
  static const white30 = Color(0x4DFFFFFF);
  static const white40 = Color(0x66FFFFFF);
  static const white50 = Color(0x80FFFFFF);
  static const white70 = Color(0xB3FFFFFF);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
}
