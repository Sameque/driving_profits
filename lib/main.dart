import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_tracker/data/repositories/entry_repository.dart';
import 'package:uber_tracker/data/repositories/expense_repository.dart';
import 'package:uber_tracker/data/services/entry_service.dart';
import 'package:uber_tracker/data/services/expense_service.dart';
import 'package:uber_tracker/data/services/database_service.dart';
import 'package:uber_tracker/ui/feature/expenses/expense_viewmodel.dart';
import 'package:uber_tracker/ui/feature/list/daily_list_viewmodel.dart';
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
        // Shared DatabaseService
        Provider<DatabaseService>(create: (_) => DatabaseService.instance),

        // Entry
        ProxyProvider<DatabaseService, EntryService>(
          update: (_, db, __) => EntryService(db),
        ),
        ProxyProvider<EntryService, EntryRepository>(
          update: (_, service, __) => EntryRepository(service),
        ),

        ChangeNotifierProvider(
          create: (ctx) => SummaryViewmodel(ctx.read<EntryRepository>()),
        ),

        // Entry List
        ChangeNotifierProvider(
          create: (ctx) => DailyListViewmodel(ctx.read<EntryRepository>()),
        ),

        // Expense
        ProxyProvider<DatabaseService, ExpenseService>(
          update: (_, db, __) => ExpenseService(db),
        ),
        ProxyProvider<ExpenseService, ExpenseRepository>(
          update: (_, service, __) => ExpenseRepository(service),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ExpenseViewModel(ctx.read<ExpenseRepository>()),
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
    return MaterialApp(
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
    );
  }
}
