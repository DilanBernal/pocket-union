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
            .from('category')
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
  Future<dynamic> deleteAllCategories() async {
    try {
      final localResult = await _categoryPortLocal.deleteAllCategories();

      try {
        final coupleId = _sharedPrefsCache.getString(
          PreferencesCacheKeys.coupleId,
        );
        if (coupleId != null) {
          await _supabaseClient
              .from('category')
              .update({'is_deleted': true})
              .eq('couple_id', coupleId);
        }
      } catch (e) {
        _logger.error('Error deleting all categories in cloud', error: e);
      }

      return localResult;
    } catch (e, st) {
      _logger.error('Error deleting all categories', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<bool> deleteCategory(String idCategory) async {
    try {
      await _categoryPortLocal.updateSyncStatus(
        idCategory,
        SyncStatus.pendingDelete,
      );
      try {
        await _supabaseClient
            .from('category')
            .update({'is_deleted': true})
            .eq('id', idCategory);
        await _categoryPortLocal.deleteCategory(idCategory);
      } catch (e) {
        _logger.error('Error deleting category in cloud', error: e);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    try {
      final categoriesInLocal = await _categoryPortLocal.getAllCategories();

      try {
        final categoriesInCloudMap = await _supabaseClient
            .from('category')
            .select()
            .eq('is_deleted', false);

        List<CategoryEntity> categoriesInCloud = [];
        for (final map in categoriesInCloudMap) {
          try {
            final category = CategoryEntity.fromMap(map);
            categoriesInCloud.add(
              category
                ..lastSyncedAt = DateTime.now().toUtc()
                ..syncStatus = SyncStatus.synced
                ..localUpdatedAt = DateTime.now().toUtc(),
            );
          } catch (e) {
            _logger.error('Error parsing category from cloud: $map', error: e);
          }
        }

        if (categoriesInCloud.isNotEmpty) {
          if (categoriesInCloud.length > categoriesInLocal.length) {
            await _categoryPortLocal.createCategories(
              categoriesInCloud,
              // .where((e) => !categoriesInLocal.any((x) => x.id == e.id))
              // .toList(),
            );
          }
          return categoriesInCloud.toList();
        }
      } catch (e) {
        _logger.logObject(e);
      }
      return categoriesInLocal
          .where((category) => category.isDeleted == false)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CategoryEntity>> getCategoriesByHost(CategoryHost host) async {
    try {
      final coupleId = _sharedPrefsCache.getString(
        PreferencesCacheKeys.coupleId,
      );
      final categoriesInLocal = await _categoryPortLocal.getCategoriesByHost(
        host,
        coupleId: coupleId,
      );

      try {
        var query = _supabaseClient
            .from('category')
            .select()
            .eq('is_deleted', false)
            .eq('category_host', host.name.toUpperCase());

        if (coupleId != null) {
          query = query.eq('couple_id', coupleId);
        }

        final categoriesInCloudMap = await query;
        final categoriesInCloud = <CategoryEntity>[];

        for (final map in categoriesInCloudMap) {
          try {
            final category = CategoryEntity.fromMap(map)
              ..lastSyncedAt = DateTime.now().toUtc()
              ..syncStatus = SyncStatus.synced
              ..localUpdatedAt = DateTime.now().toUtc();

            categoriesInCloud.add(category);
            await _categoryPortLocal.upsertFromCloud(category);
          } catch (e) {
            _logger.error(
              'Error parsing category by host from cloud: $map',
              error: e,
            );
          }
        }

        if (categoriesInCloud.isNotEmpty) {
          return categoriesInCloud;
        }
      } catch (e) {
        _logger.error('Error getting categories by host from cloud', error: e);
      }

      return categoriesInLocal;
    } catch (e, st) {
      _logger.error(
        'Error getting categories by host',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<Map<String, bool>> syncAllCategories() async {
    final syncResults = <String, bool>{};

    try {
      final categoriesNeedingSync = await _categoryPortLocal
          .getCategoriesNeedingSync();

      for (final category in categoriesNeedingSync) {
        syncResults[category.id] = await syncCategory(category.id);
      }

      return syncResults;
    } catch (e, st) {
      _logger.error('Error syncing all categories', error: e, stackTrace: st);
      return syncResults;
    }
  }

  @override
  Future<bool> syncCategory(String categoryId) async {
    try {
      final category = await _categoryPortLocal.getCategoryById(categoryId);
      if (category == null) {
        return false;
      }

      if (category.syncStatus == SyncStatus.pendingDelete ||
          category.localDeletedAt != null) {
        await _supabaseClient
            .from('category')
            .update({'is_deleted': true})
            .eq('id', categoryId);
        await _categoryPortLocal.deleteCategory(categoryId);
        return true;
      }

      await _supabaseClient.from('category').upsert(category.toMap());
      await _categoryPortLocal.updateSyncStatus(
        categoryId,
        SyncStatus.synced,
        lastSyncAt: DateTime.now().toUtc(),
      );

      return true;
    } catch (e, st) {
      _logger.error(
        'Error syncing category $categoryId',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  @override
  Future<bool> updateCategories(List<CategoryUpdDto> dtos) async {
    try {
      final now = DateTime.now().toUtc();
      final entitiesToUpdate = <CategoryEntity>[];
      var localResult = true;

      for (final dto in dtos) {
        final current = await _categoryPortLocal.getCategoryById(dto.id);
        if (current == null) {
          localResult = false;
          continue;
        }

        entitiesToUpdate.add(
          CategoryEntity(
            id: current.id,
            coupleId: current.coupleId,
            name: dto.name,
            icon: dto.icon,
            shortDescription: dto.shortDescription,
            color: dto.color,
            createdAt: current.createdAt,
            categoryHost: dto.host,
            syncStatus: SyncStatus.pendingUpdate,
            localUpdatedAt: now,
            lastSyncedAt: current.lastSyncedAt,
            localDeletedAt: current.localDeletedAt,
          ),
        );
      }

      if (entitiesToUpdate.isEmpty) {
        return false;
      }

      localResult =
          localResult &&
          await _categoryPortLocal.updateCategories(entitiesToUpdate);

      try {
        await _supabaseClient
            .from('category')
            .upsert(entitiesToUpdate.map((entity) => entity.toMap()).toList());

        for (final category in entitiesToUpdate) {
          await _categoryPortLocal.updateSyncStatus(
            category.id,
            SyncStatus.synced,
            lastSyncAt: DateTime.now().toUtc(),
          );
        }
      } catch (e) {
        _logger.error('Error updating categories in cloud', error: e);
      }

      return localResult;
    } catch (e, st) {
      _logger.error('Error updating categories', error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<bool> updateCategory(CategoryUpdDto dto) async {
    try {
      final current = await _categoryPortLocal.getCategoryById(dto.id);
      if (current == null) {
        return false;
      }

      final categoryEntity = CategoryEntity(
        id: current.id,
        coupleId: current.coupleId,
        name: dto.name,
        icon: dto.icon,
        shortDescription: dto.shortDescription,
        color: dto.color,
        createdAt: current.createdAt,
        categoryHost: dto.host,
        syncStatus: SyncStatus.pendingUpdate,
        localUpdatedAt: DateTime.now().toUtc(),
        lastSyncedAt: current.lastSyncedAt,
        localDeletedAt: current.localDeletedAt,
      );

      final localResult = await _categoryPortLocal.updateCategory(
        categoryEntity,
      );

      try {
        await _supabaseClient.from('category').upsert(categoryEntity.toMap());

        await _categoryPortLocal.updateSyncStatus(
          categoryEntity.id,
          SyncStatus.synced,
          lastSyncAt: DateTime.now().toUtc(),
        );
      } catch (e) {
        _logger.error('Error updating category in cloud', error: e);
      }

      return localResult;
    } catch (e, st) {
      _logger.error('Error updating category', error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<CategoryEntity?> getCategoryById(String categoryId) {
    return _categoryPortLocal.getCategoryById(categoryId);
  }
}
