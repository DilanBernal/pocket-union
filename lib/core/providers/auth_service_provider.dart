import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/data_cloud_providers.dart';
import 'package:pocket_union/core/providers/data_local_providers.dart';
import 'package:pocket_union/core/providers/utils_providers.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/models/couple.dart';
import 'package:pocket_union/domain/models/income.dart';
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
