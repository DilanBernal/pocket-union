import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/models/user.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/models/category.dart';

class CategoryDaoSqlite {
  final DbSqlite dbHelper;

  CategoryDaoSqlite({required this.dbHelper});

  Future<int> insertCategory(Category category) async {
    final db = await dbHelper.database;
    int id = await db.insert('category', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future<List<Category>> getAllCategories() async {
    final db = await dbHelper.database;
    try{
      final List<Map<String, dynamic>> maps = await db.query(
        'category'
      );
      return List.generate(maps.length, (int i) {
        return Category.fromMap(maps[i]);
      });
    }
    catch (e){
      throw Exception("Ocurrio un error $e");
    }
  }


  Future<List<User>> getAllUsers() async{
    final db = await dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
          'user',
          orderBy: 'name ASC'
      );
      return List.generate(maps.length, (int i) {
        return User.fromMap(maps[i]);
      });
    }catch(e) {
      throw Exception(e);
    }
  }
}
