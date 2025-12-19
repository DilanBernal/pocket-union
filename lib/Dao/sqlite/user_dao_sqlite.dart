import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/models/user.dart';
import 'package:sqflite/sqflite.dart';

class UserDaoSqlite {
  final DbSqlite dbHelper;

  UserDaoSqlite ({required this.dbHelper});

  Future<int> insertUser(User user) async {
    final db = await dbHelper.database;
    int id =  await db.insert(
        'user',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
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

  Future<User> getTheUser(int idUser) async {
    final db = await dbHelper.database;

    try {
      final Map<String, dynamic> map = (await db.query(
        'user'
      )) as Map<String, dynamic>;
      return User.fromMap(map);
    } catch(e) {
      throw Exception('Error al cargar el usuario');
    }
  }
}