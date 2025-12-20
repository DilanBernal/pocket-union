import 'package:flutter/material.dart';
import 'package:pocket_union/Dao/sqlite/category_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/revenue_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/user_dao_sqlite.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MultiProviderInApp extends StatelessWidget {
  const MultiProviderInApp({super.key});


  @override
  Widget  build(BuildContext context) {
    return MultiProvider(  providers: [
      Provider<DbSqlite>(create: (_) => sqliteHelper),
      Provider<UserDaoSqlite>(
          create: (ctx) => UserDaoSqlite(dbHelper: ctx.read<DbSqlite>())),
      Provider<RevenueDaoSqlite>(
          create: (ctx) => RevenueDaoSqlite(dbHelper: ctx.read<DbSqlite>())),
      Provider<SharedPreferences>(create: (_) => prefs),
      Provider<CategoryDaoSqlite>(
          create: (ctx) => CategoryDaoSqlite(dbHelper: ctx.read<DbSqlite>()))
    ],)
  }
}