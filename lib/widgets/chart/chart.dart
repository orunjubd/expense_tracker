import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/chart/chart_bar.dart';

// Assuming you have categoryIcons defined in expense_item.dart,
// we declare them here for chart display matching layout lines.
const chartCategoryIcons = {
  Category.food: Icons.lunch_dining,
  Category.leisure: Icons.movie,
  Category.travel: Icons.flight_takeoff,
  Category.work: Icons.work,
};

class Chart extends StatelessWidget {
  const Chart({super.key, required this.expenses});

  final List<Expense> expenses;

  // 1. A getter function that sums up total expenditures for each single category bucket option
  double get totalExpensesSum {
    double sum = 0.0;
    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    // Calculate category specific splits safely
    final Map<Category, double> categorySums = {
      Category.food: 0,
      Category.leisure: 0,
      Category.travel: 0,
      Category.work: 0,
    };

    for (final expense in expenses) {
      categorySums[expense.category] =
          (categorySums[expense.category] ?? 0) + expense.amount;
    }

    final overallMaxSum = totalExpensesSum == 0 ? 1.0 : totalExpensesSum;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      width: double.infinity,
      height: 180, // Balanced medium height for mobile viewports
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.3),
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // The Visual Bars Row
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: Category.values.map((category) {
                final currentCategorySum = categorySums[category] ?? 0.0;
                final fillRatio = totalExpensesSum == 0
                    ? 0.0
                    : currentCategorySum / overallMaxSum;
                return ChartBar(fill: fillRatio);
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // The Corresponding Icons Row at bottom baseline alignment
          Row(
            children: Category.values.map((category) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    chartCategoryIcons[category],
                    color: isDarkMode
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
