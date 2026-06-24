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

final categoryDaoDriftProvider = Provider<CategoryDaoDrift>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return CategoryDaoDrift(appDatabase: db, logger: logger);
});

final coupleDaoDriftProvider = Provider<CoupleDaoDrift>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return CoupleDaoDrift(appDatabase: db, logger: logger);
});

final expenseDaoDriftProvider = Provider<ExpenseDaoDrift>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return ExpenseDaoDrift(appDatabase: db, logger: logger);
});

final expenseShareDaoDriftProvider = Provider<ExpenseShareDaoDrift>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return ExpenseShareDaoDrift(appDatabase: db, logger: logger);
});

final incomeDaoDriftProvider = Provider<IncomeDaoDrift>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return IncomeDaoDrift(appDatabase: db, logger: logger);
});

final goalDaoDriftProvider = Provider<GoalDaoDrift>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return GoalDaoDrift(appDatabase: db, logger: logger);
});

final goalContributionDaoDriftProvider = Provider<GoalContributionDaoDrift>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return GoalContributionDaoDrift(appDatabase: db, logger: logger);
});

final recurrentExpenseDaoDriftProvider = Provider<RecurrentExpenseDaoDrift>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return RecurrentExpenseDaoDrift(appDatabase: db, logger: logger);
});

final recurrentIncomeDaoDriftProvider = Provider<RecurrentIncomeDaoDrift>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return RecurrentIncomeDaoDrift(appDatabase: db, logger: logger);
});

final userDaoDriftProvider = Provider<UserDaoDrift>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  final logger = ref.watch(loggerProvider);
  return UserDaoDrift(appDatabase: db, logger: logger);
});
