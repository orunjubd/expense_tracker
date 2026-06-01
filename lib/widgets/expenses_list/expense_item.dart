import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:intl/intl.dart';

// 📝 NOTE / HINTS:
// 1) VISUAL CATEGORY ICON MAPPING DICTIONARY (MAP):
// What it does: This is a matching dictionary that pairs each strict Category enum
// with its corresponding graphic icon vector (like pairing Category.food to a burger icon).
// How it connects: It lets the card render the correct icon automatically depending
// on what type of item is stored inside the database row.
// Create a map to link your Category enum choices to beautiful Material Icons
const categoryIcons = {
  Category.food: Icons.lunch_dining,
  Category.leisure: Icons.movie,
  Category.travel: Icons.flight_takeoff,
  Category.work: Icons.work,
};

// 📝 NOTE / HINTS:
// 2) CONSTRUCTOR AND REMOVAL FUNCTION RECEIVER PARAMETERS:
// What it does: This is the entryway data receiver for your single visual transaction card.
// - 'expense' takes a single object package containing your Title, Amount, Date, and Category data.
// - 'onDelete' is a pointer function bridge that links clicking the card's trash icon back to the deletion engine.
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
              // 📝 NOTE / HINTS:
              // 3) TEXT METADATA COLUMN (LEFT SIDE LAYOUT):
              // What it does: This builds the left side section of your item card using a vertical Column.
              // - The first 'Text' uses 'Theme.of(context)' to fetch your global title style for the item name.
              // - The second 'Text' converts your raw amount number into a string locked to exactly 2 decimal places (e.g. $19.99).
              // - 'onSurfaceVariant' tints the currency string to a muted professional grey text color.
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

            // 📝 NOTE / HINTS:
            // 4) ELASTIC SPACING BLOCK (SPACER):
            // What it does: This widget acts like an invisible spring. It expanding-fills all the empty
            // whitespace in the middle of your Row card layout box.
            // How it connects: It forces your text details onto the far-left edge while completely pushing
            // your dates and action buttons onto the clean far-right edge of the device viewport screen.
            const Spacer(), // Pushes the date and delete actions to the far right
            // 📝 NOTE / HINTS:
            // 5) CATEGORY, DATE, AND BUTTON ALIGNMENT (RIGHT SIDE LAYOUT):
            // What it does: This arranges all of your data metadata and action items horizontally on the right side.
            // - 'Icon' looks up your dictionary map to fetch your matching visual vector symbol.
            // - 'dateFormatter.format()' translates your raw, hidden database date stamp into a clean text string (e.g. 27/05/2026).
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

                // 📝 NOTE / HINTS:
                // 6) PRECISE TRASH ICON ACTION BUTTON CONTAINER:
                // What it does: This is your explicit visual delete button container widget.
                // - It renders a modern, thin red outline trash can symbol ('Icons.delete_outline').
                // - Tapping it runs 'onDelete(expense)', passing execution back to your stateful hub in 'expenses.dart'
                //   to instantly wipe this specific row entry off the device's SQL storage chip.
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
