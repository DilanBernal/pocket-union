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
  Future<List<Category>> getCategories() async {
    return await _categoryDao.getCategories();
  }

  @override
  Future<String> createCategory(NewCategoryDto dto, String coupleId) async {
    final id = await _categoryDao.createCategory(dto, coupleId);

    try {
      final category = await _categoryDao.getCategories().then(
            (list) => list.firstWhere((c) => c.id == id),
          );
      await _supabaseClient.from('category').insert(category.toJson());
    } catch (e) {
      debugPrint('CategoryService: error syncing to Supabase: $e');
    }

    return id;
  }
}
