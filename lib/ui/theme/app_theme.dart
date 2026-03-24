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
      backgroundColor: Color.fromRGBO(20, 0, 20, 1),
    ),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: Colors.white,
      onPrimary: Colors.black,
      surface: const Color.fromARGB(255, 26, 16, 35),
      onSurface: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: const Color.fromARGB(255, 26, 16, 35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      surfaceTintColor: const Color.fromARGB(255, 26, 16, 35),
    ),
    chipTheme: ChipThemeData(
      //rgb(31, 19, 47)
      backgroundColor: const Color.fromARGB(255, 31, 19, 47),
      labelStyle: GoogleFonts.didactGothicTextTheme().labelMedium!.copyWith(
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    textTheme: TextTheme(
      titleLarge: GoogleFonts.bungeeTextTheme().titleLarge!.copyWith(
        color: Colors.white,
      ),
      titleMedium: GoogleFonts.bungeeTextTheme().titleMedium!.copyWith(
        color: Colors.white,
      ),
      titleSmall: GoogleFonts.bungeeTextTheme().titleSmall!.copyWith(
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.didactGothicTextTheme().bodyLarge!.copyWith(
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.didactGothicTextTheme().bodyMedium!.copyWith(
        color: Colors.white,
      ),
      bodySmall: GoogleFonts.didactGothicTextTheme().bodySmall!.copyWith(
        color: Colors.white,
      ),
      labelLarge: GoogleFonts.didactGothicTextTheme().labelLarge!.copyWith(
        color: Colors.white,
      ),
      labelMedium: GoogleFonts.honkTextTheme().labelMedium!.copyWith(
        color: Colors.white,
      ),
      labelSmall: GoogleFonts.didactGothicTextTheme().labelSmall!.copyWith(
        color: Colors.white,
      ),
    ),
  );
}
