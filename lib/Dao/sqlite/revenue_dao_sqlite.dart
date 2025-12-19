import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/domain/models/revenue.dart';
import 'package:sqflite/sqflite.dart';

class RevenueDaoSqlite {
  final DbSqlite dbHelper;

  RevenueDaoSqlite({required this.dbHelper});

  Future<int> insertRevenue(Revenue revenue) async {
    final db = await dbHelper.database;
    int id = await db.insert('revenue', revenue.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future<List<Revenue>> getAllRevenues() async{
    final db = await dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'revenue',
        orderBy: 'name ASC'
      );
      return List.generate(maps.length, (int i) {
        return Revenue.fromMap(maps[i]);
      });
    }catch (e) {
      throw Exception(e);
    }
  }
}
