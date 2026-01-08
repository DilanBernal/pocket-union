import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/revenue_dao_sqlite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// SQLite provider (existing)
final sqliteDbProvider = Provider<DbSqlite>((ref) {
  return DbSqlite.instance;
});

// RevenueDaoSqlite provider
final revenueDaoProvider = Provider<RevenueDaoSqlite>((ref) {
  final dbHelper = ref.watch(sqliteDbProvider);
  return RevenueDaoSqlite(dbHelper: dbHelper);
});

// SharedPreferences provider with lazy initialization
// Note: SharedPreferences.getInstance() returns a singleton, so this is safe
// to call even though AppInitializer also initializes SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Supabase provider
// Note: Returns the Supabase client initialized by AppInitializer.
// AppInitializer.initialize() must complete before this provider is accessed.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
