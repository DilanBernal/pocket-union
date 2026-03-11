import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/models/user.dart';
import 'package:pocket_union/domain/port/local/user_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/user_filter_dto.dart';
import 'package:sqflite/sqflite.dart';

class UserDaoSqlite extends UserLocalPort {
  final DbSqlite dbHelper;
  final LoggerPort _logger;

  UserDaoSqlite({required this.dbHelper, required LoggerPort logger})
    : _logger = logger;

  @override
  Future<bool> upsertUser(DomainUser user) async {
    try {
      final db = await dbHelper.database;
      var data = await db.insert(
        'profile',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (data.isNegative || data == 0) return false;
      return true;
    } catch (e) {
      _logger.error('UserDaoSqlite: Error al guardar usuario', error: e);
      return false;
    }
  }

  @override
  Future<DomainUser?> getUserById(String id) async {
    try {
      final db = await dbHelper.database;
      final result = await db.query(
        'profile',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (result.isEmpty) return null;
      return DomainUser.fromMap(result.first);
    } catch (e) {
      _logger.error('UserDaoSqlite: Error al buscar usuario por id', error: e);
      return null;
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
      _logger.error('UserDaoSqlite: Error al cargar el usuario', error: e);
      return null;
    }
  }

  @override
  Future<List<DomainUser>> getByFilter(UserFilterDto filter) async {
    final db = await dbHelper.database;
    final where = <String>[];
    final whereArgs = <dynamic>[];

    if (filter.id != null) {
      where.add('id = ?');
      whereArgs.add(filter.id);
    }
    if (filter.fullName != null) {
      where.add('full_name LIKE ?');
      whereArgs.add('%${filter.fullName}%');
    }

    final maps = await db.query(
      'profile',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );
    return maps.map((m) => DomainUser.fromMap(m)).toList();
  }

  @override
  Future<bool> deleteAllUsers() async {
    try {
      final db = await dbHelper.database;
      await db.delete('profile');
      return true;
    } catch (e) {
      _logger.error('UserDaoSqlite: Error al eliminar usuarios', error: e);
      return false;
    }
  }
}
