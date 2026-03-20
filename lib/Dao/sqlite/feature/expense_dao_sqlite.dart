import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/enum/sync_status.dart';
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
    final transactionDate = (dto.transactionDate ?? now).toIso8601String();

    await db.transaction((txn) async {
      // 1. Insertar en expense
      await txn.insert('expense', {
        'id': id,
        'couple_id': dto.coupleId ?? '',
        'created_by': dto.createdBy ?? '',
        'name': dto.name,
        'transaction_date': transactionDate,
        'description': dto.description,
        'amount': (dto.amount * 100).round(),
        'created_at': now.toIso8601String(),
        'sync_status': 'pending',
        'local_updated_at': now.toIso8601String(),
        'is_deleted': 0,
      });

      // 2. Insertar en expense_info
      await txn.insert('expense_info', {
        'id': id,
        'is_fixed': dto.isFixed ? 1 : 0,
        'is_planed': dto.isPlaned ? 1 : 0,
        'importance_level': dto.importanceLevel,
      });

      // 3. Insertar en expense_category (N:N)
      for (final categoryId in dto.categoryIds) {
        await txn.insert('expense_category', {
          'expense_id': id,
          'category_id': categoryId,
        });
      }
    });

    return id;
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    final db = await _dbHelper.database;
    try {
      final maps = await db.rawQuery(
        '''
        SELECT e.*, ei.is_fixed, ei.is_planed, ei.importance_level
        FROM expense e
        LEFT JOIN expense_info ei ON e.id = ei.id
        WHERE e.id = ? AND e.is_deleted = 0
        LIMIT 1
      ''',
        [id],
      );

      if (maps.isEmpty) return null;

      final categoryMaps = await db.query(
        'expense_category',
        where: 'expense_id = ?',
        whereArgs: [id],
      );
      final categoryIds = categoryMaps
          .map((m) => m['category_id'] as String)
          .toList();

      return Expense.fromMap(maps.first, categoryIds: categoryIds);
    } catch (e) {
      _logger.error('ExpenseDaoSqlite: Error al buscar gasto por id', error: e);
      return null;
    }
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    final db = await _dbHelper.database;
    try {
      final maps = await db.rawQuery('''
        SELECT e.*, ei.is_fixed, ei.is_planed, ei.importance_level
        FROM expense e
        LEFT JOIN expense_info ei ON e.id = ei.id
        WHERE e.is_deleted = 0
        ORDER BY e.transaction_date DESC
      ''');

      if (maps.isEmpty) return [];

      final expenseIds = maps.map((m) => m['id'] as String).toList();
      final categoryMap = await _loadCategoryIds(db, expenseIds);

      return maps.map((m) {
        final id = m['id'] as String;
        return Expense.fromMap(m, categoryIds: categoryMap[id] ?? []);
      }).toList();
    } catch (e) {
      _logger.error('ExpenseDaoSqlite: Error al obtener gastos', error: e);
      throw Exception("Error al obtener gastos: $e");
    }
  }

  @override
  Future<bool> upsertFromCloud(Expense expense) async {
    final db = await _dbHelper.database;
    try {
      await db.transaction((txn) async {
        final expenseMap = expense.toMap();
        expenseMap['sync_status'] = SyncStatus.synced.value;
        expenseMap['last_sync_at'] = DateTime.now().toIso8601String();
        expenseMap['is_deleted'] = 0;

        await txn.insert(
          'expense',
          expenseMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await txn.insert(
          'expense_info',
          expense.toExpenseInfoMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await txn.delete(
          'expense_category',
          where: 'expense_id = ?',
          whereArgs: [expense.id],
        );
      });

      return true;
    } catch (e) {
      _logger.error(
        'ExpenseDaoSqlite: Error al guardar gasto desde Supabase',
        error: e,
      );
      return false;
    }
  }

  @override
  Future<List<Expense>> getByFilter(ExpenseFilterDto filter) async {
    final db = await _dbHelper.database;
    final where = <String>['e.is_deleted = 0'];
    final whereArgs = <dynamic>[];

    if (filter.id != null) {
      where.add('e.id = ?');
      whereArgs.add(filter.id);
    }
    if (filter.coupleId != null) {
      where.add('e.couple_id = ?');
      whereArgs.add(filter.coupleId);
    }
    if (filter.categoryId != null) {
      where.add(
        'EXISTS (SELECT 1 FROM expense_category ec WHERE ec.expense_id = e.id AND ec.category_id = ?)',
      );
      whereArgs.add(filter.categoryId);
    }
    if (filter.isFixed != null) {
      where.add('ei.is_fixed = ?');
      whereArgs.add(filter.isFixed! ? 1 : 0);
    }
    if (filter.dateFrom != null) {
      where.add('e.transaction_date >= ?');
      whereArgs.add(filter.dateFrom!.toIso8601String());
    }
    if (filter.dateTo != null) {
      where.add('e.transaction_date <= ?');
      whereArgs.add(filter.dateTo!.toIso8601String());
    }

    final maps = await db.rawQuery('''
      SELECT e.*, ei.is_fixed, ei.is_planed, ei.importance_level
      FROM expense e
      LEFT JOIN expense_info ei ON e.id = ei.id
      WHERE ${where.join(' AND ')}
      ORDER BY e.transaction_date DESC
    ''', whereArgs.isNotEmpty ? whereArgs : null);

    if (maps.isEmpty) return [];

    final expenseIds = maps.map((m) => m['id'] as String).toList();
    final categoryMap = await _loadCategoryIds(db, expenseIds);

    return maps.map((m) {
      final id = m['id'] as String;
      return Expense.fromMap(m, categoryIds: categoryMap[id] ?? []);
    }).toList();
  }

  @override
  Future<bool> updateExpense(Expense expense) async {
    final db = await _dbHelper.database;
    try {
      var updated = false;

      await db.transaction((txn) async {
        final updatedRows = await txn.update(
          'expense',
          expense.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
          where: 'id = ?',
          whereArgs: [expense.id],
        );

        if (updatedRows == 0) {
          return;
        }

        // Upsert expense_info
        await txn.insert(
          'expense_info',
          expense.toExpenseInfoMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Reemplazar categorías
        await txn.delete(
          'expense_category',
          where: 'expense_id = ?',
          whereArgs: [expense.id],
        );
        for (final categoryId in expense.categoryIds) {
          await txn.insert('expense_category', {
            'expense_id': expense.id,
            'category_id': categoryId,
          });
        }

        updated = true;
      });

      return updated;
    } catch (e) {
      _logger.error('ExpenseDaoSqlite: Error al actualizar gasto', error: e);
      return false;
    }
  }

  @override
  Future<bool> deleteExpense(String id) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.update(
        'expense',
        {'is_deleted': 1},
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

  /// Carga category_ids en batch para una lista de expense IDs.
  Future<Map<String, List<String>>> _loadCategoryIds(
    Database db,
    List<String> expenseIds,
  ) async {
    if (expenseIds.isEmpty) return {};

    final placeholders = List.filled(expenseIds.length, '?').join(',');
    final rows = await db.rawQuery(
      'SELECT expense_id, category_id FROM expense_category WHERE expense_id IN ($placeholders)',
      expenseIds,
    );

    final result = <String, List<String>>{};
    for (final row in rows) {
      final expenseId = row['expense_id'] as String;
      final categoryId = row['category_id'] as String;
      result.putIfAbsent(expenseId, () => []).add(categoryId);
    }
    return result;
  }
}
