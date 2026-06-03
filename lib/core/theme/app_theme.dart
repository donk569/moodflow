import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color bgWarmWhite = Color(0xFFfaf8f5);
  static const Color cardWhite = Color(0xFFffffff);
  static const Color textBrown = Color(0xFF5c4a3a);
  static const Color textSecondary = Color(0xFFa89888);
  static const Color textTertiary = Color(0xFFb8a99a);
  static const Color buttonApricot = Color(0xFFc8a080);
  static const Color divider = Color(0xFFe8e0d8);
  static const Color maleBlueBg = Color(0xFFe8f4fd);
  static const Color femalePinkBg = Color(0xFFffe8f0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: buttonApricot,
        surface: bgWarmWhite,
        onSurface: textBrown,
      ),
      scaffoldBackgroundColor: bgWarmWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: bgWarmWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textBrown,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonApricot,
          foregroundColor: Colors.white,
          padding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle:
              const TextStyle(fontSize: 16, letterSpacing: 0.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textTertiary,
          textStyle: const TextStyle(fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: divider, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: buttonApricot, width: 1.5),
        ),
        hintStyle:
            const TextStyle(color: textTertiary, fontSize: 15),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin:
            const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardWhite,
        selectedItemColor: buttonApricot,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
