import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/Dao/sqlite/feature/category_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/feature/couple_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/feature/income_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/feature/user_dao_sqlite.dart';
import 'package:pocket_union/core/providers/utils_providers.dart';
import 'package:pocket_union/core/services/features/category_service.dart';
import 'package:pocket_union/core/services/features/income_service.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/models/income.dart';
import 'package:pocket_union/domain/port/cloud/feat/income_port_cloud.dart';
import 'package:pocket_union/domain/port/local/income_port_local.dart';
import 'package:pocket_union/domain/port/local/user_port_local.dart';

// SQLite provider (existing)
final sqliteDbProvider = Provider<DbSqlite>((ref) {
  return DbSqlite.instance;
});

// RevenueDaoSqlite provider
final revenueDaoProvider = Provider<IncomeLocalPort>((ref) {
  final dbHelper = ref.read(sqliteDbProvider);
  return IncomeDaoSqlite(dbHelper: dbHelper);
});

// UserDaoSqlite provider
final userDaoProvider = Provider<UserPortLocal>((ref) {
  final dbHelper = ref.read(sqliteDbProvider);
  return UserDaoSqlite(dbHelper: dbHelper);
});

// CategoryDaoSqlite provider
final categoryDaoProvider = Provider<CategoryDaoSqlite>((ref) {
  final dbHelper = ref.read(sqliteDbProvider);
  return CategoryDaoSqlite(dbHelper: dbHelper);
});

// CoupleDaoSqlite provider
final coupleDaoProvider = Provider<CoupleDaoSqlite>((ref) {
  final dbHelper = ref.read(sqliteDbProvider);
  return CoupleDaoSqlite(dbHelper: dbHelper);
});

// CategoryService provider (offline-first)
final categoryServiceProvider = FutureProvider<CategoryService>((ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final categoryDao = ref.watch(categoryDaoProvider);
  return CategoryService(categoryDao, supabaseClient);
});

// IncomeService provider (offline-first)
final incomeServiceProvider = FutureProvider<IncomeCloudPort>((ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final incomeDao = ref.watch(revenueDaoProvider);
  return IncomeService(incomeDao, supabaseClient);
});

// Categorías filtradas por CategoryHost.income (offline-first con fallback)
final incomeCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  try {
    final categoryService = await ref.watch(categoryServiceProvider.future);
    return categoryService.getCategoriesByHost(CategoryHost.income);
  } catch (_) {
    final categoryDao = ref.watch(categoryDaoProvider);
    return categoryDao.getCategoriesByHost(CategoryHost.income);
  }
});

// Todas las categorías (para la pantalla de listado)
final allCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  try {
    final categoryService = await ref.watch(categoryServiceProvider.future);
    return categoryService.getAllCategories();
  } catch (_) {
    final categoryDao = ref.watch(categoryDaoProvider);
    return categoryDao.getAllCategories();
  }
});

// Todos los ingresos (para la pantalla de listado)
final allIncomesProvider = FutureProvider<List<Income>>((ref) async {
  try {
    final incomeService = await ref.watch(incomeServiceProvider.future);
    return incomeService.getAllIncomes();
  } catch (_) {
    final incomeDao = ref.watch(revenueDaoProvider);
    return incomeDao.getAllIncomes();
  }
});
