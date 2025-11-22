import 'package:driving_profits/data/services/supabase_initializer.dart';
import 'package:driving_profits/app/app_providers.dart';
import 'package:driving_profits/core/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:driving_profits/ui/theme/app_theme_alt_soft.dart';
import 'package:driving_profits/ui/theme/app_theme_alt_soft_dark.dart';
import 'ui/feature/home/home_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseInitializer.initialize();

  runApp(AppProviders.build(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppConstants.localizationDelegates,
      supportedLocales: AppConstants.supportedLocales,
      title: 'Driving Profits',
      theme: AltSoftTheme.theme(),
      darkTheme: AltSoftDarkTheme.theme(),
      themeMode: ThemeMode.light,
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
