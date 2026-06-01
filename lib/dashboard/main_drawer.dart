import 'package:flutter/material.dart';

// 📝 NOTE / HINTS:
// 1) CONSTRUCTOR AND PARAMETER BLUEPRINT:
// What it does: This is the data entryway for your sidebar. Because the drawer is a separate file,
// it requires these parameters to interact with the main application settings.
// - 'currentThemeMode' checks whether the app is currently in Light or Dark mode.
// - 'onChangeTheme' is a bridge function that passes the user's click choice back to main.dart.
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
    // 📝 NOTE / HINTS:
    // 2) DRAWER VISUAL CONTAINER AND HEADER BANNER:
    // What it does: This builds the sliding layout container block (Drawer) and its top colored banner.
    // - 'LinearGradient' blends your primary theme color smoothly down into a soft transparency overlay tint.
    // - The 'Icon' and 'Text' create your custom branding header ('TrackFlow UI') at the top.
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

          // 📝 NOTE / HINTS:
          // 3) NAVIGATION ROUTE LIST ITEMS:
          // What it does: This creates the clickable button items in your menu.
          // - 'ListTile' generates a row with a dashboard icon on the left (leading) and a clean text title.
          // - 'Navigator.pop(context)' is the click action handler (onTap). It simply slides the sidebar
          //   backward off the screen to reveal the main dashboard layout underneath.
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

          // 📝 NOTE / HINTS:
          // MODERN PARENT RADIO TOGGLER GROUP:
          // What it does: This is the centralized modern engine that coordinates your theme selection bubbles.
          // Instead of coding tracking logic into each button separately, this parent widget listens for any tap
          // inside its list, instantly runs the 'onChangeTheme' function, and updates the entire app interface colors globally.
          // 1. Wrap the selections inside the modern RadioGroup widget
          RadioGroup<ThemeMode>(
            groupValue: currentThemeMode, // Centralized value controller
            onChanged: (value) {
              if (value != null) onChangeTheme(value);
            },
            // 2. Pass a layout container (like a Column) to hold your options cleanly
            child: Column(
              children: [
                // 📝 NOTE / HINTS:
                // INDIVIDUAL RADIO LIST OPTION TILES:
                // What it does: These are the selectable light/dark option rows inside the theme group.
                // - Each 'RadioListTile' holds its own specific platform code settings value ('ThemeMode.light' or 'ThemeMode.dark').
                // - When selected, it communicates with the parent 'RadioGroup' to switch selection ring highlights smoothly.
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

          // 📝 NOTE / HINTS:
          // 6) LAYOUT SPACER AND BOTTOM VERSION STAMP:
          // What it does: This handles the lower layout styling of your sidebar menu.
          // - 'Spacer()' acts like an elastic spring. It takes up all the empty white space in the middle,
          //   forcefully pushing your app release designation stamp text to the absolute bottom floor of the phone viewport.
          // - The final 'Padding' prints a clean tracking string so your user always knows their current build version.
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
