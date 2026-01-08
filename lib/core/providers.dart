import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:riverpod/riverpod.dart';

final sqliteDbProvider = Provider<DbSqlite>((ref) {
  return DbSqlite.instance;
});
