import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/data_local_providers.dart';
import 'package:pocket_union/core/providers/utils_providers.dart';
import 'package:pocket_union/core/services/features/expense_service.dart';
import 'package:pocket_union/core/services/features/expense_share_service.dart';
import 'package:pocket_union/core/services/features/income_service.dart';
import 'package:pocket_union/core/services/features/recurrent_income_service.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_expense_port.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_expense_share_port.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_income_port.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_recurrent_income_port.dart';

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

final incomeServiceProvider = FutureProvider<IIncomePort>((ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final incomeDao = ref.watch(incomeDaoProvider);
  final logger = ref.watch(loggerProvider);
  return IncomeService(incomeDao, supabaseClient, logger);
});

final recurrentIncomeServiceProvider = FutureProvider<IRecurrentIncomePort>((
  ref,
) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final recurrentIncomeDao = ref.watch(recurrentIncomeDaoProvider);
  final logger = ref.watch(loggerProvider);
  return RecurrentIncomeService(recurrentIncomeDao, supabaseClient, logger);
});
