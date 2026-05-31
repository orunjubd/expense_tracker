import 'package:flutter/material.dart';
import 'package:expense_tracker/dashboard/dashboard.dart'; // Verify dashboard path
import 'package:expense_tracker/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 1. FIXED: Remove any "?" to make sure this is strictly non-nullable and defaults to light mode
  ThemeMode _themeMode = ThemeMode.light;

  // 2. FIXED: Ensure this function takes a strict, non-nullable 'ThemeMode' argument
  void _changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: Dashboard(
        // 3. This matches perfectly with the required parameters in Dashboard now!
        onChangeTheme: _changeTheme,
        currentThemeMode: _themeMode,
      ),
    );
  }
}
