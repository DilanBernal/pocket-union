import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/models/income.dart';
import 'package:pocket_union/domain/port/feat/income_port.dart';
import 'package:pocket_union/dto/new_income_dto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class IncomeDaoSqlite implements IncomePort {
  final DbSqlite dbHelper;
  final _uuid = Uuid();

  IncomeDaoSqlite({required this.dbHelper});

  @override
  Future<String> createIncome(NewIncomeDto dto) async {
    final db = await dbHelper.database;
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    await db.insert(
      'income',
      {
        'id': id,
        'name': dto.name,
        'amount': dto.amount,
        'category_id': dto.categoryId,
        'description': dto.description,
        'transaction_date': now,
        'is_recurring': dto.isRecurring ? 1 : 0,
        'recurrence_interval': null,
        'is_received': dto.isReceived ? 1 : 0,
        'received_in': null,
        'created_at': now,
        'user_recipient_id': dto.userRecipientId,
        'sync_status': 'pending',
        'local_updated_at': now,
        'is_deleted': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  @override
  Future<List<Income>> getAllIncomes() async {
    final db = await dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.query('income', orderBy: 'created_at DESC');
      return List.generate(maps.length, (int i) {
        return Income.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception(e);
    }
  }
}
