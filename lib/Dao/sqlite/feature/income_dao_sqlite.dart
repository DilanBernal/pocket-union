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
    final income = Income(
      id: id,
      coupleId: dto.coupleId,
      name: dto.name,
      transactionDate: now,
      description: dto.description,
      amount: dto.amount,
      categoryId: dto.categoryId,
      isRecurring: dto.isRecurring,
      isReceived: dto.isReceived,
      createdAt: now,
      userRecipientId: dto.userId,
    );
    await db.insert(
      'income',
      income.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  @override
  Future<Income?> getIncomeById(String id) async {
    final db = await dbHelper.database;
    try {
      final maps = await db.query(
        'income',
        where: 'id = ? AND is_deleted = 0',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Income.fromMap(maps.first);
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
      final List<Map<String, dynamic>> maps = await db.query(
        'income',
        where: 'is_deleted = 0',
        orderBy: 'transaction_date DESC',
      );
      return List.generate(maps.length, (int i) {
        return Income.fromMap(maps[i]);
      });
    } catch (e) {
      _logger.error('IncomeDaoSqlite: Error al obtener ingresos', error: e);
      throw Exception("Error al obtener ingresos: $e");
    }
  }

  @override
  Future<List<Income>> getByFilter(IncomeFilterDto filter) async {
    final db = await dbHelper.database;
    final where = <String>['is_deleted = 0'];
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
    if (filter.isRecurring != null) {
      where.add('is_recurring = ?');
      whereArgs.add(filter.isRecurring! ? 1 : 0);
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
      'income',
      where: where.join(' AND '),
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'transaction_date DESC',
    );
    return maps.map((m) => Income.fromMap(m)).toList();
  }

  @override
  Future<bool> updateIncome(Income income) async {
    final db = await dbHelper.database;
    try {
      final count = await db.update(
        'income',
        income.toMap(),
        where: 'id = ?',
        whereArgs: [income.id],
      );
      return count > 0;
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
}
