import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({
    super.key,
    required this.onChangeTheme,
    required this.currentThemeMode,
  });

  final void Function(ThemeMode themeMode) onChangeTheme;
  final ThemeMode currentThemeMode;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Side Menu Header Banner
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withAlpha(180),
                ],
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 40,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(width: 12),
                Text(
                  'TrackFlow UI',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Navigation Actions Option 1: Dashboard
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),

          // Appearance Configuration Header Label Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'THEME OPTIONS',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 1. Wrap the selections inside the modern RadioGroup widget
          RadioGroup<ThemeMode>(
            groupValue: currentThemeMode, // Centralized value controller
            onChanged: (value) {
              if (value != null) onChangeTheme(value);
            },
            // 2. Pass a layout container (like a Column) to hold your options cleanly
            child: Column(
              children: [
                // Light Mode Option
                RadioListTile<ThemeMode>(
                  title: const Row(
                    children: [
                      Icon(Icons.light_mode_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Light Mode'),
                    ],
                  ),
                  value: ThemeMode
                      .light, // NO individual groupValue or onChanged needed here anymore!
                ),

                // Dark Mode Option
                RadioListTile<ThemeMode>(
                  title: const Row(
                    children: [
                      Icon(Icons.dark_mode_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Dark Mode'),
                    ],
                  ),
                  value: ThemeMode.dark, // Clean and simple parameter matching
                ),
              ],
            ),
          ),

          const Spacer(), // Pushes the release stamp to the bottom floor
          const Divider(),

          // Version 1.1.0 Progress Stamp
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Version 1.1.0 (Development Dev Build)',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
