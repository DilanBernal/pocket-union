import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/models/recurrent_expense.dart';
import 'package:pocket_union/domain/port/local/recurrent_expense_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/new_recurrent_expense_dto.dart';
import 'package:uuid/uuid.dart';

class RecurrentExpenseDaoSqlite implements RecurrentExpenseLocalPort {
  final DbSqlite _dbHelper;
  final LoggerPort _logger;
  final Uuid _uuid = const Uuid();

  RecurrentExpenseDaoSqlite({
    required DbSqlite dbHelper,
    required LoggerPort logger,
  }) : _dbHelper = dbHelper,
       _logger = logger;

  @override
  Future<String> createRecurrentExpense(NewRecurrentExpenseDto dto) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    final now = DateTime.now();

    await db.insert('recurrent_expense', {
      'id': id,
      'created_at': now.toIso8601String(),
      'name': dto.name,
      'created_by': dto.createdBy,
      'couple_id': dto.coupleId,
      'amount': (dto.amount * 100).round(),
      'recurrent_info': dto.recurrentInfo,
      'sync_status': 'pending',
    });

    return id;
  }

  @override
  Future<RecurrentExpense?> getRecurrentExpenseById(String id) async {
    final db = await _dbHelper.database;
    try {
      final maps = await db.query(
        'recurrent_expense',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return RecurrentExpense.fromMap(maps.first);
    } catch (e) {
      _logger.error(
        'RecurrentExpenseDaoSqlite: Error al buscar gasto recurrente',
        error: e,
      );
      return null;
    }
  }

  @override
  Future<List<RecurrentExpense>> getAllRecurrentExpenses() async {
    final db = await _dbHelper.database;
    try {
      final maps = await db.query(
        'recurrent_expense',
        orderBy: 'created_at DESC',
      );
      return maps.map((m) => RecurrentExpense.fromMap(m)).toList();
    } catch (e) {
      _logger.error(
        'RecurrentExpenseDaoSqlite: Error al obtener gastos recurrentes',
        error: e,
      );
      throw Exception('Error al obtener gastos recurrentes: $e');
    }
  }

  @override
  Future<bool> updateRecurrentExpense(RecurrentExpense recurrentExpense) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.update(
        'recurrent_expense',
        recurrentExpense.toMap(),
        where: 'id = ?',
        whereArgs: [recurrentExpense.id],
      );
      return count > 0;
    } catch (e) {
      _logger.error(
        'RecurrentExpenseDaoSqlite: Error al actualizar gasto recurrente',
        error: e,
      );
      return false;
    }
  }

  @override
  Future<bool> deleteRecurrentExpense(String id) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.delete(
        'recurrent_expense',
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      _logger.error(
        'RecurrentExpenseDaoSqlite: Error al eliminar gasto recurrente',
        error: e,
      );
      return false;
    }
  }
}
