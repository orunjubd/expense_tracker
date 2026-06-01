import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

// 📝 NOTE / HINTS:
// 1) GLOBAL UTILITIES (DATE FORMATTER & UNIQUE ID GENERATOR):
// What it does: These are background tools that help format data strings.
// - 'formatter': Converts a complex, messy system timestamp (like 2026-06-01 15:43:00) into a clean, human-readable date format (like 6/1/2026).
// - 'uuid': A random digit generator used to stamp entries with an absolute unique ID so they don't get mixed up.
// How it connects: Used right below inside the Expense model class to style dates and tag transactions.
// final DateFormat formatter = DateFormat('yyyy-MM-dd');
final formatter = DateFormat.yMd();
const uuid = Uuid();

// 📝 NOTE / HINTS:
// 2) STRICT CATEGORY ENUMERATION (ENUM):
// What it does: This defines a rigid, closed list of categories allowed in your tracker app.
// It prevents spelling typos (like writing 'Food' on one screen and 'food' on another) by locking down the choices.
// How it connects:
// - 'database_helper.dart' saves these options as TEXT words (like 'travel').
// - 'new_expenses.dart' loops through these values to build your input form selection items.
enum Category { food, leisure, travel, work }

// 📝 NOTE / HINTS:
// 3) CATEGORY ICON MAPPING DICTIONARY (MAP):
// What it does: This is a mapping lookup dictionary. It automatically links each item from
// your strict Category list directly to a beautiful visual Material Design icon graphic vector.
// How it connects: 'expense_item.dart' reads this map to render a custom icon (like a suitcase for work or film for leisure) on the transaction row cards.
const categoryIcons = {
  Category.food: Icons.lunch_dining,
  Category.leisure: Icons.movie,
  Category.travel: Icons.flight_takeoff,
  Category.work: Icons.work,
};

// 📝 NOTE / HINTS:
// 4) CORE DATA BLUEPRINT & CONSTRUCTOR RULES (CLASS):
// What it does: This is your pure structural blueprint class. It has no UI views or buttons.
// It defines the mandatory variables that make up an "Expense" card: a String ID, a String title, a double price, a DateTime timestamp, and a Category option.
// - The constructor 'Expense()' has a smart logic rule: If an existing ID is pulled out of your SQLite table, it locks onto it. If it's a new user item, it generates a fresh uuid string on the spot.
// How it connects: Every file in your project imports this class to pass around information safely without breaking data schemas.
class Expense {
  Expense({
    String? id, // 1. FIXED: Allow an optional custom ID string input parameter
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  }) : id =
           id ??
           uuid.v4(); // 2. FIXED: Keep the existing ID if it exists, otherwise generate a new one!

  // 📝 NOTE / HINTS:
  // 5) FORMATTED DATE STRING GETTER (PROPERTY):
  // What it does: This is a helper string function (a Getter). Instead of running formatting calculations on your UI screens, this property instantly extracts the raw, hidden date variable and returns a formatted text layout string.
  // How it connects: Your 'expense_item.dart' rows can just call 'expense.formattedDate' to display clean time stamps on the screen cards seamlessly.
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  String get formattedDate {
    return formatter.format(date);
  }
}
