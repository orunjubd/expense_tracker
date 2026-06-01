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

  @override
  void initState() {
    super.initState();
    _loadExpensesFromDatabase(); // Automatically triggers data reading on startup
  }

  void _loadExpensesFromDatabase() async {
    final savedData = await DatabaseHelper.instance.getExpenses();

    // 1. ADD THIS LOOP SCRIPT TO CHECK YOUR SQL DATA IN THE TERMINAL
    // print('--- SQL DATABASE ENTRIES ---');
    // for (final exp in savedData) {
    //   print(
    //     'ID: ${exp.id} | Title: ${exp.title} | Amount: \$${exp.amount} | Category: ${exp.category.name}',
    //   );
    // }
    // print('----------------------------');

    setState(() {
      _registeredExpenses = savedData;
    });
  }

  // ===========================================================================
  //  Add and Update your overlay launcher method to accept a target item:
  // ===========================================================================
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

  @override
  Widget build(BuildContext context) {
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
