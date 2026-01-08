import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

// Provider para SQLite Database
final sqliteDbProvider = FutureProvider<Database>((ref) async {
  final dbHelper = DbSqlite.instance;
  return await dbHelper.database;
});

// Provider para DbSqlite instance
final dbSqliteProvider = Provider<DbSqlite>((ref) {
  return DbSqlite.instance;
});

// Provider para SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});
