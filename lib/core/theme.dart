import 'package:flutter/material.dart';

class DripTheme {
  static const Color voidBlack = Color(0xFF0B0F14);
  static const Color deepBlack = voidBlack;
  static const Color gunmetal = Color(0xFF1A1F26);
  static const Color gunmetalLight = Color(0xFF242A33);
  static const Color chrome = Color(0xFFC0C6D4);
  static const Color teal = Color(0xFF00D4AA);
  static const Color cosmicTeal = teal;
  static const Color tealDim = Color(0xFF00A88A);
  static const Color pearl = Color(0xFFF5F7FA);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color warmWhite = pearl;
  static const Color silver = Color(0xFFC0C6D4);
  static const Color muted = silver;
  static const Color softWhite = Color(0xFFE8EDF5);
  static const Color surface = gunmetal;
  static const Color surfaceRaised = gunmetalLight;
  static const Color surfaceLight = Color(0xFF2A3038);
  static const Color nebulaCyan = Color(0xFF00E5FF);
  static const Color aquaGlow = Color(0xFF00F0C8);
  static const Color hairline = Color(0xFF2A3038);
  static const Color hairlineStrong = Color(0xFF3A4048);
  static const Color faint = Color(0xFF1E242C);
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: voidBlack,
        primaryColor: teal,
      );
  static const TextStyle technical = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.2, color: teal);
  static const TextStyle title = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: pearl);
  static const TextStyle body = TextStyle(fontSize: 15, color: softWhite, height: 1.4);
  static const TextStyle meta = TextStyle(fontSize: 13, color: silver);
  static const TextStyle overline = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: teal);
  static const TextStyle brandMark = TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 2.0, color: pearl);
  static const TextStyle display = TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: pearl);
}

class DripColors {
  static const Color primary = DripTheme.teal;
  static const Color surface = DripTheme.surface;
  static const Color text = DripTheme.pearl;
  static const Color white50 = Color(0x80FFFFFF);
  static const Color white40 = Color(0x66FFFFFF);
}