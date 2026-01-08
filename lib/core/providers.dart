import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// SQLite provider (ya existe)
final sqliteDbProvider = Provider<DbSqlite>((ref) {
  return DbSqlite.instance;
});

// SharedPreferences provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Supabase provider
final supabaseClientProvider = FutureProvider<SupabaseClient>((ref) async {
  await dotenv.load(fileName: ".env", isOptional: false);
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_API_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  return Supabase.instance.client;
});
