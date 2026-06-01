import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/chart/chart_bar.dart';

// 📝 NOTE / HINTS:
// 1) CATEGORY ICON MAPPING DICTIONARY (MAP):
// What it does: This is a visual icon lookup dictionary declared specifically for your bar chart.
// It automatically links each item from your strict Category list directly to a matching Material Design icon graphic vector.
// How it connects: It ensures the icons drawn at the absolute bottom baseline floor of the graph align perfectly with the category column bars sitting directly above them.
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

  // 📝 NOTE / HINTS:
  // 2) GLOBAL CALCULATOR GETTER (TOTAL SPENDING SUM):
  // What it does: This is a math utility property (a Getter). It loops through your entire active database list array
  // and adds up the prices of every single receipt entry to calculate your absolute total expenditure sum.
  // How it connects: Used lower down to calculate the mathematical ratios needed to stretch your vertical graph bars proportionally.
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

    // 📝 NOTE / HINTS:
    // 3) CATEGORY BUDGET BUCKET AGGREGATOR LOOP:
    // What it does: This is a data sorting loop. It initializes an empty map (a bucket) for your 4 category selections,
    // loops through your raw database items, and sums up the prices specifically per single category channel (e.g. tracking your total Food vs total Travel costs).
    // How it connects: Translates rows of raw list transactions into single grouped totals ready for chart display.
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

    // 📝 NOTE / HINTS:
    //  4) OUTER GRAPH BOX LAYOUT CONTAINER & GRADIENT TINTING:
    // What it does: This builds the main background display panel for your bar chart diagram.
    // - 'LinearGradient' blends your primary container theme tint from a transparent 30% opacity down into a soft 0% clear fadeout at the bottom.
    // - The rounded corners ('BorderRadius.circular(16)') make it fit modern dashboard screen styles.
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
          // 📝 NOTE / HINTS:
          // 5) Dynamic Bars Row Mapper Loop:
          // What it does: This is the visual engine of the chart dashboard. It loops through your strict 'Category.values' enum list,
          // grabs the spending sum for each category, divides it by the total overall sum to get a fractional percentage,
          // and map-loops it straight into an array of separate 'ChartBar' widgets aligned along the lower edge ('crossAxisAlignment: CrossAxisAlignment.end').
          // How it connects: Feeds the dynamic filling ratio parameters directly down into your individual column bar classes.
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

          // 📝 NOTE / HINTS:
          // 6) BASELINE GRAPHIC ICON ROW MAPPER LOOP:
          // What it does: This loops through your strict category enumeration items and prints their corresponding icon vector emblems
          // directly beneath each matching vertical chart bar column.
          // - It checks your 'isDarkMode' variable state to automatically paint soft teal colors at night or royal brand purples during the day.
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
