import 'package:drift/drift.dart';
import 'package:pocket_union/Dao/drift/app_database.dart' as drift;
import 'package:pocket_union/Dao/drift/mappers/category_mapper.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/port/local/category_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/category_filter_dto.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
import 'package:pocket_union/dto/update_category_dto.dart';
import 'package:uuid/uuid.dart';

class CategoryDaoDrift extends CategoryLocalPort {
  final drift.AppDatabase _db;
  final LoggerPort _logger;
  final CategoryMapper _mapper;
  final Uuid _uuid;

  CategoryDaoDrift({
    required drift.AppDatabase appDatabase,
    required LoggerPort logger,
    CategoryMapper? mapper,
  })  : _db = appDatabase,
        _logger = logger,
        _mapper = mapper ?? CategoryMapper(),
        _uuid = const Uuid();

  @override
  Future<String> createCategory(NewCategoryDto dto) async {
    final id = _uuid.v4();
    final category = NewCategoryDto.toCategoryDomain(dto, id);
    await _db.into(_db.categories).insert(_mapper.toCompanion(category));
    return id;
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    try {
      final result = await (_db.select(_db.categories)
            ..where((tbl) => tbl.id.equals(id))
            ..limit(1))
          .getSingleOrNull();
      return result != null ? _mapper.toDomain(result) : null;
    } catch (e, st) {
      _logger.error('CategoryDaoDrift: getCategoryById falló',
          error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<bool> deleteCategory(String idCategory) async {
    try {
      await (_db.delete(_db.categories)
            ..where((tbl) => tbl.id.equals(idCategory)))
          .go();
      return true;
    } catch (e, st) {
      _logger.error('CategoryDaoDrift: deleteCategory falló',
          error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future deleteAllCategories() async {
    await _db.delete(_db.categories).go();
  }

  @override
  Future<bool> createCategories(List<NewCategoryDto> categories) async {
    try {
      for (final dto in categories) {
        await createCategory(dto);
      }
      return true;
    } catch (e, st) {
      _logger.error('CategoryDaoDrift: createCategories falló',
          error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<List<Category>> createDefaultCategories(String idCouple) async {
    final now = DateTime.now();
    final defaults = [
      Category(
        id: _uuid.v4(),
        coupleId: idCouple,
        name: 'Salud',
        icon: '59536',
        color: '#FFF44336',
        createdAt: now,
        categoryHost: CategoryHost.expense,
        syncStatus: SyncStatus.pending,
      ),
      Category(
        id: _uuid.v4(),
        coupleId: idCouple,
        name: 'Hogar',
        icon: '59400',
        color: '#FF2196F3',
        createdAt: now,
        categoryHost: CategoryHost.expense,
        syncStatus: SyncStatus.pending,
      ),
      Category(
        id: _uuid.v4(),
        coupleId: idCouple,
        name: 'Mascotas',
        icon: '59564',
        color: '#FF4CAF50',
        createdAt: now,
        categoryHost: CategoryHost.expense,
        syncStatus: SyncStatus.pending,
      ),
      Category(
        id: _uuid.v4(),
        coupleId: idCouple,
        name: 'Trabajo',
        icon: '59540',
        color: '#FF4CAF50',
        createdAt: now,
        categoryHost: CategoryHost.income,
        syncStatus: SyncStatus.pending,
      ),
    ];
    for (final cat in defaults) {
      await _db.into(_db.categories).insert(_mapper.toCompanion(cat));
    }
    return defaults;
  }

  @override
  Future<List<Category>> getAllCategories() async {
    try {
      final rows = await _db.select(_db.categories).get();
      return rows.map(_mapper.toDomain).toList();
    } catch (e, st) {
      _logger.error('CategoryDaoDrift: getAllCategories falló',
          error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<List<Category>> getAllCategoriesByCouple({String? coupleId}) async {
    try {
      final query = _db.select(_db.categories);
      if (coupleId != null) {
        query.where((tbl) => tbl.coupleId.equals(coupleId));
      }
      query.where((tbl) => tbl.isDeleted.equals(false));
      final rows = await query.get();
      return rows.map(_mapper.toDomain).toList();
    } catch (e, st) {
      _logger.error('CategoryDaoDrift: getAllCategoriesByCouple falló',
          error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<List<Category>> getCategoriesByHost(
    CategoryHost host, {
    String? coupleId,
  }) async {
    try {
      final query = _db.select(_db.categories)
        ..where((tbl) => tbl.categoryHost.equals(host.value));
      if (coupleId != null) {
        query.where((tbl) => tbl.coupleId.equals(coupleId));
      }
      query.where((tbl) => tbl.isDeleted.equals(false));
      final rows = await query.get();
      return rows.map(_mapper.toDomain).toList();
    } catch (e, st) {
      _logger.error('CategoryDaoDrift: getCategoriesByHost falló',
          error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<List<Category>> getByFilter(CategoryFilterDto filter) async {
    try {
      final query = _db.select(_db.categories);
      query.where((tbl) {
        final predicates = <Expression<bool>>[];
        if (filter.id != null) predicates.add(tbl.id.equals(filter.id!));
        if (filter.coupleId != null) {
          predicates.add(tbl.coupleId.equals(filter.coupleId!));
        }
        if (filter.host != null) {
          predicates.add(tbl.categoryHost.equals(filter.host!.value));
        }
        if (filter.syncStatus != null) {
          predicates.add(
              tbl.syncStatus.equals(filter.syncStatus!.value.toLowerCase()));
        }
        if (predicates.isEmpty) return const Constant(true);
        return predicates.reduce((a, b) => a & b);
      });
      final rows = await query.get();
      return rows.map(_mapper.toDomain).toList();
    } catch (e, st) {
      _logger.error('CategoryDaoDrift: getByFilter falló',
          error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<bool> updateCategory(UpdateCategoryDto dto) async {
    try {
      await (_db.update(_db.categories)
            ..where((tbl) => tbl.id.equals(dto.id)))
          .write(const drift.CategoriesCompanion(
        syncStatus: Value('pending'),
      ));
      return true;
    } catch (e, st) {
      _logger.error('CategoryDaoDrift: updateCategory falló',
          error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<bool> updateCategories(List<UpdateCategoryDto> dtos) async {
    try {
      for (final dto in dtos) {
        await updateCategory(dto);
      }
      return true;
    } catch (e, st) {
      _logger.error('CategoryDaoDrift: updateCategories falló',
          error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<List<Category>> getCategoriesNeedingSync() async {
    try {
      final rows = await (_db.select(_db.categories)
            ..where((tbl) =>
                tbl.syncStatus.equals('pending') |
                tbl.syncStatus.equals('conflict')))
          .get();
      return rows.map(_mapper.toDomain).toList();
    } catch (e, st) {
      _logger.error('CategoryDaoDrift: getCategoriesNeedingSync falló',
          error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<void> updateSyncStatus(
    String categoryId,
    SyncStatus status, {
    DateTime? lastSyncAt,
  }) async {
    await (_db.update(_db.categories)
          ..where((tbl) => tbl.id.equals(categoryId)))
        .write(drift.CategoriesCompanion(
      syncStatus: Value(status.value.toLowerCase()),
    ));
  }

  @override
  Future<bool> upsertFromCloud(Category category) async {
    try {
      final companion = _mapper.toCompanion(category);
      await _db.into(_db.categories).insertOnConflictUpdate(companion);
      return true;
    } catch (e, st) {
      _logger.error('CategoryDaoDrift: upsertFromCloud falló',
          error: e, stackTrace: st);
      return false;
    }
  }
}
