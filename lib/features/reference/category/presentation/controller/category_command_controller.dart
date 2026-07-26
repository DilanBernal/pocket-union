import 'package:pocket_union/features/reference/category/dtos/category_ins_dto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_command_controller.g.dart';

@riverpod
class CategoryCommandController extends _$CategoryCommandController {
  @override
  AsyncValue build() => const AsyncData(null);

  Future<void> createCategory(CategoryInsDto request) async {
    state = const AsyncLoading();
    try {
      // final categoryPort = await ref.
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
