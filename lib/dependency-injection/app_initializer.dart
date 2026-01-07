import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/dependency-injection/app_dependencies.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppInitializer {
  static Future<AppDependencies> initialize() async {
    final sqliteHelper = DbSqlite.instance;
    await sqliteHelper.database;
    await dotenv.load(fileName: ".env", isOptional: false);

    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_API_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
