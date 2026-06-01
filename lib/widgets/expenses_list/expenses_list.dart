import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expenses_list/expense_item.dart';
import 'package:flutter/material.dart';

// 📝 NOTE / HINTS:
// 1) CONSTRUCTOR & CALLBACK FUNCTION RECEIVERS:
// What it does: This is the data entry setup for your scrolling list engine.
// - 'expenses' receives your live database array data list of transactions.
// - 'onRemoveExpense' receives the database function link to run an SQL DELETE.
// - 'onEditExpense' receives the overlay form launcher function to handle updates.
class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onRemoveExpense,
    required this.onEditExpense,
  });
  final List<Expense> expenses; // = const [];
  final void Function(Expense expense)
  onRemoveExpense; // 2. Declare the function variable
  final void Function({Expense? expense}) onEditExpense; // 👈 2. Define it

  @override
  Widget build(BuildContext context) {
    // 📝 NOTE / HINTS:
    // 2) HIGH-PERFORMANCE MEMORY SCROLL ENGINE (LISTVIEW.BUILDER):
    // What it does: This is a smart scrolling list manager. Instead of loading 100 items
    // all at once and freezing your phone's memory, 'ListView.builder' only builds and paints
    // the specific cards that are actively sliding onto the visible screen viewport frame!
    // - 'itemCount' tells the engine exactly how many loops it needs to perform.
    // - 'index' tells it exactly which specific record index row to pull out of the array map.
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (ctx, index) {
        // ctx => context object => current context
        final currentExpense = expenses[index]; // Get the current expense

        // Inside your expenses_list.dart file:
        // ==============================================================
        // Step 4: Link the Click Event to your Cards inside the ListView
        // =============================================================
        // 📝 NOTE / HINTS:
        // 3) Swipe-to-Delete Gesture Layer (Dismissible):
        // What it does: This wraps each individual card row row with a swipe movement gesture detector.
        // - 'key: ValueKey(currentExpense.id)' assigns a permanent tracking identity label so Flutter doesn't mix up rows during list animations.
        // - 'background: Container' paints a modern red layout box with a white trash can icon that slides into view behind the card row when you swipe your finger left or right.
        // - 'onDismissed' catches the end of your swipe animation and triggers your removal code.
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

          // 📝 NOTE / HINTS:
          // 4) EDIT OVERLAY TOUCH TRIGGER (GESTUREDETECTOR):
          // What it does: This is an invisible touch detection wrapper layer.
          // - It intercepts standard single finger tap clicks anywhere inside the row bounding borders.
          // - 'onTap: ()' executes 'onEditExpense(expense: currentExpense)', which immediately opens your
          //   bottom overlay form sheet, pre-filling it with this specific item's database details for editing!
          child: GestureDetector(
            onTap: () {
              onEditExpense(
                expense: currentExpense,
              ); // Opens editing modal form sheet
            },

            // FIXED: Pass the removal function pointer into the individual card widget here
            // 📝 NOTE / HINTS:
            // 5) VISUAL CARD RENDERER CHILD (EXPENSEITEM):
            // What it does: This is the final target child widget block. It loads your individual visual card blueprint layout file.
            // - It passes down the 'currentExpense' record data and your 'onRemoveExpense' function pointer to wire up the small red delete trash button inside the card row.
            child: ExpenseItem(currentExpense, onDelete: onRemoveExpense),
          ),
        );
      },
      // ExpenseItem(expenses[index]), // => syntex is return
    );
  }
}
