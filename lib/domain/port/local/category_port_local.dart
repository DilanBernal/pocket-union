import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/dto/filter/category_filter_dto.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
import 'package:pocket_union/dto/update_category_dto.dart';

abstract class CategoryLocalPort {
  Future<String> createCategory(NewCategoryDto categoryDto);

  Future<Category?> getCategoryById(String id);

  Future<bool> deleteCategory(String idCategory);

  Future deleteAllCategories();

  Future<bool> createCategories(List<NewCategoryDto> categories);

  Future<List<Category>> createDefaultCategories(String idCouple);

  Future<List<Category>> getAllCategories();

  Future<List<Category>> getAllCategoriesByCouple({String? coupleId});

  Future<List<Category>> getCategoriesByHost(
    CategoryHost host, {
    String? coupleId,
  });

  Future<List<Category>> getByFilter(CategoryFilterDto filter);

  Future<bool> updateCategory(UpdateCategoryDto dto);

  Future<bool> updateCategories(List<UpdateCategoryDto> dtos);

  Future<List<Category>> getCategoriesNeedingSync();

  Future<void> updateSyncStatus(
    String categoryId,
    SyncStatus status, {
    DateTime? lastSyncAt,
  });
}
