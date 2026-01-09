import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/Dao/sqlite/category_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/revenue_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/user_dao_sqlite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// SQLite provider (existing)
final sqliteDbProvider = Provider<DbSqlite>((ref) {
  return DbSqlite.instance;
});

// RevenueDaoSqlite provider
final revenueDaoProvider = Provider<RevenueDaoSqlite>((ref) {
  final dbHelper = ref.read(sqliteDbProvider);
  return RevenueDaoSqlite(dbHelper: dbHelper);
});

// UserDaoSqlite provider
final userDaoProvider = Provider<UserDaoSqlite>((ref) {
  final dbHelper = ref.read(sqliteDbProvider);
  return UserDaoSqlite(dbHelper: dbHelper);
});

// CategoryDaoSqlite provider
final categoryDaoProvider = Provider<CategoryDaoSqlite>((ref) {
  final dbHelper = ref.read(sqliteDbProvider);
  return CategoryDaoSqlite(dbHelper: dbHelper);
});

// SharedPreferences provider with lazy initialization
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// DotEnv provider - carga variables de entorno
final dotEnvProvider = FutureProvider<DotEnv>((ref) async {
  await dotenv.load(fileName: ".env", isOptional: false);
  return dotenv;
});

// Supabase provider con inicialización lazy
final supabaseClientProvider = FutureProvider<SupabaseClient>((ref) async {
  // Asegurar que dotenv esté cargado
  await ref.watch(dotEnvProvider.future);
  
  // Check if Supabase is already initialized to avoid exceptions
  if (!Supabase.instance.isInitialized) {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_API_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }
  
  return Supabase.instance.client;
});
