import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/Dao/sqlite/feature/category_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/feature/couple_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/feature/expense_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/feature/expense_share_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/feature/goal_contribution_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/feature/goal_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/feature/income_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/feature/user_dao_sqlite.dart';
import 'package:pocket_union/core/providers/utils_providers.dart';
import 'package:pocket_union/domain/port/local/category_port_local.dart';
import 'package:pocket_union/domain/port/local/couple_local_port.dart';
import 'package:pocket_union/domain/port/local/expense_local_port.dart';
import 'package:pocket_union/domain/port/local/expense_share_local_port.dart';
import 'package:pocket_union/domain/port/local/goal_contribution_local_port.dart';
import 'package:pocket_union/domain/port/local/goal_local_port.dart';
import 'package:pocket_union/domain/port/local/income_port_local.dart';
import 'package:pocket_union/domain/port/local/user_port_local.dart';

// SQLite provider
final sqliteDbProvider = Provider<DbSqlite>((ref) {
  return DbSqlite.instance;
});

// DAO providers — all use abstract local port types
final incomeDaoProvider = Provider<IncomeLocalPort>((ref) {
  final dbHelper = ref.read(sqliteDbProvider);
  final logger = ref.read(loggerProvider);
  return IncomeDaoSqlite(dbHelper: dbHelper, logger: logger);
});

final userDaoProvider = Provider<UserLocalPort>((ref) {
  final dbHelper = ref.read(sqliteDbProvider);
  final logger = ref.read(loggerProvider);
  return UserDaoSqlite(dbHelper: dbHelper, logger: logger);
});

final categoryDaoProvider = Provider<CategoryLocalPort>((ref) {
  final dbHelper = ref.read(sqliteDbProvider);
  final logger = ref.read(loggerProvider);
  return CategoryDaoSqlite(dbHelper: dbHelper, logger: logger);
});

final coupleDaoProvider = Provider<CoupleLocalPort>((ref) {
  final dbHelper = ref.read(sqliteDbProvider);
  final logger = ref.read(loggerProvider);
  return CoupleDaoSqlite(dbHelper: dbHelper, logger: logger);
});

final expenseDaoProvider = Provider<ExpenseLocalPort>((ref) {
  final dbHelper = ref.read(sqliteDbProvider);
  final logger = ref.read(loggerProvider);
  return ExpenseDaoSqlite(dbHelper: dbHelper, logger: logger);
});

final expenseShareDaoProvider = Provider<ExpenseShareLocalPort>((ref) {
  final dbHelper = ref.read(sqliteDbProvider);
  final logger = ref.read(loggerProvider);
  return ExpenseShareDaoSqlite(dbHelper: dbHelper, logger: logger);
});

final goalDaoProvider = Provider<GoalLocalPort>((ref) {
  final dbHelper = ref.read(sqliteDbProvider);
  final logger = ref.read(loggerProvider);
  return GoalDaoSqlite(dbHelper: dbHelper, logger: logger);
});

final goalContributionDaoProvider = Provider<GoalContributionLocalPort>((ref) {
  final dbHelper = ref.read(sqliteDbProvider);
  final logger = ref.read(loggerProvider);
  return GoalContributionDaoSqlite(dbHelper: dbHelper, logger: logger);
});
