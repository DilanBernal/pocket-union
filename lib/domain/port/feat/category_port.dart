import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/dto/new_category_dto.dart';

abstract class CategoryPort {
  Future<List<Category>> getAllCategories();
  Future<String> createCategory(NewCategoryDto dto);
}
