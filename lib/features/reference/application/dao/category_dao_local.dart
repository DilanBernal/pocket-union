import 'package:pocket_union/core/enums/sync_status.dart';
import 'package:pocket_union/core/ports/logger_port.dart';
import 'package:pocket_union/core/utils/app_database.dart';
import 'package:pocket_union/core/utils/logger_provider.dart';
import 'package:pocket_union/features/reference/application/dto/category_filter_dto.dart';
import 'package:pocket_union/features/reference/domain/entities/category_entity.dart';
import 'package:pocket_union/features/reference/domain/enums/category_host.dart';
import 'package:pocket_union/features/reference/domain/ports/category_port_local.dart';
import 'package:pocket_union/features/reference/persistence/tables/category_table.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_dao_local.g.dart';

@Riverpod(keepAlive: true)
Future<CategoryPortLocal> categoryDaoLocal(Ref ref) async {
  final appDatabase = await ref.watch(appDatabaseProvider.future);
  final logger = ref.watch(loggerProvider);
  return CategoryDaoLocal(appDatabase: appDatabase, logger: logger);
}

class CategoryDaoLocal extends CategoryPortLocal {
  final AppDatabase _db;
  // final Uuid _uuid = const Uuid();
  final LoggerPort _logger;

  CategoryDaoLocal({
    required AppDatabase appDatabase,
    required LoggerPort logger,
  }) : _logger = logger,
       _db = appDatabase;

  @override
  Future<bool> createCategories(List<CategoryEntity> categories) async {
    // await _appDatabase
    //     .into(_appDatabase.categoryTable)
    //     .insert(
    //       categories
    //           .map((category) => categoryTableCompanionFromEntity(category))
    //           .toList(),
    //     );
    throw UnimplementedError();
  }

  @override
  Future<String> createCategory(CategoryEntity category) async {
    await _db
        .into(_db.categoryTable)
        .insertOnConflictUpdate(categoryTableCompanionFromEntity(category));
    return category.id;
  }

  @override
  Future<List<CategoryEntity>> createDefaultCategories(String idCouple) {
    // TODO: implement createDefaultCategories
    throw UnimplementedError();
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
  Future<List<CategoryEntity>> getAllCategoriesByCouple({String? coupleId}) {
    // TODO: implement getAllCategoriesByCouple
    throw UnimplementedError();
  }

  @override
  Future<List<CategoryEntity>> getByFilter(CategoryFilterDto filter) {
    // TODO: implement getByFilter
    throw UnimplementedError();
  }

  @override
  Future<List<CategoryEntity>> getCategoriesByHost(
    CategoryHost host, {
    String? coupleId,
  }) {
    // TODO: implement getCategoriesByHost
    throw UnimplementedError();
  }

  @override
  Future<List<CategoryEntity>> getCategoriesNeedingSync() {
    // TODO: implement getCategoriesNeedingSync
    throw UnimplementedError();
  }

  @override
  Future<CategoryEntity?> getCategoryById(String id) async {
    try {
      final result =
          await (_db.select(_db.categoryTable)
                ..where((tbl) => tbl.id.equals(id))
                ..limit(1))
              .getSingleOrNull();
      if (result == null) {
        return null;
      }
      return CategoryEntity(
        id: result.id,
        coupleId: result.coupleId,
        name: result.name,
        createdAt: result.createdAt,
        categoryHost: result.categoryHost,
        syncStatus: result.syncStatus,
        localUpdatedAt: result.localUpdatedAt ?? DateTime.now().toUtc(),
        icon: result.icon,
        shortDescription: result.shortDescription,
        color: result.color,
      );
    } catch (e, st) {
      _logger.error(
        'CategoryDaoDrift: getCategoryById falló',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  @override
  Future<bool> updateCategories(List<CategoryEntity> dtos) {
    // TODO: implement updateCategories
    throw UnimplementedError();
  }

  @override
  Future<bool> updateCategory(CategoryEntity entity) {
    // TODO: implement updateCategory
    throw UnimplementedError();
  }

  @override
  Future<void> updateSyncStatus(
    String categoryId,
    SyncStatus status, {
    DateTime? lastSyncAt,
  }) {
    // TODO: implement updateSyncStatus
    throw UnimplementedError();
  }

  @override
  Future<bool> upsertFromCloud(CategoryEntity category) {
    // TODO: implement upsertFromCloud
    throw UnimplementedError();
  }
}
