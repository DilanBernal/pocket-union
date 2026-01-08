import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/dependency-injection/app_initializer.dart';
import 'package:pocket_union/dependency-injection/multi_provider.dart';
import 'package:pocket_union/ui/router.dart';
import 'package:pocket_union/ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencies = await AppInitializer.initialize();

  runApp(
    ProviderScope(
      child: MultiProviderInApp(
        dbSqlite: dependencies.dbSqlite,
        sharedPreferences: dependencies.sharedPreferences,
        child: const PocketUnionApp(),
      ),
    ),
  );
}

class PocketUnionApp extends StatelessWidget {
  const PocketUnionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.blackDarkTheme,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        return Scaffold(body: child);
      },
      debugShowCheckedModeBanner: false,
      routes: AppRoutes.routes,
    );
  }
}
