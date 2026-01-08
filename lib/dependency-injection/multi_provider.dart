import 'package:flutter/material.dart';
import 'package:pocket_union/Dao/sqlite/category_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/user_dao_sqlite.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MultiProviderInApp extends StatelessWidget {
  final DbSqlite dbSqlite;
  final SharedPreferences sharedPreferences;
  final Widget child;

  const MultiProviderInApp({
    super.key,
    required this.dbSqlite,
    required this.sharedPreferences,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DbSqlite>(create: (_) => dbSqlite),
        Provider<UserDaoSqlite>(
          create: (ctx) => UserDaoSqlite(dbHelper: ctx.read<DbSqlite>()),
        ),
        Provider<SharedPreferences>(create: (_) => sharedPreferences),
        Provider<CategoryDaoSqlite>(
          create: (ctx) => CategoryDaoSqlite(dbHelper: ctx.read<DbSqlite>()),
        ),
      ],
      child: child,
    );
  }
}
