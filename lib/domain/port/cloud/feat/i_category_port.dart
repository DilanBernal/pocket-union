import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
import 'package:pocket_union/dto/update_category_dto.dart';

abstract class ICategoryPort {
  Future<String> createCategory(NewCategoryDto categoryDto);

  Future<bool> deleteCategory(String idCategory);

  Future deleteAllCategories();

  Future<bool> createCategories(List<NewCategoryDto> categories);

  Future<List<Category>> getAllCategories();

  Future<List<Category>> getCategoriesByHost(CategoryHost host);

  Future<bool> updateCategory(UpdateCategoryDto dto);

  Future<bool> updateCategories(List<UpdateCategoryDto> dtos);

  Future<bool> syncCategory(String categoryId);

  Future<Map<String, bool>> syncAllCategories();
}
