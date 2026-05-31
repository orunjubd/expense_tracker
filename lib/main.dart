import 'package:flutter/material.dart';
import 'package:expense_tracker/dashboard/dashboard.dart'; // Verify dashboard path
import 'package:expense_tracker/theme/app_theme.dart';

final kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 59, 12, 135),
);

void main() {
  runApp(
    MaterialApp(
      title: 'Expense Tracker',
      // themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      home: const Dashboard(), // Automatically opens your fresh dashboard!
    ),
  );
}
