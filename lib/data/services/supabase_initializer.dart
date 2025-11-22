import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseInitializer {
  static Future<void> initialize({String envFile = ".env"}) async {
    await dotenv.load(fileName: envFile);

    final supabaseUrl =
        dotenv.env['SUPABASE_URL'] ??
        const String.fromEnvironment('SUPABASE_URL');
    final supabaseAnonKey =
        dotenv.env['SUPABASE_ANNON_KEY'] ??
        const String.fromEnvironment('SUPABASE_ANNON_KEY');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'Supabase credentials not provided. Set .env or pass --dart-define.',
      );
    }

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
}
