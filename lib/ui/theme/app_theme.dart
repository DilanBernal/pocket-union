import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData.light();

  static final ThemeData blackDarkTheme = ThemeData(
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
}
