import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/dto/new_category_dto.dart';

abstract class CategoryPort {
  Future<String> createCategory(NewCategoryDto categoryDto);
  Future<bool> deleteCategory(String idCategory);
  Future createDefaultCategories(String idCouple);
  Future deleteAllCategories();
  Future<bool> createCategories(List<NewCategoryDto> categories);
  Future<List<Category>> getAllCategories();
  Future<List<Category>> getCategoriesByHost(CategoryHost host);
}
