import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/models/income.dart';
import 'package:pocket_union/domain/port/local/income_port_local.dart';
import 'package:pocket_union/dto/new_income_dto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class IncomeDaoSqlite implements IncomeLocalPort {
  final DbSqlite dbHelper;
  final _uuid = Uuid();

  IncomeDaoSqlite({required this.dbHelper});

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
      throw Exception("Error al obtener ingresos: $e");
    }
  }

  /// Legacy method kept for backward compatibility
  Future<int> insertRevenue(NewIncomeDto revenueDto) async {
    final db = await dbHelper.database;
    final revenue = Income(
      id: _uuid.v4(),
      name: revenueDto.name,
      transactionDate: DateTime.now(),
      amount: revenueDto.amount,
      createdAt: DateTime.now(),
    );
    int id = await db.insert(
      'income',
      revenue.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }
}
