import 'package:flutter/material.dart';

class AppTheme {
  // Cores primárias
  static const Color primaryColor = Color(0xFF4361EE); // Azul vibrante
  static const Color secondaryColor = Color(0xFF3F37C9); // Azul mais escuro
  static const Color accentColor = Color(0xFF4CC9F0); // Azul claro
  static const Color errorColor = Color(0xFFF72585); // Rosa/vermelho
  static const Color successColor = Color(0xFF4AD66D); // Verde
  static const Color warningColor = Color(0xFFF77F00); // Laranja

  // Cores de texto
  static const Color textPrimary = Color(0xFF2B2D42); // Cinza escuro
  static const Color textSecondary = Color(0xFF8D99AE); // Cinza médio
  static const Color textOnPrimary = Colors.white; // Branco

  // Cores de fundo
  static const Color backgroundLight = Color(0xFFF8F9FA); // Branco acinzentado
  static const Color backgroundDark = Color(0xFF212529); // Preto acinzentado
  static const Color surfaceColor = Colors.white; // Branco puro

  // Cores adicionais
  static const Color dividerColor = Color(0xFFE9ECEF);
  static const Color disabledColor = Color(0xFFADB5BD);

  // Tipografia
  static const String fontFamily = 'Roboto';
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeadline = 28.0;
  static const double fontSizeDisplay = 32.0;

  // Bordas
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;

  // Espaçamentos
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Tema claro
  static ThemeData lightTheme() {
    return ThemeData(
      cardColor: Colors.white,

      cardTheme: CardTheme(
        color: Colors.white,
        shadowColor: Colors.grey.withOpacity(0.5),
        elevation: 4,
        margin: const EdgeInsets.all(paddingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ).data,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: surfaceColor,
        // background: backgroundLight,
      ),

      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        color: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSizeTitle,
          fontWeight: FontWeight.bold,
          color: textOnPrimary,
        ),
        iconTheme: IconThemeData(color: textOnPrimary),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSizeDisplay,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSizeHeadline,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSizeTitle,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSizeMedium,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSizeSmall,
          color: textSecondary,
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: primaryColor,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadiusMedium)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textOnPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingLarge,
            vertical: paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadiusMedium)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: errorColor, width: 2.0),
        ),
        contentPadding: EdgeInsets.all(paddingMedium),
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: disabledColor),
      ),

      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: paddingMedium,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        error: errorColor,
        // surface: Color(0xFF343A40),
        surface: Color(0xFF121212),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        color: Color(0xFF1E1E1E),
        elevation: 200,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSizeTitle,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSizeDisplay,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSizeHeadline,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSizeTitle,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSizeMedium,
          color: Color(0xFFE0E0E0),
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSizeSmall,
          color: Color(0xFFB0B0B0),
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: primaryColor,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadiusMedium)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 150,
            vertical: paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        fillColor: Color.fromARGB(255, 224, 28, 28),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadiusMedium)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF424242)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: errorColor, width: 2.0),
        ),
        contentPadding: EdgeInsets.all(paddingMedium),
        labelStyle: TextStyle(color: Color(0xFF9E9E9E)),
        hintStyle: TextStyle(color: Color(0xFF616161)),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        margin: const EdgeInsets.all(paddingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ).data,
      dividerTheme: const DividerThemeData(
        color: Color(0xFF424242),
        thickness: 1,
        space: paddingMedium,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF424242),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: primaryColor,
        unselectedItemColor: Color(0xFF757575),
      ),
    );
  }
}
