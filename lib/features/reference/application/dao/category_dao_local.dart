import 'package:drift/drift.dart';
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
import 'package:uuid/uuid.dart';

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
  final Uuid _uuid = const Uuid();

  CategoryDaoLocal({
    required AppDatabase appDatabase,
    required LoggerPort logger,
  }) : _logger = logger,
       _db = appDatabase;

  @override
  Future<bool> createCategories(List<CategoryEntity> categories) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.categoryTable,
        categories.map(categoryTableCompanionFromEntity).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
    return true;
  }

  @override
  Future<String> createCategory(CategoryEntity category) async {
    await _db
        .into(_db.categoryTable)
        .insertOnConflictUpdate(categoryTableCompanionFromEntity(category));
    return category.id;
  }

  @override
  Future<List<CategoryEntity>> createDefaultCategories(String idCouple) async {
    final now = DateTime.now().toUtc();
    final defaults = <CategoryEntity>[
      CategoryEntity(
        id: _uuid.v4(),
        coupleId: idCouple,
        name: 'Food',
        icon: '🍽️',
        color: '#FF8A65',
        createdAt: now,
        categoryHost: CategoryHost.expense,
        syncStatus: SyncStatus.synced,
        localUpdatedAt: now,
        lastSyncedAt: now,
      ),
      CategoryEntity(
        id: _uuid.v4(),
        coupleId: idCouple,
        name: 'Housing',
        icon: '🏠',
        color: '#64B5F6',
        createdAt: now,
        categoryHost: CategoryHost.expense,
        syncStatus: SyncStatus.synced,
        localUpdatedAt: now,
        lastSyncedAt: now,
      ),
      CategoryEntity(
        id: _uuid.v4(),
        coupleId: idCouple,
        name: 'Transport',
        icon: '🚗',
        color: '#81C784',
        createdAt: now,
        categoryHost: CategoryHost.expense,
        syncStatus: SyncStatus.synced,
        localUpdatedAt: now,
        lastSyncedAt: now,
      ),
      CategoryEntity(
        id: _uuid.v4(),
        coupleId: idCouple,
        name: 'Salary',
        icon: '💰',
        color: '#FFD54F',
        createdAt: now,
        categoryHost: CategoryHost.income,
        syncStatus: SyncStatus.synced,
        localUpdatedAt: now,
        lastSyncedAt: now,
      ),
    ];

    await _db.batch((batch) {
      batch.insertAll(
        _db.categoryTable,
        defaults.map(categoryTableCompanionFromEntity).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });

    return defaults;
  }

  @override
  Future<dynamic> deleteAllCategories() async {
    await _db.delete(_db.categoryTable).go();
    return true;
  }

  @override
  Future<bool> deleteCategory(String idCategory) async {
    await (_db.delete(
      _db.categoryTable,
    )..where((tbl) => tbl.id.equals(idCategory))).go();
    return true;
  }

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    final entities = await _db
        .select(_db.categoryTable)
        .map(
          (row) => CategoryEntity(
            id: row.id,
            coupleId: row.coupleId,
            name: row.name,
            createdAt: row.createdAt,
            categoryHost: row.categoryHost,
            syncStatus: row.syncStatus,
            localUpdatedAt: row.localUpdatedAt ?? DateTime.now().toUtc(),
            localDeletedAt: row.localDeletedAt,
            icon: row.icon,
            color: row.color,
            lastSyncedAt: row.lastSyncedAt,
            shortDescription: row.shortDescription,
          ),
        )
        .get();
    return entities.toList();
  }

  @override
  Future<List<CategoryEntity>> getAllCategoriesByCouple({
    String? coupleId,
  }) async {
    var query = _db.select(_db.categoryTable)
      ..where((tbl) => tbl.localDeletedAt.isNull());

    if (coupleId != null && coupleId.isNotEmpty) {
      query = query..where((tbl) => tbl.coupleId.equals(coupleId));
    }

    final rows = await query
        .map(
          (row) => CategoryEntity(
            id: row.id,
            coupleId: row.coupleId,
            name: row.name,
            createdAt: row.createdAt,
            categoryHost: row.categoryHost,
            syncStatus: row.syncStatus,
            localUpdatedAt: row.localUpdatedAt ?? DateTime.now().toUtc(),
            localDeletedAt: row.localDeletedAt,
            icon: row.icon,
            color: row.color,
            lastSyncedAt: row.lastSyncedAt,
            shortDescription: row.shortDescription,
          ),
        )
        .get();

    return rows.toList();
  }

  @override
  Future<List<CategoryEntity>> getByFilter(CategoryFilterDto filter) async {
    return getAllCategoriesByCouple();
  }

  @override
  Future<List<CategoryEntity>> getCategoriesByHost(
    CategoryHost host, {
    String? coupleId,
  }) async {
    var query = _db.select(_db.categoryTable)
      ..where(
        (tbl) =>
            tbl.categoryHost.equals(host.index) & tbl.localDeletedAt.isNull(),
      );

    if (coupleId != null && coupleId.isNotEmpty) {
      query = query..where((tbl) => tbl.coupleId.equals(coupleId));
    }

    final rows = await query
        .map(
          (row) => CategoryEntity(
            id: row.id,
            coupleId: row.coupleId,
            name: row.name,
            createdAt: row.createdAt,
            categoryHost: row.categoryHost,
            syncStatus: row.syncStatus,
            localUpdatedAt: row.localUpdatedAt ?? DateTime.now().toUtc(),
            localDeletedAt: row.localDeletedAt,
            icon: row.icon,
            color: row.color,
            lastSyncedAt: row.lastSyncedAt,
            shortDescription: row.shortDescription,
          ),
        )
        .get();

    return rows.toList();
  }

  @override
  Future<List<CategoryEntity>> getCategoriesNeedingSync() async {
    final rows =
        await (_db.select(_db.categoryTable)..where(
              (tbl) =>
                  tbl.syncStatus.isNotValue(SyncStatus.synced.index) &
                  tbl.localDeletedAt.isNull(),
            ))
            .map(
              (row) => CategoryEntity(
                id: row.id,
                coupleId: row.coupleId,
                name: row.name,
                createdAt: row.createdAt,
                categoryHost: row.categoryHost,
                syncStatus: row.syncStatus,
                localUpdatedAt: row.localUpdatedAt ?? DateTime.now().toUtc(),
                localDeletedAt: row.localDeletedAt,
                icon: row.icon,
                color: row.color,
                lastSyncedAt: row.lastSyncedAt,
                shortDescription: row.shortDescription,
              ),
            )
            .get();

    return rows.toList();
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
  Future<bool> updateCategories(List<CategoryEntity> dtos) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.categoryTable,
        dtos.map(categoryTableCompanionFromEntity).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
    return true;
  }

  @override
  Future<bool> updateCategory(CategoryEntity entity) async {
    await _db
        .into(_db.categoryTable)
        .insertOnConflictUpdate(categoryTableCompanionFromEntity(entity));
    return true;
  }

  @override
  Future<void> updateSyncStatus(
    String categoryId,
    SyncStatus status, {
    DateTime? lastSyncAt,
  }) async {
    await _db
        .update(_db.categoryTable)
        .replace(
          CategoryTableCompanion(
            id: Value(categoryId),
            syncStatus: Value(status),
            lastSyncedAt: Value(lastSyncAt ?? DateTime.now().toUtc()),
            localUpdatedAt: Value(lastSyncAt ?? DateTime.now().toUtc()),
          ),
        );
  }

  @override
  Future<bool> upsertFromCloud(CategoryEntity category) async {
    final now = DateTime.now().toUtc();
    await _db
        .into(_db.categoryTable)
        .insertOnConflictUpdate(
          categoryTableCompanionFromEntity(
            CategoryEntity(
              id: category.id,
              coupleId: category.coupleId,
              name: category.name,
              icon: category.icon,
              shortDescription: category.shortDescription,
              color: category.color,
              createdAt: category.createdAt,
              categoryHost: category.categoryHost,
              syncStatus: SyncStatus.synced,
              localUpdatedAt: category.localUpdatedAt,
              lastSyncedAt: now,
              localDeletedAt: category.localDeletedAt,
            ),
          ),
        );
    return true;
  }
}
