import 'dart:async';

import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/overlays/new_expenses.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/services/database_helper.dart';

class Expenses extends StatefulWidget {
  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }

  const Expenses({super.key});
}

class _ExpensesState extends State<Expenses> {
  List<Expense> _registeredExpenses = [];

  // 📝 NOTE / HINTS:
  // 1) STATEFUL LIFECYCLE IGNITION (INITSTATE):
  // What it does: This is the bootloader manager of your screen.
  // - 'initState()' is a built-in method that fires automatically exactly ONCE when this page first opens.
  // How it connects: It calls '_loadExpensesFromDatabase()' right away so your saved data is read
  // from storage before the user even looks at the screen layout.
  @override
  void initState() {
    super.initState();
    _loadExpensesFromDatabase(); // Automatically triggers data reading on startup
  }

  // 📝 NOTE / HINTS:
  // 2) DATABASE LOADER / STATE SYNCER (LOADEXPENSESFROMDATABASE):
  // What it does: This is your Read (R) operation manager. It asynchronously waits for the
  // SQLite database engine to collect all transaction rows, then runs 'setState()' to overwrite
  // your empty list array and cleanly re-draw your charts and cards with real data.
  // How it connects: Talks directly to 'DatabaseHelper.instance.getExpenses()'.
  void _loadExpensesFromDatabase() async {
    final savedData = await DatabaseHelper.instance.getExpenses();
    setState(() {
      _registeredExpenses = savedData;
    });
  }

  // ===========================================================================
  //  Add and Update your overlay launcher method to accept a target item:
  // ===========================================================================
  // 📝 NOTE / HINTS:
  // 3) OVERLAY SHEET LAUNCHER (_OPENADDEXPENSEOVERLAY):
  // What it does: This slides your input sheet up from the floor of the device viewport frame.
  // - It is upgraded to accept an optional 'Expense? expense' package argument map.
  // - If 'expense' is null, it opens a blank form to create an item. If it has data, it passes
  //   that data down to pre-fill the form text fields for editing!
  // How it connects: Triggered by the top AppBar plus button (+) or by clicking an item card tile.
  void _openAddExpenseOverlay({Expense? expense}) {
    showModalBottomSheet(
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpenses(
        onAddExpense: _addExpense,
        expenseToEdit:
            expense, // Pass the row data straight down into the inputs form!
      ),
    );
  }

  // ===========================================================================
  // Add the DB Update execution inside your main _addExpense handler block:
  // ===========================================================================
  // 📝 NOTE / HINTS:
  // 4) DUAL SMART SAVE ENGINE (_ADDEXPENSE):
  // What it does: This is a smart handler that manages both Create (C) and Update (U) operations.
  // - It inspects the item's unique tracking ID: If the ID already exists in your local storage list,
  //   it executes an 'updateExpense()' SQL script. If the ID is completely fresh, it runs 'insertExpense()'.
  // How it connects: Receives validated inputs back from your overlay form worksheet on submission.
  void _addExpense(Expense expense) async {
    // Check if this ID already exists inside our current memory state list array
    final isExisting = _registeredExpenses.any(
      (element) => element.id == expense.id,
    );
    if (isExisting) {
      await DatabaseHelper.instance.updateExpense(expense); // Run SQL UPDATE
    } else {
      await DatabaseHelper.instance.insertExpense(expense); // Run SQL INSERT
    }
    _loadExpensesFromDatabase(); // Refresh everything automatically!
  }

  // 📝 NOTE / HINTS:
  // 5) Protected Eraser & Undo SnackBar Engine (_removeExpense):
  // What it does: This is your Delete (D) operation manager. It handles row purges safely.
  // - It runs an SQL deletion script, removes the item from your visual list, and opens an interactive SnackBar.
  // - 'if (!mounted) return;' is an async guard that blocks execution if the user closed the screen,
  //   preventing production crashes.
  // - The 'Undo' button inserts the item straight back into the database and refreshes the screen data.
  // - 'Timer()' is a hard programmatic fallback clock that forces stuck notifications down after 3 seconds.
  void _removeExpense(Expense expense) async {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    await DatabaseHelper.instance.deleteExpense(
      expense.id,
    ); // 1. Delete from SQLite

    // 2. PROTECT CONTEXT: If the user navigated away while the database was busy,
    // stop execution immediately so the app never crashes!
    if (!mounted) return;

    setState(() {
      _registeredExpenses.remove(expense);
    });

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${expense.title}" deleted!'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            // If undo is pressed, slide the entry right back into the storage layer!
            await DatabaseHelper.instance.insertExpense(expense);
            setState(() {
              // FIXED: Passing expenseIndex here uses the variable and clears the warning!
              _registeredExpenses.insert(expenseIndex, expense);
            });

            _loadExpensesFromDatabase();
          },
        ),
      ),
    );

    // 4. GUARANTEED WORKAROUND: Force a hard programmatic close after 3 seconds
    Timer(const Duration(seconds: 3), () {
      // 'mounted' verifies the screen is still active before trying to clear it
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }

  // 📝 NOTE / HINTS:
  // 7) MASTER SCAFFOLD BUILD TREE LAYOUT:
  // What it does: This maps out the physical layout structure down your tracker page viewport.
  // - The top 'AppBar' manages page branding titles and houses your overlay plus button trigger (+).
  // - The body Column sets up a perfect top-to-bottom stack sequence: Left-aligned
  //   'Financial Analytics' Header text ➔ Dynamic Category Bar 'Chart()' ➔ Scrolled Transaction list ('Expanded').
  @override
  Widget build(BuildContext context) {
    // 📝 NOTE / HINTS:
    // 6) CONDITIONAL FALLBACK CONTENT WATCHDOG (mainContent):
    // What it does: This is a conditional layout monitor. By default, it sets 'mainContent'
    // to a soft red placeholder text block ('No expenses found. Start adding some!').
    // - If your database array list is NOT empty, it instantly overwrites that variable with
    //   your high-performance scrolling widget engine 'ExpensesList()'.
    // How it connects: Placed directly inside your lower Column build tree.
    // 1. Setup the default fallback text layout
    Widget mainContent = const Center(
      child: Text(
        'No expenses found. Start adding some!',
        style: TextStyle(
          fontSize: 16,
          color: Color.fromARGB(255, 246, 148, 148),
        ),
      ),
    );

    // 2. Override it with the actual list if items exist
    if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _registeredExpenses,
        onRemoveExpense: _removeExpense,
        onEditExpense: _openAddExpenseOverlay, // 👈 ADD THIS LINE
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openAddExpenseOverlay,
          ),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Aligns text to the left
          children: [
            // 1. TOP TITLE SECTION (Stays clean at the top)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'Financial Analytics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 2. FIXED: Replaced the old static placeholder Container box
            // with your real dynamic Chart diagram component!
            Chart(expenses: _registeredExpenses),
            const SizedBox(height: 12),
            // 3. THE SCROLLING EXPENSE RECORDS LIST (Takes up the remaining screen)
            Expanded(child: mainContent),
          ],
        ),
      ),
    );
  }
}
