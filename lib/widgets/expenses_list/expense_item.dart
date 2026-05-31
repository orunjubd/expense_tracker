import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:intl/intl.dart';

// Create a map to link your Category enum choices to beautiful Material Icons
const categoryIcons = {
  Category.food: Icons.lunch_dining,
  Category.leisure: Icons.movie,
  Category.travel: Icons.flight_takeoff,
  Category.work: Icons.work,
};

class ExpenseItem extends StatelessWidget {
  const ExpenseItem(
    this.expense, {
    super.key,
    required this.onDelete, // 1. Add this required parameter
  });

  final Expense expense;
  final void Function(Expense expense)
  onDelete; // 2. Define the function variable

  @override
  Widget build(BuildContext context) {
    // 2. Setup a standard visual date format utility (e.g., 27/05/2026)
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                // Formats to 2 decimal places (e.g., $19.99)
                Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Spacer(), // Pushes the date and delete actions to the far right

            Row(
              children: [
                // 3. Render the correct category icon dynamically from the map above
                Icon(categoryIcons[expense.category], color: Colors.grey[600]),
                const SizedBox(width: 8),

                // 4. FIXED: Output your formatted DateTime string safely here!
                Text(
                  dateFormatter.format(expense.date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(width: 8),

                // 5. The visible delete action button
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    onDelete(expense);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
