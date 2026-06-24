import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/Dao/drift/app_database.dart';
import 'package:pocket_union/Dao/drift/daos/category_dao_drift.dart';
import 'package:pocket_union/Dao/drift/daos/couple_dao_drift.dart';
import 'package:pocket_union/Dao/drift/daos/expense_dao_drift.dart';
import 'package:pocket_union/Dao/drift/daos/expense_share_dao_drift.dart';
import 'package:pocket_union/Dao/drift/daos/goal_contribution_dao_drift.dart';
import 'package:pocket_union/Dao/drift/daos/goal_dao_drift.dart';
import 'package:pocket_union/Dao/drift/daos/income_dao_drift.dart';
import 'package:pocket_union/Dao/drift/daos/recurrent_expense_dao_drift.dart';
import 'package:pocket_union/Dao/drift/daos/recurrent_income_dao_drift.dart';
import 'package:pocket_union/Dao/drift/daos/user_dao_drift.dart';
import 'package:pocket_union/core/providers/utils_providers.dart';
import 'package:pocket_union/domain/port/local/category_port_local.dart';
import 'package:pocket_union/domain/port/local/couple_local_port.dart';
import 'package:pocket_union/domain/port/local/expense_local_port.dart';
import 'package:pocket_union/domain/port/local/expense_share_local_port.dart';
import 'package:pocket_union/domain/port/local/goal_contribution_local_port.dart';
import 'package:pocket_union/domain/port/local/goal_local_port.dart';
import 'package:pocket_union/domain/port/local/income_port_local.dart';
import 'package:pocket_union/domain/port/local/recurrent_expense_port_local.dart';
import 'package:pocket_union/domain/port/local/recurrent_income_port_local.dart';
import 'package:pocket_union/domain/port/local/user_port_local.dart';

final incomeDaoProvider = Provider<IncomeLocalPort>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return IncomeDaoDrift(appDatabase: db, logger: logger);
});

final categoryDaoProvider = Provider<CategoryLocalPort>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return CategoryDaoDrift(appDatabase: db, logger: logger);
});

final coupleDaoProvider = Provider<CoupleLocalPort>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return CoupleDaoDrift(appDatabase: db, logger: logger);
});

final expenseDaoProvider = Provider<ExpenseLocalPort>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return ExpenseDaoDrift(appDatabase: db, logger: logger);
});

final expenseShareDaoProvider = Provider<ExpenseShareLocalPort>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return ExpenseShareDaoDrift(appDatabase: db, logger: logger);
});

final goalDaoProvider = Provider<GoalLocalPort>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return GoalDaoDrift(appDatabase: db, logger: logger);
});

final goalContributionDaoProvider = Provider<GoalContributionLocalPort>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return GoalContributionDaoDrift(appDatabase: db, logger: logger);
});

final recurrentIncomeDaoProvider = Provider<RecurrentIncomeLocalPort>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return RecurrentIncomeDaoDrift(appDatabase: db, logger: logger);
});

final recurrentExpenseDaoProvider = Provider<RecurrentExpenseLocalPort>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return RecurrentExpenseDaoDrift(appDatabase: db, logger: logger);
});

final userDaoProvider = Provider<UserLocalPort>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return UserDaoDrift(appDatabase: db, logger: logger);
});
