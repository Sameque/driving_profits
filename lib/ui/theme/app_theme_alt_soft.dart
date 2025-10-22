import 'package:flutter/material.dart';

class AltSoftColors {
  static const Color primary = Color(0xFF3F6FB0); // Azul suave
  static const Color accent = Color(0xFF6FCF97); // Verde moeda clara
  static const Color background = Color(0xFFF7F9FC); // Fundo muito claro
  static const Color surface = Color(0xFFFFFFFF); // Branco
  static const Color textPrimary = Color(0xFF2C3E50); // Azul grafite
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color error = Color(0xFFE57373); // Vermelho suave
}

class AltSoftTheme {
  static ThemeData theme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AltSoftColors.primary,
      scaffoldBackgroundColor: AltSoftColors.background,
      colorScheme: ColorScheme.light(
        primary: AltSoftColors.primary,
        secondary: AltSoftColors.accent,
        background: AltSoftColors.background,
        surface: AltSoftColors.surface,
        error: AltSoftColors.error,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AltSoftColors.textPrimary,
        ),
        bodyMedium: TextStyle(fontSize: 16, color: AltSoftColors.textPrimary),
        bodySmall: TextStyle(fontSize: 14, color: AltSoftColors.textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AltSoftColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AltSoftColors.accent,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AltSoftColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
