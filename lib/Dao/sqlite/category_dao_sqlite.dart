import 'package:flutter/rendering.dart';
import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/port/feat/category_port.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
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
    await db.insert('category', categoryEntity.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
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
  Future createDefaultCategories(String idCouple) async {
    try {
      final idHealthCategory = _uuid.v4();
      final idHomeCategory = _uuid.v4();
      final idPetCategory = _uuid.v4();

      final db = await _dbHelper.database;

      final healthCategory = Category(
          id: idHealthCategory,
          coupleId: idCouple,
          name: "Salud",
          createdAt: DateTime.now(),
          categoryHost: CategoryHost.expense,
          syncStatus: SyncStatus.pending);
      final homeCategory = Category(
          id: idHomeCategory,
          coupleId: idCouple,
          name: "Hogar",
          createdAt: DateTime.now(),
          categoryHost: CategoryHost.expense,
          syncStatus: SyncStatus.pending);
      final petCategory = Category(
          id: idPetCategory,
          coupleId: idCouple,
          name: "Mascotas",
          createdAt: DateTime.now(),
          categoryHost: CategoryHost.expense,
          syncStatus: SyncStatus.pending);

      await Future.wait([
        db.insert('category', healthCategory.toJson()),
        db.insert('category', petCategory.toJson()),
        db.insert('category', homeCategory.toJson())
      ]);
    } catch (e) {
      debugPrint(e.toString());
    }
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
}
