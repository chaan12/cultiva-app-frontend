import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.white,
    cardColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.greenDark,
      brightness: Brightness.light,
      surface: const Color(0xFFF1F4E0),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Colors.black45),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.greenDark,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0D1711),
    cardColor: const Color(0xFF17241B),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.greenPrimary,
      brightness: Brightness.dark,
      surface: const Color(0xFF0D1711),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF203327),
      hintStyle: const TextStyle(color: Color(0xFFB6C4BA)),
      prefixIconColor: const Color(0xFFB6C4BA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF102519),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
