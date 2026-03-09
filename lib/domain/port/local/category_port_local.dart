import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
import 'package:pocket_union/dto/update_category_dto.dart';

abstract class CategoryLocalPort {
  Future<String> createCategory(NewCategoryDto categoryDto);
  Future<bool> deleteCategory(String idCategory);

  ///Crea las categorias por defecto en el almacenamiento local siguiendo el id de la pareja
  Future<List<Category>> createDefaultCategories(String idCouple);

  ///Limpia todas las categorias existentes en el almacenamiento local
  Future deleteAllCategories();

  ///Usa una lista de dto de categorias para crearlas en el almacenamiento local
  Future<bool> createCategories(List<NewCategoryDto> categories);

  ///Trae todas las categorias guardadas en el almacenamiento local
  Future<List<Category>> getAllCategories();

  ///Trae todas las categorais filtrandolas por la pareja, en el dado caso
  ///que el usuario que este usando la app haya iniciado sesion
  ///recientemente y se ha iniciado sesion antes, se traera el de la sesion
  ///actual exclusivamente para evitar errores.
  Future<List<Category>> getAllCategoriesByCouple({String? coupleId});

  ///Trae todas las categorias pero filtrandolas por el CategoryHost
  ///En el caso en que no haya una coupleId agregada en el metodo se usara la que
  ///este guardada en el almacenamiento local
  Future<List<Category>> getCategoriesByHost(
    CategoryHost host, {
    String? coupleId,
  });

  /// Actualiza una sola categoría.
  Future<bool> updateCategory(UpdateCategoryDto dto);

  /// Actualiza múltiples categorías.
  Future<bool> updateCategories(List<UpdateCategoryDto> dtos);
}
