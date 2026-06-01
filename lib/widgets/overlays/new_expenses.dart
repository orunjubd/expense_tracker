// =========================================================
// NEW EXPENSES OVERLAY -( temporary popup modal sheet (overlay) )
// =========================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/expense.dart';
//import 'package:flutter/foundation.dart' hide Category;

class NewExpenses extends StatefulWidget {
  const NewExpenses({
    required this.onAddExpense,
    this.expenseToEdit, // ADD THIS OPTIONAL PARAMETER
    super.key,
  });

  final void Function(Expense expense) onAddExpense;
  final Expense? expenseToEdit; // Holds the transaction record being modified

  @override
  State<NewExpenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<NewExpenses> {
  // var _enteredTitle = '';
  // void _saveTitleInput(String inputValue) {
  //   _enteredTitle = inputValue;
  // }

  //  ============= alternate way ================
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  //final formatter = DateFormat('dd-MM-yyyy  HH:mm:ss');
  final formatter = DateFormat('dd-MM-yyyy');
  DateTime? _selectedDate;

  // 1. FIXED: Define the state variable to track the selected category
  Category _selectedCategory = Category.food;

  @override
  void initState() {
    super.initState();
    // If we are editing, pre-fill all form parameters with the saved database row values!
    if (widget.expenseToEdit != null) {
      _titleController.text = widget.expenseToEdit!.title;
      _amountController.text = widget.expenseToEdit!.amount.toString();
      _selectedDate = widget.expenseToEdit!.date;
      _selectedCategory = widget.expenseToEdit!.category;
    }
  }

  void _presentDatePicker() async {
    // async because it returns a future
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      // await because it returns a future
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  // ==========================================================================
  // Update your validation submit logic to branch between creating and updating:
  // ==========================================================================
  void _submitExpenseData() {
    final enteredAmount = double.tryParse(
      _amountController.text,
    ); // tryParse('Hello') => null, tryParse('1.12') => 1.12
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;
    if (_titleController.text.trim().isEmpty ||
        amountIsInvalid ||
        _selectedDate == null) {
      // showSnack(context);
      //return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid input'),
          content: const Text(
            'Please make sure a valid title, amount, date and category was entered.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    } else {
      // 1. Get the raw text string entered by the user
      final rawTitle = _titleController.text.trim();
      // 2. Format it: Capital letter [0] + the rest of the text from index [1]
      final capitalizedTitle =
          rawTitle[0].toUpperCase() + rawTitle.substring(1);

      widget.onAddExpense(
        Expense(
          id: widget.expenseToEdit?.id,
          title: capitalizedTitle,
          amount: enteredAmount,
          date: _selectedDate!,
          category: _selectedCategory,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    // Captures the exact height taken up by the smartphone software keyboard
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return SizedBox(
      height:
          double.infinity, // Tells the modal to respect full screen boundaries
      child: SingleChildScrollView(
        // Prevents layout crashes when keyboard opens
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            48,
            20,
            keyboardSpace + 20,
          ), // Dynamic spacing
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Title')),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ), // Allows decimal numbers
                      inputFormatters: [
                        // This blocks minus signs and text characters completely at the keyboard level
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        prefixText: '\$ ', // Adds a dollar sign format prefix
                        label: Text('Amount'),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _selectedDate == null
                              ? 'No date selected'
                              : formatter.format(_selectedDate!),
                          style: const TextStyle(fontSize: 13), //! null check
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month_outlined),
                          onPressed: _presentDatePicker,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 1. Standard spacing between inputs and the submit actions
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .end, // Aligns buttons beautifully to the right
                children: [
                  // Let the dropdown take up half the row dynamically
                  DropdownButton<Category>(
                    value:
                        _selectedCategory, // FIXED: Tell the dropdown what is selected
                    items: Category.values
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(
                              category.name[0].toUpperCase() +
                                  category.name.substring(1),
                            ),
                          ),
                        )
                        .toList(),
                    //),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedCategory =
                            value; // FIXED: Assign to declared state variable
                      });
                    },
                  ),
                  const Spacer(), // Pushes the action buttons cleanly to the right side
                  TextButton(
                    onPressed: () {
                      // This command instantly closes the bottom modal sheet or current page
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(
                    width: 8,
                  ), // Sta horizontal spacing between multiple buttons
                  ElevatedButton(
                    onPressed: _submitExpenseData,
                    //() {
                    //   // 1. Clean the text string input from the controller
                    //   final enteredText = _amountController.text;
                    //   // 2. Try to parse it, and if it fails (returns null), fallback to 0.00
                    //   final parsedAmount = double.tryParse(enteredText) ?? 0.00;
                    //   //print( 'Final safe amount: $parsedAmount',); // Will print 0.0 if input was "." or "-"
                    //   // 3. You can now read the chosen category here!
                    //   //print('Selected Category: $_selectedCategory');
                    //   // 4. Close the modal
                    //   Navigator.pop(context);
                    // },
                    child: Text(
                      widget.expenseToEdit == null
                          ? 'Save Expense'
                          : 'Update Changes',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
