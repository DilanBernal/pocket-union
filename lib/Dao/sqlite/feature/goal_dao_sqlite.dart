import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/models/goal.dart';
import 'package:pocket_union/domain/port/local/goal_local_port.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/goal_filter_dto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class GoalDaoSqlite implements GoalLocalPort {
  final DbSqlite _dbHelper;
  final LoggerPort _logger;
  final Uuid _uuid = const Uuid();

  GoalDaoSqlite({required DbSqlite dbHelper, required LoggerPort logger})
    : _dbHelper = dbHelper,
      _logger = logger;

  @override
  Future<String> createGoal(Goal goal) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    final newGoal = Goal(
      id: id,
      createdAt: goal.createdAt,
      coupleId: goal.coupleId,
      name: goal.name,
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount,
      deadline: goal.deadline,
      description: goal.description,
      inCloud: false,
    );
    await db.insert(
      'goal',
      newGoal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  @override
  Future<Goal?> getGoalById(String id) async {
    final db = await _dbHelper.database;
    try {
      final maps = await db.query(
        'goal',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Goal.fromMap(maps.first);
    } catch (e) {
      _logger.error('GoalDaoSqlite: Error al buscar meta por id', error: e);
      return null;
    }
  }

  @override
  Future<List<Goal>> getAllGoals() async {
    final db = await _dbHelper.database;
    try {
      final maps = await db.query('goal');
      return maps.map((m) => Goal.fromMap(m)).toList();
    } catch (e) {
      _logger.error('GoalDaoSqlite: Error al obtener metas', error: e);
      throw Exception("Error al obtener metas: $e");
    }
  }

  @override
  Future<List<Goal>> getByFilter(GoalFilterDto filter) async {
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
    if (filter.name != null) {
      where.add('name LIKE ?');
      whereArgs.add('%${filter.name}%');
    }

    final maps = await db.query(
      'goal',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );
    return maps.map((m) => Goal.fromMap(m)).toList();
  }

  @override
  Future<bool> updateGoal(Goal goal) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.update(
        'goal',
        goal.toMap(),
        where: 'id = ?',
        whereArgs: [goal.id],
      );
      return count > 0;
    } catch (e) {
      _logger.error('GoalDaoSqlite: Error al actualizar meta', error: e);
      return false;
    }
  }

  @override
  Future<bool> deleteGoal(String id) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.delete('goal', where: 'id = ?', whereArgs: [id]);
      return count > 0;
    } catch (e) {
      _logger.error('GoalDaoSqlite: Error al eliminar meta', error: e);
      return false;
    }
  }
}
