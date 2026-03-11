import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/port/cloud/feat/i_category_port.dart';
import 'package:pocket_union/domain/port/local/category_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
import 'package:pocket_union/dto/update_category_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryService implements ICategoryPort {
  final CategoryLocalPort _categoryDao;
  final SupabaseClient _supabaseClient;
  final LoggerPort _logger;

  CategoryService(this._categoryDao, this._supabaseClient, this._logger);

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
      _logger.error(
        'CategoryService: no se pudo sincronizar con Supabase: ${e.toString()}',
      );
    }

    return id;
  }

  @override
  Future<bool> deleteCategory(String idCategory) async {
    return await _categoryDao.deleteCategory(idCategory);
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
    var categoriesInLocal = await _categoryDao.getAllCategories();

    try {
      final response = await _supabaseClient.from('category').select();
      final List<Category> categoriesInCloud = (response as List)
          // .map(toElement)
          .map((e) => Category.fromJson(e)..syncStatus = SyncStatus.synced)
          .toList();
      List<Category> categoriesNewsInCloudNotLocal = [];
      for (var categoryInCloud in categoriesInCloud) {
        if (!categoriesInLocal.any((c) => c.id == categoryInCloud.id)) {
          categoriesNewsInCloudNotLocal.add(categoryInCloud);
        }
      }
      if (categoriesNewsInCloudNotLocal.isNotEmpty) {
        await _categoryDao.updateCategories(
          categoriesNewsInCloudNotLocal
              .map(
                (c) => UpdateCategoryDto(
                  id: c.id,
                  color: c.color,
                  name: c.name,
                  host: c.categoryHost,
                  icon: c.icon,
                  shortDescription: c.shortDescription,
                  status: SyncStatus.synced,
                ),
              )
              .toList(),
        );
        categoriesInLocal.addAll(categoriesNewsInCloudNotLocal);
      }
    } catch (e) {
      _logger.error("Ocurrio un error con supabase, ${e.toString()}");
    }
    return categoriesInLocal;
  }

  /// Actualiza una categoría primero en SQLite (offline-first),
  /// luego intenta sincronizar con Supabase sin bloquear si falla.
  @override
  Future<bool> updateCategory(UpdateCategoryDto dto) async {
    final localSuccess = await _categoryDao.updateCategory(dto);
    if (!localSuccess) return false;

    // Intentar sincronizar con Supabase — si falla, no afecta la ejecución
    try {
      final supabaseData = dto.toSupabaseMap();
      if (supabaseData.isNotEmpty) {
        await _supabaseClient
            .from('category')
            .update(supabaseData)
            .eq('id', dto.id);

        // Si Supabase fue exitoso, marcar como synced
        await _categoryDao.updateSyncStatus(
          dto.id,
          SyncStatus.synced,
          lastSyncAt: DateTime.now(),
        );
      }
    } catch (e) {
      _logger.error(
        'CategoryService: Supabase update falló (no crítico): ${e.toString()}',
      );
    }

    return true;
  }

  /// Actualiza múltiples categorías primero en SQLite,
  /// luego intenta sincronizar cada una con Supabase.
  @override
  Future<bool> updateCategories(List<UpdateCategoryDto> dtos) async {
    final localSuccess = await _categoryDao.updateCategories(dtos);
    if (!localSuccess) return false;

    // Intentar sincronizar con Supabase — si falla, no afecta la ejecución
    for (final dto in dtos) {
      try {
        final supabaseData = dto.toSupabaseMap();
        if (supabaseData.isNotEmpty) {
          await _supabaseClient
              .from('category')
              .update(supabaseData)
              .eq('id', dto.id);

          await _categoryDao.updateSyncStatus(
            dto.id,
            SyncStatus.synced,
            lastSyncAt: DateTime.now(),
          );
        }
      } catch (e) {
        _logger.error(
          'CategoryService: Supabase update falló para ${dto.id}: $e',
        );
      }
    }

    return true;
  }

  /// Sincroniza una categoría individual con Supabase.
  /// - Si sync_status = 'pending': intenta INSERT en Supabase.
  /// - Si local_updated_at > last_sync_at: intenta UPDATE en Supabase.
  /// - Si falla: marca como 'conflict' en SQLite.
  @override
  Future<bool> syncCategory(String categoryId) async {
    final category = await _categoryDao.getCategoryById(categoryId);
    if (category == null) return false;

    try {
      if (category.syncStatus == SyncStatus.pending ||
          category.syncStatus == SyncStatus.conflict) {
        // Categoría nueva — INSERT en Supabase
        await _supabaseClient.from('category').upsert(category.toJson());
      } else if (category.lastSyncAt != null &&
          category.localUpdatedAt.isAfter(category.lastSyncAt!)) {
        // Categoría con cambios locales — UPDATE en Supabase
        await _supabaseClient
            .from('category')
            .update(category.toJson())
            .eq('id', categoryId);
      } else {
        // No necesita sincronización
        return true;
      }

      // Éxito — marcar como synced
      await _categoryDao.updateSyncStatus(
        categoryId,
        SyncStatus.synced,
        lastSyncAt: DateTime.now(),
      );
      return true;
    } catch (e) {
      _logger.error('CategoryService: syncCategory falló para $categoryId: $e');
      // Fallo — marcar como conflict
      await _categoryDao.updateSyncStatus(categoryId, SyncStatus.conflict);
      return false;
    }
  }

  /// Sincroniza todas las categorías pendientes con Supabase.
  /// Retorna un Map<categoryId, success> con el resultado de cada una.
  @override
  Future<Map<String, bool>> syncAllCategories() async {
    final results = <String, bool>{};
    final categoriesToSync = await _categoryDao.getCategoriesNeedingSync();

    if (categoriesToSync.isEmpty) return results;

    for (final category in categoriesToSync) {
      final success = await syncCategory(category.id);
      results[category.id] = success;
    }

    return results;
  }

  @override
  Future<List<Category>> getCategoriesByHost(CategoryHost host) async {
    final categoriesInLocal = await _categoryDao.getCategoriesByHost(host);
    try {
      final categoriesInCloud = await _supabaseClient
          .from('category')
          .select()
          .eq('host', host);
    } catch (e) {
      _logger.logObject(e, label: "Error en category Service");
    }
    return categoriesInLocal;
  }
}
