import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// SQLite provider (existing)
final sqliteDbProvider = Provider<DbSqlite>((ref) {
  return DbSqlite.instance;
});

// SharedPreferences provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Supabase provider
// Note: Assumes Supabase is already initialized by AppInitializer
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
