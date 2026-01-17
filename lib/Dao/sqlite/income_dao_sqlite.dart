import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/models/income.dart';
import 'package:pocket_union/dto/new_income_dto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class IncomeDaoSqlite {
  final DbSqlite dbHelper;
  final _uuid = Uuid();

  IncomeDaoSqlite({required this.dbHelper});

  Future<int> insertRevenue(NewIncomeDto revenueDto) async {
    final db = await dbHelper.database;
    final revenue = Income(
        id: _uuid.v4(),
        name: revenueDto.name,
        transactionDate: DateTime.now(),
        amount: revenueDto.amount,
        createdAt: DateTime.now(),
        inCloud: false);
    int id = await db.insert('revenue', revenue.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future<List<Income>> getAllRevenues() async {
    final db = await dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.query('revenue', orderBy: 'name ASC');
      return List.generate(maps.length, (int i) {
        return Income.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception(e);
    }
  }
}
