import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppDependencies {
  final DbSqlite dbSqlite;
  final SharedPreferences sharedPreferences;
  final bool isFirstLaunch;
  final SupabaseClient supabaseClient;

  const AppDependencies({
    required this.dbSqlite,
    required this.sharedPreferences,
    required this.isFirstLaunch,
    required this.supabaseClient,
  });
}
