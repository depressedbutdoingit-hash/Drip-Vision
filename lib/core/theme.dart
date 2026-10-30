import 'package:flutter/material.dart';

class DripTheme {
  static const Color voidBlack = Color(0xFF05080C);
  static const Color deepBlack = Color(0xFF0B0F14);
  static const Color gunmetal = Color(0xFF141820);
  static const Color gunmetalLight = Color(0xFF1C222C);
  static const Color chrome = Color(0xFFC8CED8);
  static const Color teal = Color(0xFF00E5C0);
  static const Color cosmicTeal = teal;
  static const Color tealDim = Color(0xFF00B89A);
  static const Color pearl = Color(0xFFF7F9FC);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color warmWhite = pearl;
  static const Color silver = Color(0xFFB8BEC8);
  static const Color muted = silver;
  static const Color softWhite = Color(0xFFE8EDF5);
  static const Color surface = gunmetal;
  static const Color surfaceRaised = gunmetalLight;
  static const Color surfaceLight = Color(0xFF242B36);
  static const Color nebulaCyan = Color(0xFF00E5FF);
  static const Color aquaGlow = Color(0xFF00F0C8);
  static const Color hairline = Color(0xFF2A3038);
  static const Color hairlineStrong = Color(0xFF3A424E);
  static const Color faint = Color(0xFF1A2028);
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 28;

  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: voidBlack,
        primaryColor: teal,
        colorScheme: const ColorScheme.dark(
          primary: teal,
          secondary: teal,
          surface: deepBlack,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: pearl,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: teal,
            foregroundColor: Colors.black,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: teal,
            side: const BorderSide(color: teal, width: 1.2),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          ),
        ),
      );

  static const TextStyle technical = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: teal);
  static const TextStyle title = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: pearl, letterSpacing: -0.3);
  static const TextStyle body = TextStyle(fontSize: 15, color: softWhite, height: 1.45);
  static const TextStyle meta = TextStyle(fontSize: 13, color: silver);
  static const TextStyle overline = TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.8, color: teal);
  static const TextStyle brandMark = TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: pearl);
  static const TextStyle display = TextStyle(fontSize: 42, fontWeight: FontWeight.w700, color: pearl, letterSpacing: -1.2, height: 1.05);
}

class DripColors {
  static const Color primary = DripTheme.teal;
  static const Color surface = DripTheme.surface;
  static const Color text = DripTheme.pearl;
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white40 = Color(0x66FFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
}
