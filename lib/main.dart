import 'package:flutter/material.dart';
import 'package:expense_tracker/dashboard/dashboard.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:expense_tracker/models/expense.dart'; // 1. IMPORT YOUR MODEL
import 'package:expense_tracker/services/database_helper.dart'; // 2. IMPORT SQL HELPER
//import 'package:expense_tracker/auth/auth_screen.dart';

// ===========================================================
// Step 2: Initialize Firebase inside main.dart
// ===========================================================
import 'package:firebase_core/firebase_core.dart'; // 1. Import the engine
import 'firebase_options.dart'; // Generated automatically later by the FlutterFire CLI tool

void main() async {
  // 2. Ensures the native engine frameworks are completely bound before booting
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Initialize Firebase. Spawns the background communication channel to your cloud backend servers
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp()); // Runs your main entry widget safely
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
