import 'package:flutter/foundation.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/port/feat/category_port.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryService implements CategoryPort {
  final CategoryPort _categoryDao;
  final SupabaseClient _supabaseClient;

  CategoryService(this._categoryDao, this._supabaseClient);

  @override
  Future<List<Category>> getAllCategories() async {
    return await _categoryDao.getAllCategories();
  }

  @override
  Future<String> createCategory(NewCategoryDto dto) async {
    final id = await _categoryDao.createCategory(dto);

    try {
      await _supabaseClient.from('category').insert({
        'id': id,
        'name': dto.name,
        'couple_id': dto.coupleId,
        'icon': dto.icon,
        'short_description': dto.shortDescription,
        'color': dto.color,
        'category_host': dto.host.value,
      });
    } catch (e) {
      debugPrint('CategoryService: no se pudo sincronizar con Supabase: $e');
    }

    return id;
  }
}
