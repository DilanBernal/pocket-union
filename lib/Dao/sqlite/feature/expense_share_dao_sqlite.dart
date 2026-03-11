import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/models/expense_share.dart';
import 'package:pocket_union/domain/port/local/expense_share_local_port.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/expense_share_filter_dto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class ExpenseShareDaoSqlite implements ExpenseShareLocalPort {
  final DbSqlite _dbHelper;
  final LoggerPort _logger;
  final Uuid _uuid = const Uuid();

  ExpenseShareDaoSqlite({
    required DbSqlite dbHelper,
    required LoggerPort logger,
  }) : _dbHelper = dbHelper,
       _logger = logger;

  @override
  Future<String> createExpenseShare(ExpenseShare share) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    final newShare = ExpenseShare(
      id: id,
      createdAt: share.createdAt,
      expenseId: share.expenseId,
      userId: share.userId,
      sharePercentage: share.sharePercentage,
      inCloud: false,
    );
    await db.insert(
      'expense_share',
      newShare.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  @override
  Future<ExpenseShare?> getExpenseShareById(String id) async {
    final db = await _dbHelper.database;
    try {
      final maps = await db.query(
        'expense_share',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return ExpenseShare.fromMap(maps.first);
    } catch (e) {
      _logger.error('ExpenseShareDaoSqlite: Error al buscar por id', error: e);
      return null;
    }
  }

  @override
  Future<List<ExpenseShare>> getAllExpenseShares() async {
    final db = await _dbHelper.database;
    try {
      final maps = await db.query('expense_share');
      return maps.map((m) => ExpenseShare.fromMap(m)).toList();
    } catch (e) {
      _logger.error('ExpenseShareDaoSqlite: Error al obtener shares', error: e);
      throw Exception("Error al obtener expense shares: $e");
    }
  }

  @override
  Future<List<ExpenseShare>> getByFilter(ExpenseShareFilterDto filter) async {
    final db = await _dbHelper.database;
    final where = <String>[];
    final whereArgs = <dynamic>[];

    if (filter.id != null) {
      where.add('id = ?');
      whereArgs.add(filter.id);
    }
    if (filter.expenseId != null) {
      where.add('expense_id = ?');
      whereArgs.add(filter.expenseId);
    }
    if (filter.userId != null) {
      where.add('user_id = ?');
      whereArgs.add(filter.userId);
    }

    final maps = await db.query(
      'expense_share',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );
    return maps.map((m) => ExpenseShare.fromMap(m)).toList();
  }

  @override
  Future<bool> updateExpenseShare(ExpenseShare share) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.update(
        'expense_share',
        share.toMap(),
        where: 'id = ?',
        whereArgs: [share.id],
      );
      return count > 0;
    } catch (e) {
      _logger.error(
        'ExpenseShareDaoSqlite: Error al actualizar share',
        error: e,
      );
      return false;
    }
  }

  @override
  Future<bool> deleteExpenseShare(String id) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.delete(
        'expense_share',
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      _logger.error('ExpenseShareDaoSqlite: Error al eliminar share', error: e);
      return false;
    }
  }
}
