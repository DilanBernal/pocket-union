import 'package:pocket_union/features/reference/category/dtos/category_ins_dto.dart';
import 'package:pocket_union/features/reference/category/dtos/category_upd_dto.dart';
import 'package:pocket_union/features/reference/domain/entities/category_entity.dart';
import 'package:pocket_union/features/reference/domain/enums/category_host.dart';

abstract class CategoryPort {
  Future<String> createCategory(CategoryInsDto categoryDto);

  Future<bool> deleteCategory(String idCategory);

  Future deleteAllCategories();

  Future<bool> createCategories(List<CategoryInsDto> categories);

  Future<List<CategoryEntity>> getAllCategories();

  Future<List<CategoryEntity>> getCategoriesByHost(CategoryHost host);

  Future<bool> updateCategory(CategoryUpdDto dto);

  Future<bool> updateCategories(List<CategoryUpdDto> dtos);

  Future<bool> syncCategory(String categoryId);

  Future<Map<String, bool>> syncAllCategories();
}
