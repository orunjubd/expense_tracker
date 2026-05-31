import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expenses_list/expense_item.dart';
import 'package:flutter/material.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onRemoveExpense,
  });

  final List<Expense> expenses; // = const [];
  final void Function(Expense expense)
  onRemoveExpense; // 2. Declare the function variable

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (ctx, index) {
        //
        final currentExpense = expenses[index]; //
        // Inside your expenses_list.dart file:
        return Dismissible(
          key: ValueKey(currentExpense.id),
          background: Container(
            color: Colors.red.withValues(alpha: 0.75),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            onRemoveExpense(currentExpense); // Handles the swipe deletion
          },
          // FIXED: Pass the removal function pointer into the individual card widget here
          child: ExpenseItem(currentExpense, onDelete: onRemoveExpense),
        );
      },
      // ExpenseItem(expenses[index]), // => syntex is return
    );
  }
}
