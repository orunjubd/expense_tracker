import 'package:flutter/material.dart';

// 1. Declare your core color scheme blueprint variable configuration
final kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 59, 12, 135),
);

// 2. Dark mode theme
final kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 5, 99, 125),
);

// 1.1. Wrap all your extracted visual styles into a clean theme class
class AppTheme {
  // 2.2. Define your light and dark themes
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.grey.shade900,
    colorScheme: kDarkColorScheme,
    appBarTheme: const AppBarTheme().copyWith(
      backgroundColor: kDarkColorScheme.primary,
      foregroundColor: kDarkColorScheme.onPrimary,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
    ),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color.fromARGB(255, 245, 245, 247),
      colorScheme: kColorScheme,

      // Isolated AppBar styles
      appBarTheme: const AppBarTheme().copyWith(
        backgroundColor: kColorScheme.primary,
        foregroundColor: kColorScheme.onPrimary,
        elevation: 0,
      ),

      // Isolated Typography styles
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
      ),
    );
  }
}
