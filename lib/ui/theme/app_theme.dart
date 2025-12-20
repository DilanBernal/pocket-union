import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    textTheme: TextTheme(
      titleLarge: GoogleFonts.bungeeTextTheme()
          .titleLarge!
          .copyWith(color: Colors.white),
      titleMedium: GoogleFonts.bungeeTextTheme()
          .titleMedium!
          .copyWith(color: Colors.white),
      titleSmall: GoogleFonts.bungeeTextTheme()
          .titleSmall!
          .copyWith(color: Colors.white),
      bodyLarge: GoogleFonts.didactGothicTextTheme()
          .bodyLarge!
          .copyWith(color: Colors.white),
      bodyMedium: GoogleFonts.didactGothicTextTheme()
          .bodyMedium!
          .copyWith(color: Colors.white),
      bodySmall: GoogleFonts.didactGothicTextTheme()
          .bodySmall!
          .copyWith(color: Colors.white),
      labelLarge: GoogleFonts.didactGothicTextTheme()
          .labelLarge!
          .copyWith(color: Colors.white),
      labelMedium: GoogleFonts.honkTextTheme()
          .labelMedium!
          .copyWith(color: Colors.white),
      labelSmall: GoogleFonts.didactGothicTextTheme()
          .labelSmall!
          .copyWith(color: Colors.white),
    ),
  );
}
