import 'dart:async';

import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/overlays/new_expenses.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';

class Expenses extends StatefulWidget {
  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }

  const Expenses({super.key});
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _registeredExpenses = [
    Expense(
      title: 'Fluter Course',
      amount: 19.99,
      date: DateTime.now(),
      category: Category.work,
    ),
    Expense(
      title: 'Cinema',
      amount: 15.99,
      date: DateTime.now(),
      category: Category.leisure,
    ),
    Expense(
      title: 'New Shoes',
      amount: 69.99,
      date: DateTime.now(),
      category: Category.work,
    ),
    Expense(
      title: 'New Cart',
      amount: 100.99,
      date: DateTime.now(),
      category: Category.food,
    ),
  ];
  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      // REMOVED 'const' and added the required function pointer below
      builder: (ctx) => NewExpenses(onAddExpense: _addExpense),
    );
  }

  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
    });
  }

  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.remove(expense);
    });
    // ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${expense.title}" deleted!'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // FIXED: Instantly strips the snackbar away if they hit Undo
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            // Instantly wipe the snackbar away when they tap Undo
            // ScaffoldMessenger.of(context).hideCurrentSnackBar();
            setState(() {
              // _registeredExpenses.insert(0, expense);
              _registeredExpenses.insert(expenseIndex, expense);
            });
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
