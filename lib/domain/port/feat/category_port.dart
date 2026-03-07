import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
import 'package:pocket_union/dto/update_category_dto.dart';

abstract class CategoryPort {
  Future<String> createCategory(NewCategoryDto categoryDto);
  Future<bool> deleteCategory(String idCategory);
  Future<List<Category>> createDefaultCategories(String idCouple);
  Future deleteAllCategories();
  Future<bool> createCategories(List<NewCategoryDto> categories);
  Future<List<Category>> getAllCategories();
  Future<List<Category>> getAllCategoriesByCouple({String? coupleId});
  Future<List<Category>> getCategoriesByHost(
    CategoryHost host, {
    String? coupleId,
  });

  /// Actualiza una sola categoría.
  Future<bool> updateCategory(UpdateCategoryDto dto);

  /// Actualiza múltiples categorías.
  Future<bool> updateCategories(List<UpdateCategoryDto> dtos);

  /// Sincroniza una categoría individual con Supabase.
  /// Retorna true si la sincronización fue exitosa.
  Future<bool> syncCategory(String categoryId);

  /// Sincroniza todas las categorías pendientes con Supabase.
  /// Retorna un Map<categoryId, success> indicando el resultado de cada una.
  Future<Map<String, bool>> syncAllCategories();
}
