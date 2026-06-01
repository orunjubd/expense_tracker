import 'package:flutter/material.dart';

// 📝 NOTE / HINTS:==================================================================
// 1) GLOBAL COLOR SCHEME SEED CONFIGURATION
// What it does: These are the master engine color generators for your application.
// - 'kColorScheme' uses your primary brand color (Royal Purple) as a seed to mathematically auto-generate matching shades of backgrounds, buttons, and card borders for Light Mode.
// - 'kDarkColorScheme' does the same but passes 'brightness: Brightness.dark' to generate a dark theme palette (Slate Blue tints) that feels soft on the user's eyes at night.
// 1. Declare your core color scheme blueprint variable configuration
final kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 59, 12, 135),
);

// 2. Dark mode theme
final kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 5, 99, 125),
);

// 📝 NOTE / HINTS:
// 2) THE GLOBAL THEME ORGANIZER CLASS:
// What it does: This acts as your central CSS repository class. It keeps your interface logic separate from layout design choices. Instead of manually hardcoding fonts and hex color boxes inside every separate file, you write them once here.
// How it connects: Your 'main.dart' file reads these static getters directly on boot. Every screen can then query these settings effortlessly using 'Theme.of(context)'.
// 1.1. Wrap all your extracted visual styles into a clean theme class
class AppTheme {
  // 📝 NOTE / HINTS:==================================================================
  // 3) DARK THEME PACKAGE BLUEPRINT (GETTER):
  // What it does: This is your complete pre-packaged Dark Mode styling system bundle.
  // - 'useMaterial3: true' activates modern UI shapes and component physics.
  // - It locks the main canvas body to a deep charcoal color ('Colors.grey.shade900') and applies the Slate Blue color palette map.
  // - It defines dark-friendly AppBar background shading and high-contrast font rules.
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

  // 📝 NOTE / HINTS:==================================================================
  // 4) LIGHT THEME PACKAGE BLUEPRINT (GETTER):
  // What it does: This is your complete pre-packaged Light Mode styling system bundle.
  // - It sets a soft, clean grey canvas background color ('Color.fromARGB(255, 245, 245, 247)') to make white material cards stand out beautifully.
  // - It maps your Royal Purple color palette map onto standard structural headers.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color.fromARGB(255, 245, 245, 247),
      colorScheme: kColorScheme,

      // 📝 NOTE / HINTS:==================================================================
      // 5) APPBAR VISUAL THEME PACKAGE BLUEPRINT (GETTER):
      // What it does: This isolates and configures the style of your top navigation app header bar.
      // - 'backgroundColor' matches the bar color with the main brand color.
      // - 'foregroundColor' automatically picks a high-contrast ink color (like white text) for top headings.
      // - 'elevation: 0' removes old Material 2 drop-shadow lines to give your app a flat, modern appearance.
      // Isolated AppBar styles
      appBarTheme: const AppBarTheme().copyWith(
        backgroundColor: kColorScheme.primary,
        foregroundColor: kColorScheme.onPrimary,
        elevation: 0,
      ),

      // 📝 NOTE / HINTS:==================================================================
      // 6) GLOBAL TYPOGRAPHY ARCHITECTURE (TEXTTHEME):
      // What it does: This is the global font hierarchy ruleset for your application. It standardizes letter heights, line formatting widths, and weight values across your workspace tabs.
      // - 'titleLarge': For main dashboard title blocks and page headings.
      // - 'titleMedium': For list item title elements and action card titles.
      // - 'bodyMedium': For standard paragraph body content, labels, dates, and currency strings.
      // Isolated Typography styles
      // ==================================================================================
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
