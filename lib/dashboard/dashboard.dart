import 'package:expense_tracker/dashboard/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_tracker/widgets/expenses.dart';
import 'package:expense_tracker/models/expense.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({
    super.key,
    this.onChangeTheme,
    this.currentThemeMode = ThemeMode.light,
    required this.expenses,
    required this.onRefresh,
  });

  final void Function(ThemeMode themeMode)? onChangeTheme;
  final ThemeMode currentThemeMode;
  final List<Expense> expenses;
  final VoidCallback onRefresh;

  // MATH UTILITY: Calculate total amount spent inside the tracker app
  double get _totalSpending {
    double total = 0.0;
    for (final exp in expenses) {
      total += exp.amount;
    }
    return total;
  }

  // 📝 NOTE / HINTS:
  // CATEGORY SPENDING SUM CALCULATOR:
  // What it does: This is a math filter function. It loops through your entire database
  // list array and adds up the prices of items that match ONE specific category choice
  // (like summing up ONLY Food receipts).
  // How it connects: The Pie Chart calls this function 4 times (once for Work, Food, Leisure,
  // and Travel) to calculate how big each colored slice should be dynamically.
  // CATEGORY UTILITY: Sums up expenditures specifically for an individual category selection
  double _getCategorySum(Category category) {
    double sum = 0.0;
    for (final exp in expenses) {
      if (exp.category == category) {
        sum += exp.amount;
      }
    }
    return sum;
  }

  // ===============================================
  // 📝 NOTE / HINTS:
  // MAIN VISUAL SCREEN BUILD TREE:
  // What it does: This is the master layout blueprint of the Dashboard page. Every widget
  // you see on the phone screen (the title headers, greeting texts, cards, and list builders)
  // is nested right inside this single root function framework.
  // How it connects: Flutter automatically calls this method on startup. It pulls your global
  // design styles using 'Theme.of(context)' to draw the purple AppBar top bar and background scaffold.
  //  Copy the Bottom Section (Visual Screen Build Tree)
  // This contains your main screen structure layouts, the calculated live pie chart
  // and the math slices loop, and button helper cards
  // ===============================================
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Calculate dynamic stats for your overview summary text blocks
    final totalBalanceText =
        '\$${(5000.0 - _totalSpending).toStringAsFixed(2)}';
    final monthlySpendingText = '\$${_totalSpending.toStringAsFixed(2)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: onRefresh),
        ],
      ),
      drawer: MainDrawer(
        onChangeTheme: onChangeTheme ?? (mode) {},
        currentThemeMode: currentThemeMode,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Track your financial flow here cleanly.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Overview Cards Row Grid displaying LIVE math metrics
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Balance',
                      totalBalanceText,
                      Icons.account_balance_wallet,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'This Month',
                      monthlySpendingText,
                      Icons.trending_down,
                      Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Live BuildBody execution call passes real-time values onto screen!
              buildBody(context),

              const SizedBox(height: 30),

              // Quick Actions Routing Panel
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Expenses()),
                    );
                    onRefresh(); // Recalculate values automatically upon return transition!
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manage Expenses',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Text('View list, graphs, and add receipts'),
                          ],
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final tertiaryColor = Theme.of(context).colorScheme.tertiary;
    final errorColor = Theme.of(context).colorScheme.error;

    final workSum = _getCategorySum(Category.work);
    final foodSum = _getCategorySum(Category.food);
    final leisureSum = _getCategorySum(Category.leisure);
    final travelSum = _getCategorySum(Category.travel);

    final total = _totalSpending;

    final workPercent = total == 0 ? 25.0 : (workSum / total) * 100;
    final foodPercent = total == 0 ? 25.0 : (foodSum / total) * 100;
    final leisurePercent = total == 0 ? 25.0 : (leisureSum / total) * 100;
    final travelPercent = total == 0 ? 25.0 : (travelSum / total) * 100;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Breakdown',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 140,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: primaryColor,
                      value: workPercent,
                      title: '${workPercent.toStringAsFixed(0)}%',
                      radius: 25,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    PieChartSectionData(
                      color: secondaryColor,
                      value: foodPercent,
                      title: '${foodPercent.toStringAsFixed(0)}%',
                      radius: 25,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    PieChartSectionData(
                      color: tertiaryColor,
                      value: leisurePercent,
                      title: '${leisurePercent.toStringAsFixed(0)}%',
                      radius: 25,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    PieChartSectionData(
                      color: errorColor,
                      value: travelPercent,
                      title: '${travelPercent.toStringAsFixed(0)}%',
                      radius: 25,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Work', primaryColor),
                _buildLegendItem('Food', secondaryColor),
                _buildLegendItem('Leisure', tertiaryColor),
                _buildLegendItem('Travel', errorColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 📝 NOTE / HINTS:
  // CHART LEGEND LABEL GENERATOR:
  // What it does: This is a small, reusable visual layout template tool. Instead of repeating
  // messy row code 4 separate times for your legend labels, this widget builds a neat indicator
  // row containing a tiny colored circle dot right next to a text label string (e.g., a green dot next to 'Food').
  // How it connects: It sits inside the bottom row of your Pie Chart breakdown box card layout.
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // 📝 NOTE / HINTS:
  // FINANCIAL STATISTIC TILE CARD BUILDER:
  // What it does: This is a reusable design layout engine for your upper balance summaries.
  // It builds a single rectangular information tile card containing a custom Material icon vector,
  // a grey sub-label tracking text, and a bold dynamic monetary string value block.
  // How it connects: It is called twice inside a horizontal Row layout near the top of the screen:
  // once to build your 'Total Balance' green tile card, and once to build your 'This Month' red spending tile card.

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
} // End of file class container
