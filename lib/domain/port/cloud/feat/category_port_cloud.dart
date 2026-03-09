import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
import 'package:pocket_union/dto/update_category_dto.dart';

abstract class CategoryCloudPort {
  ///Crea una categoria en el cloud siguiendo el dto de la categoria
  Future<String> createCategory(NewCategoryDto categoryDto);

  ///Elimina una categoria en el cloud usando el id de la categoria
  Future<bool> deleteCategory(String idCategory);

  ///Crea varias categorias en el cloud, usando una lista de categorias
  Future<bool> createCategories(List<NewCategoryDto> categories);

  ///Trae todas las categorias disponibles en el cloud
  Future<List<Category>> getAllCategories();

  /// Actualiza una sola categoría.
  Future<bool> updateCategory(UpdateCategoryDto dto);

  /// Actualiza múltiples categorías.
  Future<bool> updateCategories(List<UpdateCategoryDto> dtos);

  /// Sincroniza una categoría individual con el clouod.
  /// Retorna true si la sincronización fue exitosa.
  Future<bool> syncCategory(String categoryId);

  /// Sincroniza todas las categorías pendientes con el cloud.
  // ignore: unintended_html_in_doc_comment
  /// Retorna un Map<categoryId, success> indicando el resultado de cada una.
  Future<Map<String, bool>> syncAllCategories();
}
