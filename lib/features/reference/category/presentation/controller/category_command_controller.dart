import 'package:pocket_union/features/reference/application/services/category_service.dart';
import 'package:pocket_union/features/reference/category/dtos/category_ins_dto.dart';
import 'package:pocket_union/features/reference/category/dtos/category_upd_dto.dart';
import 'package:pocket_union/features/reference/domain/entities/category_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_command_controller.g.dart';

@riverpod
class CategoryCommandController extends _$CategoryCommandController {
  @override
  AsyncValue build() => const AsyncData(null);

  Future<void> createCategory(CategoryInsDto request) async {
    state = const AsyncLoading();
    try {
      final categoryService = await ref.read(categoryServiceProvider.future);
      final result = await categoryService.createCategory(request);
      if (result.isEmpty) {
        state = AsyncData(null);
        return;
      }
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
      return;
    }
  }

  Future<void> updateCategory(CategoryUpdDto request) async {
    state = const AsyncLoading();
    try {
      final categoryService = await ref.read(categoryServiceProvider.future);
      final result = await categoryService.updateCategory(request);
      if (result) {
        state = AsyncData(result);
        return;
      }
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
      return;
    }
  }

  Future<CategoryEntity?> getCategoryById(String categoryId) async {
    final categoryService = await ref.read(categoryServiceProvider.future);
    return categoryService.getCategoryById(categoryId);
  }
}
