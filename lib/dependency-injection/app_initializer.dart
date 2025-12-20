import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInitializer {
  static Future<AppDependencies> initialize() async {
    final sqliteHelper = DbSqlite.instance;
    await sqliteHelper.database;

    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    return AppDependencies(
      dbSqlite: sqliteHelper,
      sharedPreferences: prefs,
      isFirstLaunch: isFirstLaunch,
    );
  }
}

class AppDependencies {
  final DbSqlite dbSqlite;
  final SharedPreferences sharedPreferences;
  final bool isFirstLaunch;

  AppDependencies({
    required this.dbSqlite,
    required this.sharedPreferences,
    required this.isFirstLaunch,
  });
}
