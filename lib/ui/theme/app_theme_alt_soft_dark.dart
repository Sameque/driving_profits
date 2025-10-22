import 'package:flutter/material.dart';

class AltSoftDarkColors {
  static const Color primary = Color(0xFF3F6FB0); // Azul suave
  static const Color accent = Color(0xFF6FCF97); // Verde moeda clara
  static const Color background = Color(0xFF121417); // Fundo escuro
  static const Color surface = Color(0xFF1E2125); // Superfície escura
  static const Color textPrimary = Color(0xFFECEFF1); // Texto claro
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color error = Color(0xFFEF9A9A); // Vermelho suave
}

class AltSoftDarkTheme {
  static ThemeData theme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AltSoftDarkColors.primary,
      scaffoldBackgroundColor: AltSoftDarkColors.background,
      colorScheme: ColorScheme.dark(
        primary: AltSoftDarkColors.primary,
        secondary: AltSoftDarkColors.accent,
        surface: AltSoftDarkColors.surface,
        error: AltSoftDarkColors.error,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AltSoftDarkColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: AltSoftDarkColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: AltSoftDarkColors.textSecondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AltSoftDarkColors.surface,
        foregroundColor: AltSoftDarkColors.textPrimary,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AltSoftDarkColors.accent,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AltSoftDarkColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
