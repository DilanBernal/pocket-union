import 'package:pocket_union/core/enums/sync_status.dart';
import 'package:pocket_union/features/reference/application/dto/category_filter_dto.dart';
import 'package:pocket_union/features/reference/domain/entities/category_entity.dart';
import 'package:pocket_union/features/reference/domain/enums/category_host.dart';

abstract class CategoryPortLocal {
  Future<String> createCategory(CategoryEntity categoryDto);

  Future<CategoryEntity?> getCategoryById(String id);

  Future<bool> deleteCategory(String idCategory);

  Future deleteAllCategories();

  Future<bool> createCategories(List<CategoryEntity> categories);

  Future<List<CategoryEntity>> createDefaultCategories(String idCouple);

  Future<List<CategoryEntity>> getAllCategories();

  Future<List<CategoryEntity>> getAllCategoriesByCouple({String? coupleId});

  Future<List<CategoryEntity>> getCategoriesByHost(
    CategoryHost host, {
    String? coupleId,
  });

  Future<List<CategoryEntity>> getByFilter(CategoryFilterDto filter);

  Future<bool> updateCategory(CategoryEntity entity);

  Future<bool> updateCategories(List<CategoryEntity> entity);

  Future<List<CategoryEntity>> getCategoriesNeedingSync();

  Future<void> updateSyncStatus(
    String categoryId,
    SyncStatus status, {
    DateTime? lastSyncAt,
  });

  /// Inserta una categoría proveniente del cloud en SQLite.
  /// Usa REPLACE para manejar conflictos si ya existe.
  Future<bool> upsertFromCloud(CategoryEntity category);
}
