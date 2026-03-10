import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/models/goal_contribution.dart';
import 'package:pocket_union/domain/port/local/goal_contribution_local_port.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/goal_contribution_filter_dto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class GoalContributionDaoSqlite implements GoalContributionLocalPort {
  final DbSqlite _dbHelper;
  final LoggerPort _logger;
  final Uuid _uuid = const Uuid();

  GoalContributionDaoSqlite({
    required DbSqlite dbHelper,
    required LoggerPort logger,
  }) : _dbHelper = dbHelper,
       _logger = logger;

  @override
  Future<String> createContribution(GoalContribution contribution) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    final newContribution = GoalContribution(
      id: id,
      goalId: contribution.goalId,
      userId: contribution.userId,
      amount: contribution.amount,
      contributionDate: contribution.contributionDate,
      createdAt: contribution.createdAt,
      inCloud: false,
    );
    await db.insert(
      'goal_contribution',
      newContribution.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  @override
  Future<GoalContribution?> getContributionById(String id) async {
    final db = await _dbHelper.database;
    try {
      final maps = await db.query(
        'goal_contribution',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return GoalContribution.fromMap(maps.first);
    } catch (e) {
      _logger.error(
        'GoalContributionDaoSqlite: Error al buscar contribución por id',
        error: e,
      );
      return null;
    }
  }

  @override
  Future<List<GoalContribution>> getAllContributions() async {
    final db = await _dbHelper.database;
    try {
      final maps = await db.query('goal_contribution');
      return maps.map((m) => GoalContribution.fromMap(m)).toList();
    } catch (e) {
      _logger.error(
        'GoalContributionDaoSqlite: Error al obtener contribuciones',
        error: e,
      );
      throw Exception("Error al obtener contribuciones: $e");
    }
  }

  @override
  Future<List<GoalContribution>> getByFilter(
    GoalContributionFilterDto filter,
  ) async {
    final db = await _dbHelper.database;
    final where = <String>[];
    final whereArgs = <dynamic>[];

    if (filter.id != null) {
      where.add('id = ?');
      whereArgs.add(filter.id);
    }
    if (filter.goalId != null) {
      where.add('goal_id = ?');
      whereArgs.add(filter.goalId);
    }
    if (filter.userId != null) {
      where.add('user_id = ?');
      whereArgs.add(filter.userId);
    }

    final maps = await db.query(
      'goal_contribution',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );
    return maps.map((m) => GoalContribution.fromMap(m)).toList();
  }

  @override
  Future<bool> updateContribution(GoalContribution contribution) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.update(
        'goal_contribution',
        contribution.toMap(),
        where: 'id = ?',
        whereArgs: [contribution.id],
      );
      return count > 0;
    } catch (e) {
      _logger.error(
        'GoalContributionDaoSqlite: Error al actualizar contribución',
        error: e,
      );
      return false;
    }
  }

  @override
  Future<bool> deleteContribution(String id) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.delete(
        'goal_contribution',
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      _logger.error(
        'GoalContributionDaoSqlite: Error al eliminar contribución',
        error: e,
      );
      return false;
    }
  }
}
