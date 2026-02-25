import 'package:flutter/material.dart';
import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/port/feat/category_port.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
import 'package:pocket_union/dto/update_category_dto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/category.dart';

class CategoryDaoSqlite extends CategoryPort {
  final DbSqlite _dbHelper;
  final Uuid _uuid = Uuid();

  CategoryDaoSqlite({required DbSqlite dbHelper}) : _dbHelper = dbHelper;

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
    ];

    final db = await _dbHelper.database;

    var resultCouple = await db.query('couple');

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
  Future<List<Category>> getCategoriesByHost(CategoryHost host) async {
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
      debugPrint('CategoryDaoSqlite: Error actualizando categoría: $e');
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
          updateData['sync_status'] = SyncStatus.pending.value.toLowerCase();

          await txn.update(
            'category',
            updateData,
            where: 'id = ?',
            whereArgs: [dto.id],
          );
        }
      });
      return true;
    } catch (e) {
      debugPrint('CategoryDaoSqlite: Error actualizando categorías: $e');
      return false;
    }
  }

  /// Obtiene una categoría por ID.
  Future<Category?> getCategoryById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('category', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  /// Obtiene categorías que necesitan sincronización:
  /// - sync_status = 'pending' (nunca sincronizadas — necesitan INSERT)
  /// - last_sync_at IS NOT NULL AND local_updated_at > last_sync_at (ya sincronizadas con cambios locales — necesitan UPDATE)
  Future<List<Category>> getCategoriesNeedingSync() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'category',
      where:
          "is_deleted = 0 AND (sync_status = 'pending' OR (last_sync_at IS NOT NULL AND local_updated_at > last_sync_at))",
    );
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  /// Actualiza el estado de sincronización de una categoría.
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

  @override
  Future<bool> syncCategory(String categoryId) {
    // Sync solo se implementa en el Service
    throw UnimplementedError(
      'syncCategory solo se implementa en CategoryService',
    );
  }

  @override
  Future<Map<String, bool>> syncAllCategories() {
    // Sync solo se implementa en el Service
    throw UnimplementedError(
      'syncAllCategories solo se implementa en CategoryService',
    );
  }
}
