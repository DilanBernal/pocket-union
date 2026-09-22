import 'package:pocket_union/features/reference/application/services/category_service.dart';
import 'package:pocket_union/features/reference/domain/entities/category_entity.dart';
import 'package:pocket_union/features/reference/domain/enums/category_host.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'categories_list_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<CategoryEntity>> allCategoriesList(Ref ref) async {
  final categoryService = await ref.read(categoryServiceProvider.future);
  return categoryService.getAllCategories();
}

@Riverpod(keepAlive: true)
Future<List<CategoryEntity>> categoriesByHost(
  Ref ref,
  CategoryHost host,
) async {
  final categoryService = await ref.read(categoryServiceProvider.future);
  return categoryService.getCategoriesByHost(host);
}
