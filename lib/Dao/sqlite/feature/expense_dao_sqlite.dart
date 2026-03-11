import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/models/expense.dart';
import 'package:pocket_union/domain/port/local/expense_local_port.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/expense_filter_dto.dart';
import 'package:pocket_union/dto/new_expense_dto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class ExpenseDaoSqlite implements ExpenseLocalPort {
  final DbSqlite _dbHelper;
  final LoggerPort _logger;
  final Uuid _uuid = const Uuid();

  ExpenseDaoSqlite({required DbSqlite dbHelper, required LoggerPort logger})
    : _dbHelper = dbHelper,
      _logger = logger;

  @override
  Future<String> createExpense(NewExpenseDto dto) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    final now = DateTime.now();
    final expense = Expense(
      id: id,
      coupleId: '',
      createdBy: '',
      name: dto.name,
      transactionDate: now,
      description: dto.description,
      amount: dto.amount,
      categoryId: dto.categoryId,
      isFixed: dto.isFixed,
      importanceLevel: dto.importanceLevel,
      isPlaned: dto.isPlaned,
      createdAt: now,
      inCloud: false,
    );
    await db.insert(
      'expense',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    final db = await _dbHelper.database;
    try {
      final maps = await db.query(
        'expense',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Expense.fromMap(maps.first);
    } catch (e) {
      _logger.error('ExpenseDaoSqlite: Error al buscar gasto por id', error: e);
      return null;
    }
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    final db = await _dbHelper.database;
    try {
      final maps = await db.query('expense', orderBy: 'transaction_date DESC');
      return maps.map((m) => Expense.fromMap(m)).toList();
    } catch (e) {
      _logger.error('ExpenseDaoSqlite: Error al obtener gastos', error: e);
      throw Exception("Error al obtener gastos: $e");
    }
  }

  @override
  Future<List<Expense>> getByFilter(ExpenseFilterDto filter) async {
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
    if (filter.categoryId != null) {
      where.add('category_id = ?');
      whereArgs.add(filter.categoryId);
    }
    if (filter.isFixed != null) {
      where.add('is_fixed = ?');
      whereArgs.add(filter.isFixed! ? 1 : 0);
    }
    if (filter.dateFrom != null) {
      where.add('transaction_date >= ?');
      whereArgs.add(filter.dateFrom!.toIso8601String());
    }
    if (filter.dateTo != null) {
      where.add('transaction_date <= ?');
      whereArgs.add(filter.dateTo!.toIso8601String());
    }

    final maps = await db.query(
      'expense',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'transaction_date DESC',
    );
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  @override
  Future<bool> updateExpense(Expense expense) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.update(
        'expense',
        expense.toMap(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
      return count > 0;
    } catch (e) {
      _logger.error('ExpenseDaoSqlite: Error al actualizar gasto', error: e);
      return false;
    }
  }

  @override
  Future<bool> deleteExpense(String id) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.delete(
        'expense',
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      _logger.error('ExpenseDaoSqlite: Error al eliminar gasto', error: e);
      return false;
    }
  }

  @override
  Future<bool> deleteAllExpenses() async {
    final db = await _dbHelper.database;
    try {
      await db.delete('expense');
      return true;
    } catch (e) {
      _logger.error(
        'ExpenseDaoSqlite: Error al eliminar todos los gastos',
        error: e,
      );
      return false;
    }
  }
}
