// CategoryService provider (offline-first)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/data_local_providers.dart';
import 'package:pocket_union/core/providers/utils_providers.dart';
import 'package:pocket_union/core/services/features/category_service.dart';
import 'package:pocket_union/domain/port/cloud/feat/category_port_cloud.dart';

final categoryServiceProvider = FutureProvider<CategoryCloudPort>((ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final categoryDao = ref.watch(categoryDaoProvider);
  final loggerService = ref.watch(loggerProvider);
  return CategoryService(categoryDao, supabaseClient, loggerService);
});
