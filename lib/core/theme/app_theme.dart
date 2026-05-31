import 'package:flutter/material.dart';

class AppColors {
  // Dark theme palette — deep slate with electric teal accents
  static const darkBg = Color(0xFF0A0E1A);
  static const darkSurface = Color(0xFF111827);
  static const darkCard = Color(0xFF1A2236);
  static const darkCardElevated = Color(0xFF1F2A40);
  static const darkBorder = Color(0xFF2A3550);

  // Light theme palette — warm ivory with deep navy
  static const lightBg = Color(0xFFF4F6FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE2E8F0);

  // Brand accent — electric teal
  static const accent = Color(0xFF00D9C0);
  static const accentDeep = Color(0xFF00B5A4);
  static const accentSoft = Color(0x1A00D9C0);
  static const accentGlow = Color(0x3300D9C0);

  // Semantic colors
  static const success = Color(0xFF22D3A0);
  static const warning = Color(0xFFFFB547);
  static const error = Color(0xFFFF5C7A);
  static const info = Color(0xFF60A5FA);

  // Stat card gradients
  static const userGrad1 = Color(0xFF667EEA);
  static const userGrad2 = Color(0xFF764BA2);
  static const deviceGrad1 = Color(0xFF00D9C0);
  static const deviceGrad2 = Color(0xFF0099B5);
  static const incomeGrad1 = Color(0xFFFFB547);
  static const incomeGrad2 = Color(0xFFFF6B35);
  static const errGrad1 = Color(0xFFFF5C7A);
  static const errGrad2 = Color(0xFFFF2D6B);

  // Text
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF475569);
  static const textDark = Color(0xFF0F172A);
  static const textDarkSecondary = Color(0xFF475569);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentDeep,
        surface: AppColors.darkSurface,
        error: AppColors.error,
      ),
      useMaterial3: true,
      fontFamily: 'SF Pro Display',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.darkBg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCard,
        selectedColor: AppColors.accentSoft,
        side: const BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle:
            const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      textTheme: _textTheme(AppColors.textPrimary, AppColors.textSecondary),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.accentDeep,
        surface: AppColors.lightSurface,
        error: AppColors.error,
      ),
      useMaterial3: true,
      fontFamily: 'SF Pro Display',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        hintStyle:
            const TextStyle(color: AppColors.textDarkSecondary, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightBg,
        selectedColor: AppColors.accentSoft,
        side: const BorderSide(color: AppColors.lightBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle:
            const TextStyle(fontSize: 12, color: AppColors.textDarkSecondary),
      ),
      textTheme: _textTheme(AppColors.textDark, AppColors.textDarkSecondary),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: primary,
          letterSpacing: -1),
      displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: primary,
          letterSpacing: -0.8),
      headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: primary,
          letterSpacing: -0.5),
      headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: -0.3),
      headlineSmall:
          TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: primary),
      titleLarge:
          TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: primary),
      titleMedium:
          TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primary),
      bodyLarge:
          TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: primary),
      bodyMedium: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w400, color: secondary),
      bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, color: secondary),
      labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: 0.3),
      labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: secondary,
          letterSpacing: 0.8),
    );
  }
}
