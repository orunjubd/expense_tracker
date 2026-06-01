import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

// final DateFormat formatter = DateFormat('yyyy-MM-dd');
final formatter = DateFormat.yMd();

const uuid = Uuid();

enum Category { food, leisure, travel, work }

const categoryIcons = {
  Category.food: Icons.lunch_dining,
  Category.leisure: Icons.movie,
  Category.travel: Icons.flight_takeoff,
  Category.work: Icons.work,
};

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

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  String get formattedDate {
    return formatter.format(date);
  }
}
