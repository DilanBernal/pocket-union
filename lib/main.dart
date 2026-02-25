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
  final coupleId = prefs.getString('coupleId');
  final hasCoupleReady = coupleId != null && coupleId.isNotEmpty;

  String initialRoute;
  if (isFirstLaunch) {
    initialRoute = AppRoutes.start;
  } else if (!isInSession) {
    initialRoute = AppRoutes.login;
  } else if (!hasCoupleReady) {
    initialRoute = AppRoutes.coupleSetup;
  } else {
    initialRoute = AppRoutes.home;
  }

  runApp(
    ProviderScope(
      child: PocketUnionApp(initialRoute: initialRoute),
    ),
  );
}

class PocketUnionApp extends StatelessWidget {
  final String initialRoute;

  const PocketUnionApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: initialRoute,
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
