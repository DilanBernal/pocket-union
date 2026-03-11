import 'package:flutter/material.dart';
import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/port/local/category_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/category_filter_dto.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
import 'package:pocket_union/dto/update_category_dto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/models/category.dart';

class CategoryDaoSqlite extends CategoryLocalPort {
  final DbSqlite _dbHelper;
  final LoggerPort _logger;
  final Uuid _uuid = Uuid();

  CategoryDaoSqlite({required DbSqlite dbHelper, required LoggerPort logger})
    : _dbHelper = dbHelper,
      _logger = logger;

  @override
  Future<String> createCategory(NewCategoryDto category) async {
    final db = await _dbHelper.database;
    var id = _uuid.v4();
    var categoryEntity = NewCategoryDto.toCategoryDomain(category, id);
    await db.insert(
      'category',
      categoryEntity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  @override
  Future<List<Category>> getAllCategories() async {
    final db = await _dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('category');
      return List.generate(maps.length, (int i) {
        return Category.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception("Ocurrio un error $e");
    }
  }

  @override
  Future<List<Category>> getAllCategoriesByCouple({String? coupleId}) async {
    final db = await _dbHelper.database;
    try {
      if (coupleId == null) {
        final coupleResult = await db.query(
          'couple',
          columns: ['couple_id'],
          limit: 1,
        );
        if (coupleResult.firstOrNull == null) {
          throw ArgumentError(
            "No se pueden traer las categorias sin una couple",
          );
        }
        coupleId = coupleResult.first as String;
      }
      final List<Map<String, dynamic>> maps = await db.query(
        'category',
        where: 'couple_id = ? AND is_deleted = 0',
        whereArgs: [coupleId],
      );
      return List.generate(maps.length, (int i) {
        return Category.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception("Ocurrio un error $e");
    }
  }

  @override
  Future<List<Category>> createDefaultCategories(String idCouple) async {
    final now = DateTime.now();

    final defaultCategories = [
      Category(
        id: _uuid.v4(),
        coupleId: idCouple,
        name: 'Salud',
        icon: Icons.health_and_safety.codePoint.toString(),
        color: '#FFF44336',
        createdAt: now,
        categoryHost: CategoryHost.expense,
        syncStatus: SyncStatus.pending,
      ),
      Category(
        id: _uuid.v4(),
        coupleId: idCouple,
        name: 'Hogar',
        icon: Icons.home.codePoint.toString(),
        color: '#FF2196F3',
        createdAt: now,
        categoryHost: CategoryHost.expense,
        syncStatus: SyncStatus.pending,
      ),
      Category(
        id: _uuid.v4(),
        coupleId: idCouple,
        name: 'Mascotas',
        icon: Icons.pets.codePoint.toString(),
        color: '#FF4CAF50',
        createdAt: now,
        categoryHost: CategoryHost.expense,
        syncStatus: SyncStatus.pending,
      ),

      Category(
        id: _uuid.v4(),
        coupleId: idCouple,
        name: 'Trabajo',
        icon: Icons.business_center.codePoint.toString(),
        color: '#FF4CAF50',
        createdAt: now,
        categoryHost: CategoryHost.income,
        syncStatus: SyncStatus.pending,
      ),
    ];

    final db = await _dbHelper.database;

    await Future.wait(
      defaultCategories.map(
        (cat) => db.insert(
          'category',
          cat.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        ),
      ),
    );

    return defaultCategories;
  }

  @override
  Future deleteAllCategories() {
    // TODO: implement deleteAllCategories
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteCategory(String idCategory) {
    // TODO: implement deleteCategory
    throw UnimplementedError();
  }

  @override
  Future<bool> createCategories(List<NewCategoryDto> categories) {
    // TODO: implement createCategories
    throw UnimplementedError();
  }

  @override
  Future<List<Category>> getCategoriesByHost(
    CategoryHost host, {
    String? coupleId,
  }) async {
    final db = await _dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'category',
        where: 'category_host = ? AND is_deleted = 0',
        whereArgs: [host.value],
      );
      return List.generate(maps.length, (int i) {
        return Category.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception("Error al obtener categorías por host: $e");
    }
  }

  @override
  Future<bool> updateCategory(UpdateCategoryDto dto) async {
    final db = await _dbHelper.database;
    try {
      final updateData = dto.toUpdateMap();
      updateData['local_updated_at'] = DateTime.now().toIso8601String();
      updateData['sync_status'] = SyncStatus.pending.value.toLowerCase();

      final count = await db.update(
        'category',
        updateData,
        where: 'id = ?',
        whereArgs: [dto.id],
      );
      return count > 0;
    } catch (e) {
      _logger.error(
        'CategoryDaoSqlite: Error actualizando categoría',
        error: e,
      );
      return false;
    }
  }

  @override
  Future<bool> updateCategories(List<UpdateCategoryDto> dtos) async {
    final db = await _dbHelper.database;
    try {
      await db.transaction((txn) async {
        for (final dto in dtos) {
          final updateData = dto.toUpdateMap();
          updateData['local_updated_at'] = DateTime.now().toIso8601String();
          updateData['sync_status'] ??= SyncStatus.pending.value.toLowerCase();

          await txn.update(
            'category',
            updateData,
            where: 'id = ?',
            whereArgs: [dto.id],
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      return true;
    } catch (e) {
      _logger.error(
        'CategoryDaoSqlite: Error actualizando categorías',
        error: e,
      );
      return false;
    }
  }

  @override
  Future<List<Category>> getByFilter(CategoryFilterDto filter) async {
    final db = await _dbHelper.database;
    final where = <String>[];
    final whereArgs = <dynamic>[];

    if (filter.id != null) {
      where.add('id = ?');
      whereArgs.add(filter.id);
    }
    if (filter.coupleId != null) {
      where.add('couple_id = ?');
      whereArgs.add(filter.coupleId);
    }
    if (filter.host != null) {
      where.add('category_host = ?');
      whereArgs.add(filter.host!.value);
    }
    if (filter.syncStatus != null) {
      where.add('sync_status = ?');
      whereArgs.add(filter.syncStatus!.value.toLowerCase());
    }

    final maps = await db.query(
      'category',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('category', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  @override
  Future<List<Category>> getCategoriesNeedingSync() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'category',
      where:
          "is_deleted = 0 AND (sync_status = 'pending' OR (last_sync_at IS NOT NULL AND local_updated_at > last_sync_at))",
    );
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  @override
  Future<void> updateSyncStatus(
    String categoryId,
    SyncStatus status, {
    DateTime? lastSyncAt,
  }) async {
    final db = await _dbHelper.database;
    final data = <String, dynamic>{'sync_status': status.value.toLowerCase()};
    if (lastSyncAt != null) {
      data['last_sync_at'] = lastSyncAt.toIso8601String();
    }
    await db.update('category', data, where: 'id = ?', whereArgs: [categoryId]);
  }
}
