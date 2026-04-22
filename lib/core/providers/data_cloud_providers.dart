import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/data_local_providers.dart';
import 'package:pocket_union/core/providers/utils_providers.dart';
import 'package:pocket_union/core/services/auth/couple_service.dart';
import 'package:pocket_union/core/services/features/category_service.dart';
import 'package:pocket_union/core/services/features/goal_contribution_service.dart';
import 'package:pocket_union/core/services/features/goal_service.dart';
import 'package:pocket_union/domain/port/cloud/auth/i_couple_port.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_category_port.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_goal_contribution_port.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_goal_port.dart';

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
