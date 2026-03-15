import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bg = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF13131A);
  static const Color surfaceHigh = Color(0xFF1C1C26);
  static const Color border = Color(0xFF2A2A38);
  static const Color accent = Color(0xFFE8C547);
  static const Color accentDim = Color(0x33E8C547);
  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFF8888A0);
  static const Color textMuted = Color(0xFF4A4A60);
  static const Color success = Color(0xFF4CAF7D);
  static const Color warning = Color(0xFFE8A547);
  static const Color danger = Color(0xFFE85447);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        surface: surface,
        onPrimary: bg,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
          labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: bg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }
}
