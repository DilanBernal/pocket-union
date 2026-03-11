import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/data_local_providers.dart';
import 'package:pocket_union/core/providers/utils_providers.dart';
import 'package:pocket_union/core/services/auth/auth_service.dart';
import 'package:pocket_union/core/services/auth/couple_service.dart';
import 'package:pocket_union/core/services/features/category_service.dart';
import 'package:pocket_union/core/services/features/expense_service.dart';
import 'package:pocket_union/core/services/features/expense_share_service.dart';
import 'package:pocket_union/core/services/features/goal_contribution_service.dart';
import 'package:pocket_union/core/services/features/goal_service.dart';
import 'package:pocket_union/core/services/features/income_service.dart';
import 'package:pocket_union/domain/port/cloud/auth/i_auth_port.dart';
import 'package:pocket_union/domain/port/cloud/auth/i_couple_port.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_category_port.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_expense_port.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_expense_share_port.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_goal_contribution_port.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_goal_port.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_income_port.dart';

// Auth services
final authServiceProvider = FutureProvider<IAuthPort>((ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final userSqlite = ref.watch(userDaoProvider);
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final logger = ref.watch(loggerProvider);
  return AuthService(supabaseClient, userSqlite, prefs, logger);
});

final coupleServiceProvider = FutureProvider<ICouplePort>((ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final coupleDao = ref.watch(coupleDaoProvider);
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final logger = ref.watch(loggerProvider);
  return CoupleService(coupleDao, supabaseClient, prefs, logger);
});

// Feature services
final categoryServiceProvider = FutureProvider<ICategoryPort>((ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final categoryDao = ref.watch(categoryDaoProvider);
  final logger = ref.watch(loggerProvider);
  return CategoryService(categoryDao, supabaseClient, logger);
});

final incomeServiceProvider = FutureProvider<IIncomePort>((ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final incomeDao = ref.watch(incomeDaoProvider);
  final logger = ref.watch(loggerProvider);
  return IncomeService(incomeDao, supabaseClient, logger);
});

final expenseServiceProvider = FutureProvider<IExpensePort>((ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final expenseDao = ref.watch(expenseDaoProvider);
  final logger = ref.watch(loggerProvider);
  return ExpenseService(expenseDao, supabaseClient, logger);
});

final expenseShareServiceProvider = FutureProvider<IExpenseSharePort>((
  ref,
) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final expenseShareDao = ref.watch(expenseShareDaoProvider);
  final logger = ref.watch(loggerProvider);
  return ExpenseShareService(expenseShareDao, supabaseClient, logger);
});

final goalServiceProvider = FutureProvider<IGoalPort>((ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final goalDao = ref.watch(goalDaoProvider);
  final logger = ref.watch(loggerProvider);
  return GoalService(goalDao, supabaseClient, logger);
});

final goalContributionServiceProvider = FutureProvider<IGoalContributionPort>((
  ref,
) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final contributionDao = ref.watch(goalContributionDaoProvider);
  final logger = ref.watch(loggerProvider);
  return GoalContributionService(contributionDao, supabaseClient, logger);
});
