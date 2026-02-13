import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/models/user.dart';
import 'package:pocket_union/domain/port/feat/user_port.dart';
import 'package:sqflite/sqflite.dart';

class UserDaoSqlite extends UserPort {
  final DbSqlite dbHelper;

  UserDaoSqlite({required this.dbHelper});

  @override
  Future<bool> upsertUser(DomainUser user) async {
    try {
      final db = await dbHelper.database;
      var data = await db.insert(
        'profile',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<DomainUser?> getCurrentUser() async {
    try {
      final db = await dbHelper.database;
      final result = await db.query('profile', limit: 1);
      
      if (result.isEmpty) {
        return null;
      }
      
      return DomainUser.fromMap(result.first);
    } catch (e) {
      print('Error al cargar el usuario: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteAllUsers() async {
    try {
      final db = await dbHelper.database;
      await db.delete('profile');
      return true;
    } catch (e) {
      print('Error al eliminar usuarios: $e');
      return false;
    }
  }
}
