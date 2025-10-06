import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_tracker/data/repositories/entry_repository.dart';
import 'package:uber_tracker/data/services/entry_service.dart';
import 'package:uber_tracker/ui/theme/app_theme_alt_soft.dart';
import 'package:uber_tracker/ui/theme/app_theme_alt_soft_dark.dart';
import 'package:uber_tracker/ui/feature/summary/summary_viewmodel.dart';
import 'providers/entry_provider.dart';
import 'ui/feature/home/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:uber_tracker/l10n/app_localizations.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => EntryProvider()),
        Provider(create: (_) => EntryService()),

        ProxyProvider<EntryService, EntryRepository>(
          update: (_, service, __) => EntryRepository(service),
        ),
        ChangeNotifierProxyProvider<EntryRepository, SummaryViewmodel>(
          create: (_) => SummaryViewmodel(EntryRepository(EntryService())),
          update: (_, repo, __) => SummaryViewmodel(repo),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => EntryProvider(),
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
        title: 'Controle Uber',
        theme: AltSoftTheme.theme(),
        darkTheme: AltSoftDarkTheme.theme(),
        themeMode: ThemeMode.light,
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
