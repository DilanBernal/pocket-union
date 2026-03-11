import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/models/income.dart';
import 'package:pocket_union/domain/port/local/income_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/filter/income_filter_dto.dart';
import 'package:pocket_union/dto/new_income_dto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class IncomeDaoSqlite implements IncomeLocalPort {
  final DbSqlite dbHelper;
  final LoggerPort _logger;
  final _uuid = Uuid();

  IncomeDaoSqlite({required this.dbHelper, required LoggerPort logger})
    : _logger = logger;

  @override
  Future<String> createIncome(NewIncomeDto dto) async {
    final db = await dbHelper.database;
    final id = _uuid.v4();
    final now = DateTime.now();

    await db.transaction((txn) async {
      // 1. Insertar en income
      await txn.insert('income', {
        'id': id,
        'couple_id': dto.coupleId,
        'name': dto.name,
        'transaction_date': now.toIso8601String(),
        'description': dto.description,
        'amount': (dto.amount * 100).round(),
        'is_received': dto.isReceived ? 1 : 0,
        'created_at': now.toIso8601String(),
        'user_recipient_id': dto.userId,
        'sync_status': 'pending',
        'local_updated_at': now.toIso8601String(),
        'is_deleted': 0,
      });

      // 2. Insertar en income_info
      await txn.insert('income_info', {
        'income_id': id,
        'is_recurring': dto.isRecurring ? 1 : 0,
        'is_received': dto.isReceived ? 1 : 0,
        'received_in': dto.receivedIn,
      });

      // 3. Insertar en income_category (N:N)
      for (final categoryId in dto.categoryIds) {
        await txn.insert('income_category', {
          'income_id': id,
          'category_id': categoryId,
        });
      }
    });

    return id;
  }

  @override
  Future<Income?> getIncomeById(String id) async {
    final db = await dbHelper.database;
    try {
      final maps = await db.rawQuery(
        '''
        SELECT i.*, ii.is_recurring, ii.received_in
        FROM income i
        LEFT JOIN income_info ii ON i.id = ii.income_id
        WHERE i.id = ? AND i.is_deleted = 0
        LIMIT 1
      ''',
        [id],
      );

      if (maps.isEmpty) return null;

      final categoryMaps = await db.query(
        'income_category',
        where: 'income_id = ?',
        whereArgs: [id],
      );
      final categoryIds = categoryMaps
          .map((m) => m['category_id'] as String)
          .toList();

      return Income.fromMap(maps.first, categoryIds: categoryIds);
    } catch (e) {
      _logger.error(
        'IncomeDaoSqlite: Error al buscar ingreso por id',
        error: e,
      );
      return null;
    }
  }

  @override
  Future<List<Income>> getAllIncomes() async {
    final db = await dbHelper.database;
    try {
      final maps = await db.rawQuery('''
        SELECT i.*, ii.is_recurring, ii.received_in
        FROM income i
        LEFT JOIN income_info ii ON i.id = ii.income_id
        WHERE i.is_deleted = 0
        ORDER BY i.transaction_date DESC
      ''');

      if (maps.isEmpty) return [];

      // Cargar todas las categorías de una vez
      final incomeIds = maps.map((m) => m['id'] as String).toList();
      final categoryMap = await _loadCategoryIds(db, incomeIds);

      return maps.map((m) {
        final id = m['id'] as String;
        return Income.fromMap(m, categoryIds: categoryMap[id] ?? []);
      }).toList();
    } catch (e) {
      _logger.error('IncomeDaoSqlite: Error al obtener ingresos', error: e);
      throw Exception("Error al obtener ingresos: $e");
    }
  }

  @override
  Future<List<Income>> getByFilter(IncomeFilterDto filter) async {
    final db = await dbHelper.database;
    final where = <String>['i.is_deleted = 0'];
    final whereArgs = <dynamic>[];

    if (filter.id != null) {
      where.add('i.id = ?');
      whereArgs.add(filter.id);
    }
    if (filter.coupleId != null) {
      where.add('i.couple_id = ?');
      whereArgs.add(filter.coupleId);
    }
    if (filter.categoryId != null) {
      where.add(
        'EXISTS (SELECT 1 FROM income_category ic WHERE ic.income_id = i.id AND ic.category_id = ?)',
      );
      whereArgs.add(filter.categoryId);
    }
    if (filter.isRecurring != null) {
      where.add('ii.is_recurring = ?');
      whereArgs.add(filter.isRecurring! ? 1 : 0);
    }
    if (filter.dateFrom != null) {
      where.add('i.transaction_date >= ?');
      whereArgs.add(filter.dateFrom!.toIso8601String());
    }
    if (filter.dateTo != null) {
      where.add('i.transaction_date <= ?');
      whereArgs.add(filter.dateTo!.toIso8601String());
    }

    final maps = await db.rawQuery('''
      SELECT i.*, ii.is_recurring, ii.received_in
      FROM income i
      LEFT JOIN income_info ii ON i.id = ii.income_id
      WHERE ${where.join(' AND ')}
      ORDER BY i.transaction_date DESC
    ''', whereArgs.isNotEmpty ? whereArgs : null);

    if (maps.isEmpty) return [];

    final incomeIds = maps.map((m) => m['id'] as String).toList();
    final categoryMap = await _loadCategoryIds(db, incomeIds);

    return maps.map((m) {
      final id = m['id'] as String;
      return Income.fromMap(m, categoryIds: categoryMap[id] ?? []);
    }).toList();
  }

  @override
  Future<bool> updateIncome(Income income) async {
    final db = await dbHelper.database;
    try {
      await db.transaction((txn) async {
        // Actualizar tabla income
        await txn.update(
          'income',
          income.toMap(),
          where: 'id = ?',
          whereArgs: [income.id],
        );

        // Upsert income_info
        await txn.insert(
          'income_info',
          income.toIncomeInfoMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Reemplazar categorías: borrar y re-insertar
        await txn.delete(
          'income_category',
          where: 'income_id = ?',
          whereArgs: [income.id],
        );
        for (final categoryId in income.categoryIds) {
          await txn.insert('income_category', {
            'income_id': income.id,
            'category_id': categoryId,
          });
        }
      });
      return true;
    } catch (e) {
      _logger.error('IncomeDaoSqlite: Error al actualizar ingreso', error: e);
      return false;
    }
  }

  @override
  Future<bool> deleteIncome(String id) async {
    final db = await dbHelper.database;
    try {
      final count = await db.update(
        'income',
        {'is_deleted': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      _logger.error('IncomeDaoSqlite: Error al eliminar ingreso', error: e);
      return false;
    }
  }

  /// Carga category_ids en batch para una lista de income IDs.
  Future<Map<String, List<String>>> _loadCategoryIds(
    Database db,
    List<String> incomeIds,
  ) async {
    if (incomeIds.isEmpty) return {};

    final placeholders = List.filled(incomeIds.length, '?').join(',');
    final rows = await db.rawQuery(
      'SELECT income_id, category_id FROM income_category WHERE income_id IN ($placeholders)',
      incomeIds,
    );

    final result = <String, List<String>>{};
    for (final row in rows) {
      final incomeId = row['income_id'] as String;
      final categoryId = row['category_id'] as String;
      result.putIfAbsent(incomeId, () => []).add(categoryId);
    }
    return result;
  }
}
