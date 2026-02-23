import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/Dao/sqlite/category_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/income_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/user_dao_sqlite.dart';
import 'package:pocket_union/core/services/auth/auth_service.dart';
import 'package:pocket_union/core/services/features/category_service.dart';
import 'package:pocket_union/core/services/features/income_service.dart';
import 'package:pocket_union/domain/models/user.dart';
import 'package:pocket_union/domain/port/feat/category_port.dart';
import 'package:pocket_union/domain/port/feat/income_port.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/port/auth/auth_port.dart';
import '../domain/port/feat/user_port.dart';

// SQLite provider (existing)
final sqliteDbProvider = Provider<DbSqlite>((ref) {
  return DbSqlite.instance;
});

// IncomeDaoSqlite provider
final revenueDaoProvider = Provider<IncomeDaoSqlite>((ref) {
  final dbHelper = ref.read(sqliteDbProvider);
  return IncomeDaoSqlite(dbHelper: dbHelper);
});

// UserDaoSqlite provider
final userDaoProvider = Provider<UserPort>((ref) {
  final dbHelper = ref.read(sqliteDbProvider);
  return UserDaoSqlite(dbHelper: dbHelper);
});

// CategoryDaoSqlite provider
final categoryDaoProvider = Provider<CategoryDaoSqlite>((ref) {
  final dbHelper = ref.read(sqliteDbProvider);
  return CategoryDaoSqlite(dbHelper: dbHelper);
});

// CategoryService provider
final categoryServiceProvider = FutureProvider<CategoryPort>((ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final categoryDao = ref.watch(categoryDaoProvider);
  return CategoryService(categoryDao, supabaseClient);
});

// IncomeService provider
final incomeServiceProvider = FutureProvider<IncomePort>((ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final incomeDao = ref.watch(revenueDaoProvider);
  return IncomeService(incomeDao, supabaseClient);
});

// SharedPreferences provider with lazy initialization
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  final instance = await SharedPreferences.getInstance();
  var isInSession = instance.getBool("isInSession");
  if (isInSession == null) {
    instance.setBool('isInSession', false);
  }
  return instance;
});

final dotEnvProvider = FutureProvider<DotEnv>((ref) async {
  await dotenv.load(fileName: ".env", isOptional: false);
  return dotenv;
});

final supabaseClientProvider = FutureProvider<SupabaseClient>((ref) async {
  await ref.watch(dotEnvProvider.future);

  try {
    if (Supabase.instance.isInitialized) {
      return Supabase.instance.client;
    }
  } on AssertionError catch (_) {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_API_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  } catch (error) {
    debugPrint("Ocurrio un error iniciando supabase");
  }

  return Supabase.instance.client;
});

final authServiceProvider = FutureProvider<AuthPort>((ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final userSqlite = ref.watch(userDaoProvider);
  final refs = await ref.watch(sharedPreferencesProvider.future);
  return AuthService(supabaseClient, userSqlite, refs);
});

final currentUserProvider = FutureProvider<DomainUser?>((ref) async {
  final userDao = ref.watch(userDaoProvider);
  return await userDao.getCurrentUser();
});
