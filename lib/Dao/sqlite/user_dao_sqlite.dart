import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/models/user.dart';
import 'package:pocket_union/domain/port/feat/user_port.dart';
import 'package:sqflite/sqflite.dart';

class UserDaoSqlite extends UserPort {
  final DbSqlite dbHelper;

  UserDaoSqlite({required this.dbHelper});

  @override
  Future upsertUser(User user) async {
    final db = await dbHelper.database;
    await db.insert(
      'profile',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User> getTheUser(int idUser) async {
    final db = await dbHelper.database;

    try {
      final Map<String, dynamic> map =
          (await db.query('user')) as Map<String, dynamic>;
      return User.fromMap(map);
    } catch (e) {
      throw Exception('Error al cargar el usuario');
    }
  }
}
