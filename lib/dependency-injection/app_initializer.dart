import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppInitializer {
  static Future<AppDependencies> initialize() async {
    final sqliteHelper = DbSqlite.instance;
    await sqliteHelper.database;

    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    await Supabase.initialize(
      url: '',
      anonKey: '',
    );
    final supabase = Supabase.instance.client;

    return AppDependencies(
      dbSqlite: sqliteHelper,
      sharedPreferences: prefs,
      isFirstLaunch: isFirstLaunch,
      supabaseClient: supabase,
    );
  }
}

class AppDependencies {
  final DbSqlite dbSqlite;
  final SharedPreferences sharedPreferences;
  final bool isFirstLaunch;
  final SupabaseClient supabaseClient;

  AppDependencies({
    required this.dbSqlite,
    required this.sharedPreferences,
    required this.isFirstLaunch,
    required this.supabaseClient,
  });
}
