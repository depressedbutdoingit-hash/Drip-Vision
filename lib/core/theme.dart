import 'package:flutter/material.dart';

class DripTheme {
  // Premium cinematic palette: gunmetal, deep teal, pearl
  static const Color voidBlack = Color(0xFF0B0F14);
  static const Color gunmetal = Color(0xFF1A1F26);
  static const Color gunmetalLight = Color(0xFF242A33);
  static const Color teal = Color(0xFF00D4AA);
  static const Color tealDim = Color(0xFF00A88A);
  static const Color pearl = Color(0xFFF5F7FA);
  static const Color silver = Color(0xFFC0C6D4);
  static const Color softWhite = Color(0xFFE8EDF5);

  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: voidBlack,
        primaryColor: teal,
        colorScheme: const ColorScheme.dark(
          primary: teal,
          secondary: tealDim,
          surface: gunmetal,
          background: voidBlack,
          onPrimary: Colors.black,
          onSurface: pearl,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: gunmetal,
          foregroundColor: pearl,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: pearl,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: teal,
            foregroundColor: Colors.black,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: gunmetal,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: teal, width: 1.5),
          ),
          hintStyle: const TextStyle(color: silver),
        ),
        cardTheme: CardTheme(
          color: gunmetal,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.zero,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: pearl, letterSpacing: -0.5),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: pearl),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: pearl),
          bodyLarge: TextStyle(fontSize: 16, color: softWhite, height: 1.5),
          bodyMedium: TextStyle(fontSize: 14, color: silver),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        dividerTheme: const DividerThemeData(color: Color(0xFF2A3038), thickness: 1),
      );

  static const TextStyle technical = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    color: teal,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: pearl,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    color: softWhite,
    height: 1.4,
  );

  static const TextStyle meta = TextStyle(
    fontSize: 13,
    color: silver,
  );
}