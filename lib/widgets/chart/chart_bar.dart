import 'package:flutter/material.dart';

// 📝 NOTE / HINTS:
// 1) CONSTRUCTOR AND PERCENTAGE PROPERTY PARAMETERS:
// What it does: This is the input parameter slot for a single vertical graph column.
// - 'fill' expects a decimal number variable between 0.0 (0% height) and 1.0 (100% max height).
// How it connects: 'chart.dart' runs budget math equations and passes this percentage value
// straight down to this constructor to set the vertical bar size dynamically.
class ChartBar extends StatelessWidget {
  const ChartBar({super.key, required this.fill});
  final double fill; // A value between 0.0 (empty) and 1.0 (100% full)

  @override
  Widget build(BuildContext context) {
    // 📝 NOTE / HINTS:
    // 2) AUTOMATIC DARK MODE SWITCH DETECTOR:
    // What it does: This is a system monitor lookup check. It queries the phone's hardware
    // operating system to instantly detect if the device is currently rendering in Light Mode or Dark Mode.
    // How it connects: It lets the bar graph change its colors instantly to fit whichever screen mode is active.
    // Check if dark mode is active to toggle bar colors smoothly
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    // 📝 NOTE / HINTS:
    // 3) PROPORTIONAL LAYOUT FLEX CONSTRAINT (EXPANDED):
    // What it does: This is an elastic flex layout container wrapper widget. It tells the vertical
    // bar to dynamically expand and stretch horizontally to fill up an equal share of the chart row.
    // How it connects: This guarantees that whether you have 2 categories or 4, all vertical bars stay
    // perfectly aligned across the width of the smartphone screen without overlapping.
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),

        // 📝 NOTE / HINTS:
        // 4) DYNAMIC SIZING BOX HANDLER (FRACTIONALLYSIZEDBOX):
        // What it does: This is the sizing engine of the bar chart. It takes the fractional decimal
        // 'fill' value parameter and instantly stretches its child widget height from the bottom up.
        // - If 'fill' is 0.50, this box will automatically occupy exactly 50% of the maximum chart block height.
        child: FractionallySizedBox(
          heightFactor:
              fill, // Sets bar height dynamically based on calculation
          // 📝 NOTE / HINTS:
          // 5) VISUAL STYLING & THEME COLOR PAINTER (DECORATEDBOX):
          // What it does: This paints the actual decorative shape block of the chart column row bars.
          // - 'BorderRadius.vertical(top: ...)' adds a premium, smooth rounded curve to the top tips of the bars.
          // - The color assigns your global secondary color choice if the app is in Dark Mode, or draws your
          //   primary brand color with a soft 65% opacity tint transparency layer if it is in Light Mode.
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              color: isDarkMode
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.65),
            ),
          ),
        ),
      ),
    );
  }
}
