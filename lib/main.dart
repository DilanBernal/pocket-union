import 'package:flutter/material.dart';
import 'package:pocket_union/dependency-injection/app_initializer.dart';
import 'package:pocket_union/dependency-injection/multi_provider.dart';
import 'package:pocket_union/ui/router.dart';
import 'package:pocket_union/ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencies = await AppInitializer.initialize();

  runApp(
    MultiProviderInApp(
      dbSqlite: dependencies.dbSqlite,
      sharedPreferences: dependencies.sharedPreferences,
      child: const PocketUnionApp(),
    ),
  );
}

class PocketUnionApp extends StatelessWidget {
  const PocketUnionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.blackDarkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routes: AppRoutes.routes,
    );
  }
}
