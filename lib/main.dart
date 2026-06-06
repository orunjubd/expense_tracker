import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/dashboard/dashboard.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:expense_tracker/models/expense.dart'; // 1. IMPORT YOUR MODEL
import 'package:expense_tracker/services/database_helper.dart'; // 2. IMPORT SQL HELPER
//import 'package:expense_tracker/auth/auth_screen.dart';

// ===========================================================
// Step 2: Initialize Firebase inside main.dart
// ===========================================================
import 'package:expense_tracker/admin/admin_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/auth/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Import the engine
import 'firebase_options.dart'; // Generated automatically later by the FlutterFire CLI tool

void main() async {
  // 2. Ensures the native engine frameworks are completely bound before booting
  WidgetsFlutterBinding.ensureInitialized();
  // 3. Initialize Firebase. Spawns the background communication channel to your cloud backend servers
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp()); // Runs your main entry widget safely
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
  //   fn,
  // ) {
  //   runApp(const MyApp()); // Runs your main entry widget safely
  // });
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

  // his setup automatically listens to the phone's active Firebase security token state out-of-the-box [INDEX]
  // error-free gatekeeper structure:
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,

      // 🚀 THE MASTER ROUTING GATEKEEPER STREAM
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance
            .authStateChanges(), // Listens to login/logout tokens globally
        builder: (context, snapshot) {
          // A. While firebase is checking security credentials at boot, draw a smooth loader screen
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // B. If NO user security token is found, keep them safely on the login screen
          if (!snapshot.hasData || snapshot.data == null) {
            return const AuthScreen();
          }

          // C. A user token EXISTS! Now let's fetch their role document from Firestore Cloud database
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Failsafe backup: If user collection document is missing, default safely to a User dashboard
              if (!roleSnapshot.hasData || !roleSnapshot.data!.exists) {
                return Dashboard(
                  onChangeTheme: _changeTheme,
                  currentThemeMode: _themeMode,
                  expenses: _allExpenses,
                  onRefresh: _refreshDashboardData,
                );
              }

              // Extract data map strings from cloud document fields safely
              final userData =
                  roleSnapshot.data!.data() as Map<String, dynamic>;
              final String userRole = userData['role'] ?? 'user';

              // D. THE FINAL ROUTING BRANCH DECISION SWITCH
              if (userRole == 'admin') {
                return const AdminDashboard(); // Send Master Admins to the Executive Console
              } else {
                return Dashboard(
                  // Send Standard Users to their Personal Expense Tracker Hub
                  onChangeTheme: _changeTheme,
                  currentThemeMode: _themeMode,
                  expenses: _allExpenses,
                  onRefresh: _refreshDashboardData,
                );
              }
            },
          );
        },
      ),
    );
  }
}
