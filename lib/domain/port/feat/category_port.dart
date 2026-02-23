import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/dto/new_category_dto.dart';

abstract class CategoryPort {
  Future<List<Category>> getCategories();
  Future<String> createCategory(NewCategoryDto dto, String coupleId);
}
