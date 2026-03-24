import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/models/recurrent_income.dart';
import 'package:pocket_union/domain/port/local/recurrent_income_port_local.dart';
import 'package:pocket_union/domain/port/utils/logger_port.dart';
import 'package:pocket_union/dto/new_recurrent_income_dto.dart';
import 'package:uuid/uuid.dart';

class RecurrentIncomeDaoSqlite implements RecurrentIncomeLocalPort {
  final DbSqlite _dbHelper;
  final LoggerPort _logger;
  final Uuid _uuid = const Uuid();

  RecurrentIncomeDaoSqlite({
    required DbSqlite dbHelper,
    required LoggerPort logger,
  }) : _dbHelper = dbHelper,
       _logger = logger;

  @override
  Future<String> createRecurrentIncome(NewRecurrentIncomeDto dto) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    final now = DateTime.now();

    await db.insert('recurrent_income', {
      'id': id,
      'created_at': now.toIso8601String(),
      'name': dto.name,
      'user_recipient_id': dto.userRecipientId,
      'couple_id': dto.coupleId,
      'amount': (dto.amount * 100).round(),
      'recurrent_info': dto.recurrentInfo,
      'sync_status': 'pending',
    });

    return id;
  }

  @override
  Future<RecurrentIncome?> getRecurrentIncomeById(String id) async {
    final db = await _dbHelper.database;
    try {
      final maps = await db.query(
        'recurrent_income',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return RecurrentIncome.fromMap(maps.first);
    } catch (e) {
      _logger.error(
        'RecurrentIncomeDaoSqlite: Error al buscar ingreso recurrente',
        error: e,
      );
      return null;
    }
  }

  @override
  Future<List<RecurrentIncome>> getAllRecurrentIncomes() async {
    final db = await _dbHelper.database;
    try {
      final maps = await db.query(
        'recurrent_income',
        orderBy: 'created_at DESC',
      );
      return maps.map((m) => RecurrentIncome.fromMap(m)).toList();
    } catch (e) {
      _logger.error(
        'RecurrentIncomeDaoSqlite: Error al obtener ingresos recurrentes',
        error: e,
      );
      throw Exception("Error al obtener ingresos recurrentes: $e");
    }
  }

  @override
  Future<bool> updateRecurrentIncome(RecurrentIncome recurrentIncome) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.update(
        'recurrent_income',
        recurrentIncome.toMap(),
        where: 'id = ?',
        whereArgs: [recurrentIncome.id],
      );
      return count > 0;
    } catch (e) {
      _logger.error(
        'RecurrentIncomeDaoSqlite: Error al actualizar ingreso recurrente',
        error: e,
      );
      return false;
    }
  }

  @override
  Future<bool> deleteRecurrentIncome(String id) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.delete(
        'recurrent_income',
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      _logger.error(
        'RecurrentIncomeDaoSqlite: Error al eliminar ingreso recurrente',
        error: e,
      );
      return false;
    }
  }
}
