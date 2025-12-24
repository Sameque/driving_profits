import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:driving_profits/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

class AppConstants {
  // Delegates usados pelo MaterialApp
  static const List<LocalizationsDelegate<dynamic>> localizationDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    AppLocalizations.delegate,
  ];

  // Locales suportados pela aplicação
  static const List<Locale> supportedLocales = [
    Locale('pt', 'BR'),
    Locale('en', 'US'),
  ];
}
