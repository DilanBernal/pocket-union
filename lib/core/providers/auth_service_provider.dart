import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/data_cloud_providers.dart';
import 'package:pocket_union/core/providers/data_local_providers.dart';
import 'package:pocket_union/core/providers/service_provider.dart';
import 'package:pocket_union/core/providers/utils_providers.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/models/couple.dart';
import 'package:pocket_union/domain/models/expense.dart';
import 'package:pocket_union/domain/models/income.dart';
import 'package:pocket_union/domain/models/recurrent_expense.dart';
import 'package:pocket_union/domain/models/recurrent_income.dart';
import 'package:pocket_union/domain/models/user.dart';

// Current user (local)
final currentUserProvider = FutureProvider<DomainUser?>((ref) async {
  final userDao = ref.watch(userDaoProvider);
  return await userDao.getCurrentUser();
});

// Current couple (Supabase first, fallback local)
final currentCoupleProvider = FutureProvider<Couple?>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final userId = prefs.getString('idUser');
  if (userId == null) return null;

  try {
    final coupleService = await ref.watch(coupleServiceProvider.future);
    final couple = await coupleService.getCoupleByUserId(userId);
    if (couple != null) {
      await prefs.setString('coupleId', couple.id);
    }
    return couple;
  } catch (_) {
    final coupleDao = ref.watch(coupleDaoProvider);
    return coupleDao.getCoupleByUserId(userId);
  }
});

// Categories filtered by CategoryHost.income
final incomeCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  try {
    final categoryService = await ref.watch(categoryServiceProvider.future);
    return categoryService.getCategoriesByHost(CategoryHost.income);
  } catch (_) {
    final categoryDao = ref.watch(categoryDaoProvider);
    return categoryDao.getCategoriesByHost(CategoryHost.income);
  }
});

// Categories filtered by CategoryHost.expense
final expenseCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  try {
    final categoryService = await ref.watch(categoryServiceProvider.future);
    return categoryService.getCategoriesByHost(CategoryHost.expense);
  } catch (_) {
    final categoryDao = ref.watch(categoryDaoProvider);
    return categoryDao.getCategoriesByHost(CategoryHost.expense);
  }
});

// In-memory caches used by transaction forms to avoid re-fetching categories
// on every navigation to in/out screens.
final incomeCategoriesCacheProvider = StateProvider<List<Category>?>(
  (ref) => null,
);

final expenseCategoriesCacheProvider = StateProvider<List<Category>?>(
  (ref) => null,
);

final incomeCategoriesForTransactionProvider = FutureProvider<List<Category>>((
  ref,
) async {
  final cached = ref.read(incomeCategoriesCacheProvider);
  if (cached != null) return cached;

  final categories = await ref.watch(incomeCategoriesProvider.future);
  ref.read(incomeCategoriesCacheProvider.notifier).state = categories;
  return categories;
});

final expenseCategoriesForTransactionProvider = FutureProvider<List<Category>>((
  ref,
) async {
  final cached = ref.read(expenseCategoriesCacheProvider);
  if (cached != null) return cached;

  final categories = await ref.watch(expenseCategoriesProvider.future);
  ref.read(expenseCategoriesCacheProvider.notifier).state = categories;
  return categories;
});

// All categories
final allCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  try {
    final categoryService = await ref.watch(categoryServiceProvider.future);
    return categoryService.getAllCategories();
  } catch (_) {
    final categoryDao = ref.watch(categoryDaoProvider);
    return categoryDao.getAllCategories();
  }
});

/// Controla si las categorías por defecto ya se crearon en esta sesión.
/// Se resetea al reiniciar la app.
final defaultCategoriesCreatedProvider = StateProvider<bool>((ref) => false);

// All incomes
final allIncomesProvider = FutureProvider<List<Income>>((ref) async {
  try {
    final incomeService = await ref.watch(incomeServiceProvider.future);
    return incomeService.getAllIncomes();
  } catch (_) {
    final incomeDao = ref.watch(incomeDaoProvider);
    return incomeDao.getAllIncomes();
  }
});

final allRecurrentIncomesProvider = FutureProvider<List<RecurrentIncome>>((
  ref,
) async {
  try {
    final recurrentIncomeService = await ref.watch(
      recurrentIncomeServiceProvider.future,
    );
    return recurrentIncomeService.getAllRecurrentIncomes();
  } catch (_) {
    final recurrentIncomeDao = ref.watch(recurrentIncomeDaoProvider);
    return recurrentIncomeDao.getAllRecurrentIncomes();
  }
});

final allRecurrentExpensesProvider = FutureProvider<List<RecurrentExpense>>((
  ref,
) async {
  try {
    final recurrentExpenseService = await ref.watch(
      recurrentExpenseServiceProvider.future,
    );
    return recurrentExpenseService.getAllRecurrentExpenses();
  } catch (_) {
    final recurrentExpenseDao = ref.watch(recurrentExpenseDaoProvider);
    return recurrentExpenseDao.getAllRecurrentExpenses();
  }
});

final expenseByIdProvider = FutureProvider.family<Expense?, String>((
  ref,
  expenseId,
) async {
  final expenseService = await ref.watch(expenseServiceProvider.future);
  return expenseService.getExpenseById(expenseId);
});

final incomeByIdProvider = FutureProvider.family<Income?, String>((
  ref,
  incomeId,
) async {
  final incomeService = await ref.watch(incomeServiceProvider.future);
  return incomeService.getIncomeById(incomeId);
});
