import 'package:flutter/material.dart';
import 'package:expense_tracker/dashboard/dashboard.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:expense_tracker/models/expense.dart'; // 1. IMPORT YOUR MODEL
import 'package:expense_tracker/services/database_helper.dart'; // 2. IMPORT SQL HELPER

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  List<Expense> _allExpenses = []; // 3. DECLARE THE LIVE ARRAY LIST HERE

  @override
  void initState() {
    super.initState();
    _refreshDashboardData(); // 4. Fetch database records instantly at boot
  }

  // 5. Create a dynamic method to sync local variables with SQL rows
  void _refreshDashboardData() async {
    final data = await DatabaseHelper.instance.getExpenses();
    setState(() {
      _allExpenses = data;
    });
  }

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
        onChangeTheme: _changeTheme,
        currentThemeMode: _themeMode,
        // 6. PASS THE REAL LIVE DATA AND REFRESH METHOD DOWN
        expenses: _allExpenses,
        onRefresh: _refreshDashboardData,
      ),
    );
  }
}
