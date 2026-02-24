import 'package:flutter/foundation.dart' hide Category;
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/port/feat/category_port.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryService implements CategoryPort {
  final CategoryPort _categoryDao;
  final SupabaseClient _supabaseClient;

  CategoryService(this._categoryDao, this._supabaseClient);

  @override
  Future<String> createCategory(NewCategoryDto categoryDto) async {
    final id = await _categoryDao.createCategory(categoryDto);

    try {
      await _supabaseClient.from('category').insert({
        'id': id,
        'couple_id': categoryDto.coupleId,
        'name': categoryDto.name,
        'icon': categoryDto.icon,
        'short_description': categoryDto.shortDescription,
        'color': categoryDto.color,
        'category_host': categoryDto.host.value,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // debugPrint('CategoryService: no se pudo sincronizar con Supabase: $e');
    }

    return id;
  }

  @override
  Future<bool> deleteCategory(String idCategory) async {
    return await _categoryDao.deleteCategory(idCategory);
  }

  @override
  Future createDefaultCategories(String idCouple) async {
    return await _categoryDao.createDefaultCategories(idCouple);
  }

  @override
  Future deleteAllCategories() async {
    return await _categoryDao.deleteAllCategories();
  }

  @override
  Future<bool> createCategories(List<NewCategoryDto> categories) async {
    return await _categoryDao.createCategories(categories);
  }

  @override
  Future<List<Category>> getAllCategories() async {
    return await _categoryDao.getAllCategories();
  }

  @override
  Future<List<Category>> getCategoriesByHost(CategoryHost host) async {
    return await _categoryDao.getCategoriesByHost(host);
  }
}
