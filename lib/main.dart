import 'package:flutter/material.dart';
import 'package:pocket_union/Dao/sqlite/category_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/db_helper_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/revenue_dao_sqlite.dart';
import 'package:pocket_union/Dao/sqlite/user_dao_sqlite.dart';
import 'package:pocket_union/ui/router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sqliteHelper = DbSqlite.instance;
  await sqliteHelper.database;
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  runApp(MultiProvider(
    providers: [
      Provider<DbSqlite>(create: (_) => sqliteHelper),
      Provider<UserDaoSqlite>(
          create: (ctx) => UserDaoSqlite(dbHelper: ctx.read<DbSqlite>())),
      Provider<RevenueDaoSqlite>(
          create: (ctx) => RevenueDaoSqlite(dbHelper: ctx.read<DbSqlite>())),
      Provider<SharedPreferences>(create: (_) => prefs),
      Provider<CategoryDaoSqlite>(
          create: (ctx) => CategoryDaoSqlite(dbHelper: ctx.read<DbSqlite>()))
    ],
    child: PocketUnionApp(isFirstLaunch: isFirstLaunch),
  ));
}

class PocketUnionApp extends StatefulWidget {
  final bool isFirstLaunch;

  const PocketUnionApp({super.key, required this.isFirstLaunch});

  @override
  State<PocketUnionApp> createState() => _PocketUnionAppState();
}

class _PocketUnionAppState extends State<PocketUnionApp> {
  late bool _isFirstLaunch;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _isFirstLaunch = widget.isFirstLaunch;
    _setupPrefsListener();
  }

  Future<void> _setupPrefsListener() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefs = Provider.of<SharedPreferences>(context, listen: false);
      Future.delayed(const Duration(milliseconds: 500), () {
        _checkFirstLaunchChange();
      });
    });
  }

  void _checkFirstLaunchChange() {
    bool currentValue = _prefs.getBool('isFirstLaunch') ?? true;
    if (currentValue != _isFirstLaunch) {
      setState(() {
        _isFirstLaunch = currentValue;
      });
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _checkFirstLaunchChange();
      }
    });
  }

  final ThemeData blackDarkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color.fromRGBO(20, 0, 20, 0.85),
    ),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: Colors.white,
      onPrimary: Colors.black,
      surface: const Color.fromRGBO(82, 0, 138, 1.0),
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: blackDarkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routes: AppRoutes.routes,
      // home: _isFirstLaunch
      //     ? Scaffold(body: const StartScreen())
      //     : Scaffold(
      //         appBar: AppBar(
      //           title: const Text(''),
      //         ),
      //         body: const SafeArea(
      //           child: HomeScreen(),
      //         ),
      //         drawer: Drawer(
      //           child: ListMenu(),
      //         ),
      //       ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
