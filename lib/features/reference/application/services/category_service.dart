import 'package:pocket_union/core/enums/sync_status.dart';
import 'package:pocket_union/core/ports/logger_port.dart';
import 'package:pocket_union/core/utils/logger_provider.dart';
import 'package:pocket_union/core/utils/shared_preferences.dart';
import 'package:pocket_union/core/utils/supabase_client_provider.dart';
import 'package:pocket_union/features/reference/application/dao/category_dao_local.dart';
import 'package:pocket_union/features/reference/category/dtos/category_ins_dto.dart';
import 'package:pocket_union/features/reference/category/dtos/category_upd_dto.dart';
import 'package:pocket_union/features/reference/domain/entities/category_entity.dart';
import 'package:pocket_union/features/reference/domain/enums/category_host.dart';
import 'package:pocket_union/features/reference/domain/ports/category_port.dart';
import 'package:pocket_union/features/reference/domain/ports/category_port_local.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

part 'category_service.g.dart';

@Riverpod(keepAlive: true)
Future<CategoryPort> categoryService(Ref ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final logger = ref.watch(loggerProvider);
  final categoryPortLocal = await ref.watch(categoryDaoLocalProvider.future);
  final sharedPrefsCache = await ref.watch(
    sharedPreferencesWithCacheProvider.future,
  );
  return CategoryService(
    supabaseClient: supabaseClient,
    logger: logger,
    categoryPortLocal: categoryPortLocal,
    sharedPrefsCache: sharedPrefsCache,
  );
}

class CategoryService extends CategoryPort {
  final CategoryPortLocal _categoryPortLocal;
  final SupabaseClient _supabaseClient;
  final SharedPreferencesWithCache _sharedPrefsCache;
  final LoggerPort _logger;
  final Uuid _uuid = const Uuid();

  CategoryService({
    required SupabaseClient supabaseClient,
    required LoggerPort logger,
    required CategoryPortLocal categoryPortLocal,
    required SharedPreferencesWithCache sharedPrefsCache,
  }) : _supabaseClient = supabaseClient,
       _logger = logger,
       _categoryPortLocal = categoryPortLocal,
       _sharedPrefsCache = sharedPrefsCache;
  @override
  Future<bool> createCategories(List<CategoryInsDto> categories) async {
    try {
      final coupleId = _sharedPrefsCache.getString(
        PreferencesCacheKeys.coupleId,
      );
      if (coupleId == null) {
        throw Exception('Couple ID is null');
      }
      final categoryEntities = categories.map(
        (e) => CategoryEntity(
          id: _uuid.v4(),
          coupleId: coupleId,
          name: e.name,
          createdAt: DateTime.now().toUtc(),
          categoryHost: e.host,
          syncStatus: e.status,
          localUpdatedAt: DateTime.now().toUtc(),
          color: e.color,
          icon: e.icon,
          shortDescription: e.shortDescription,
          lastSyncedAt: DateTime.now().toUtc(),
        ),
      );

      final localResult = await _categoryPortLocal.createCategories(
        categoryEntities.toList(),
      );

      try {
        await _supabaseClient
            .from('categories')
            .insert(categoryEntities.map((e) => e.toMap()));

        for (final category in categoryEntities) {
          await _categoryPortLocal.updateSyncStatus(
            category.id,
            SyncStatus.synced,
            lastSyncAt: DateTime.now().toUtc(),
          );
        }
      } catch (e) {
        _logger.error('Error creating categories in cloud', error: e);
      }

      return localResult;
    } catch (e, st) {
      _logger.error('Error creating categories', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<String> createCategory(CategoryInsDto categoryDto) async {
    final coupleId = _sharedPrefsCache.getString(PreferencesCacheKeys.coupleId);
    if (coupleId == null) {
      throw Exception('Couple ID is null');
    }
    final categoryEntity = CategoryEntity(
      id: _uuid.v4(),
      coupleId: coupleId,
      name: categoryDto.name,
      createdAt: categoryDto.createdAt,
      categoryHost: categoryDto.host,
      syncStatus: categoryDto.status,
      localUpdatedAt: DateTime.now().toUtc(),
      color: categoryDto.color,
      icon: categoryDto.icon,
      shortDescription: categoryDto.shortDescription,
    );

    final localResult = await _categoryPortLocal.createCategory(categoryEntity);

    try {
      await _supabaseClient.from('category').upsert(categoryEntity.toMap());

      await _categoryPortLocal.updateSyncStatus(
        categoryEntity.id,
        SyncStatus.synced,
      );
    } catch (e) {
      _logger.error('Error creating category in cloud', error: e);
    }
    return localResult;
  }

  @override
  Future<dynamic> deleteAllCategories() {
    // TODO: implement deleteAllCategories
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteCategory(String idCategory) {
    // TODO: implement deleteCategory
    throw UnimplementedError();
  }

  @override
  Future<List<CategoryEntity>> getAllCategories() {
    // TODO: implement getAllCategories
    throw UnimplementedError();
  }

  @override
  Future<List<CategoryEntity>> getCategoriesByHost(CategoryHost host) {
    // TODO: implement getCategoriesByHost
    throw UnimplementedError();
  }

  @override
  Future<Map<String, bool>> syncAllCategories() {
    // TODO: implement syncAllCategories
    throw UnimplementedError();
  }

  @override
  Future<bool> syncCategory(String categoryId) {
    // TODO: implement syncCategory
    throw UnimplementedError();
  }

  @override
  Future<bool> updateCategories(List<CategoryUpdDto> dtos) {
    // TODO: implement updateCategories
    throw UnimplementedError();
  }

  @override
  Future<bool> updateCategory(CategoryUpdDto dto) {
    // TODO: implement updateCategory
    throw UnimplementedError();
  }
}
