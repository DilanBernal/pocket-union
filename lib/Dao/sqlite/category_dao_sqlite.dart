import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/domain/port/feat/category_port.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class CategoryDaoSqlite implements CategoryPort {
  final DbSqlite dbHelper;
  final _uuid = Uuid();

  CategoryDaoSqlite({required this.dbHelper});

  @override
  Future<List<Category>> getAllCategories() async {
    final db = await dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('category');
      return List.generate(maps.length, (int i) {
        return Category.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  @override
  Future<String> createCategory(NewCategoryDto dto) async {
    final db = await dbHelper.database;
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    await db.insert(
      'category',
      {
        'id': id,
        'name': dto.name,
        'couple_id': dto.coupleId,
        'icon': dto.icon,
        'short_description': dto.shortDescription,
        'color': dto.color,
        'created_at': now,
        'category_host': dto.host.value,
        'sync_status': 'pending',
        'local_updated_at': now,
        'is_deleted': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }
}
