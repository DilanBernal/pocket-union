import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/ui/router.dart';
import 'package:pocket_union/ui/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Obtener SharedPreferences para determinar la ruta inicial
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  final isInSession = prefs.getBool('isInSession') ?? false;

  runApp(
    ProviderScope(
      child: PocketUnionApp(
          isFirstLaunch: isFirstLaunch, isInSession: isInSession),
    ),
  );
}

class PocketUnionApp extends StatelessWidget {
  final bool isFirstLaunch;
  final bool isInSession;

  const PocketUnionApp(
      {super.key, required this.isFirstLaunch, required this.isInSession});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: isFirstLaunch
          ? AppRoutes.start
          : !isInSession
              ? AppRoutes.login
              : AppRoutes.home,
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
