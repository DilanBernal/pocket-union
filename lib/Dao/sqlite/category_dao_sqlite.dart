import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/models/user.dart';
import 'package:pocket_union/domain/port/feat/category_port.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class CategoryDaoSqlite implements CategoryPort {
  final DbSqlite dbHelper;
  final _uuid = Uuid();

  CategoryDaoSqlite({required this.dbHelper});

  @override
  Future<String> createCategory(NewCategoryDto dto, String coupleId) async {
    final db = await dbHelper.database;
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    final category = Category(
      id: id,
      coupleId: coupleId,
      name: dto.name,
      icon: dto.icon,
      shortDescription: dto.shortDescription,
      color: dto.color,
      createdAt: DateTime.now(),
      categoryHost: dto.host,
      syncStatus: SyncStatus.pending,
    );
    final map = category.toMap();
    map['local_updated_at'] = now;
    map['is_deleted'] = 0;
    await db.insert('category', map,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  @override
  Future<List<Category>> getCategories() async {
    final db = await dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'category',
        where: 'is_deleted = ?',
        whereArgs: [0],
      );
      return List.generate(maps.length, (int i) {
        return Category.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception("Ocurrio un error $e");
    }
  }

  Future<List<DomainUser>> getAllUsers() async {
    final db = await dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
          'user',
          orderBy: 'name ASC'
      );
      return List.generate(maps.length, (int i) {
        return DomainUser.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception(e);
    }
  }
}
