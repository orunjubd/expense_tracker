import 'package:flutter/material.dart';

class ChartBar extends StatelessWidget {
  const ChartBar({super.key, required this.fill});

  final double fill; // A value between 0.0 (empty) and 1.0 (100% full)

  @override
  Widget build(BuildContext context) {
    // Check if dark mode is active to toggle bar colors smoothly
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FractionallySizedBox(
          heightFactor:
              fill, // Sets bar height dynamically based on calculation
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
