// =========================================================
// NEW EXPENSES OVERLAY -( temporary popup modal sheet (overlay) )
// =========================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/expense.dart';
//import 'package:flutter/foundation.dart' hide Category;

// 📝 NOTE / HINTS:
// 1) CONSTRUCTOR AND DUAL-PURPOSE MODE SWITCH PARAMETERS:
// What it does: This is the entryway data setup for your input worksheet.
// - 'onAddExpense' is the function pointer that carries validated forms back to the database engine.
// - 'expenseToEdit' is an optional constructor slot. If it is null, the sheet runs in "Create New Mode".
//   If it holds data, the sheet instantly runs in "Update/Edit Mode".
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
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  //final formatter = DateFormat('dd-MM-yyyy  HH:mm:ss');
  final formatter = DateFormat('dd-MM-yyyy');
  DateTime? _selectedDate;

  // 1. FIXED: Define the state variable to track the selected category
  Category _selectedCategory = Category.food;

  // 📝 NOTE / HINTS:
  //2) PRE-FILL INITIALIZATION ENGINE (INITSTATE)
  // What it does: This is your form's pre-fill automation hub.
  // - When 'expenseToEdit' is detected, it intercepts form load, grabs the saved values straight out
  //   of your SQLite row model, and inserts them into your input variables (`_titleController.text`, etc.).
  // How it connects: Populates your inputs automatically so the user doesn't re-type old data when editing a date or price!
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

  // 📝 NOTE / HINTS:
  // 3) NATIVE CALENDAR DATE PICKER SHEET LAUNCH (_PRESENTDATEPICKER):
  // What it does: This triggers Flutter's native mobile overlay calendar display screen.
  // - 'async/await' is used to halt processing and calmly wait for the user to touch a day grid item.
  // - 'firstDate' and 'lastDate' set safety boundary constraints so users cannot pick weird futures or long-past years.
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
  // 📝 NOTE / HINTS:
  // 4) INPUT WATCHDOG VALIDATION & STRING CAPITALIZER (_SUBMITEXPENSEDATA):
  // What it does: This is your form validation firewall security checkpoint.
  // - 'double.tryParse()' converts user typed numbers safely and flags an alert dialog if inputs are letters or blank.
  // - 'capitalizedTitle' performs a premium string manipulation step: it splits your string, turns index character [0]
  //   into a Capital, and joins it back together (e.g. automatically converting 'taxi ride' into 'Taxi ride').
  // - If updating, it keeps the item's original unique ID; if brand new, it passes null to let the model generate a new UUID.
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

  // 📝 NOTE / HINTS:
  // 5) MEMORY DISPOSER (DISPOSE)
  // What it does: This is an important garbage collection memory cleaner.
  // - It forcefully destroys your 'TextEditingController' listening threads when the overlay slides down.
  // How it connects: Prevents background text listeners from leaking system tracking data and lagging your phone processor!
  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // 📝 NOTE / HINTS:
  // 6) RESPONSIVE KEYBOARD INSET CUSHIONING WRAPPER:
  // What it does: This handles advanced mobile keyboard layout protection math.
  // - 'MediaQuery.of(context).viewInsets.bottom' queries the device pixel grid to measure exactly how high
  //   the phone's digital keyboard is sticking up.
  // - 'SingleChildScrollView' uses this height value to pad the bottom of the container, shifting form inputs
  //   upwards so the typing keyboard never blocks the text fields or triggers yellow layout overflow stripe crashes!
  @override
  Widget build(context) {
    // Captures the exact height taken up by the smartphone software keyboard
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    // 2. Wrap everything inside a LayoutBuilder to look at modal size rules!
    return LayoutBuilder(
      builder: (ctx, constraints) {
        // Check if the container box has enough width to fit items side-by-side
        final isLandscapeMode = constraints.maxWidth >= 600;
        return SizedBox(
          height: double
              .infinity, // Tells the modal to respect full screen boundaries
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
                  // ==========================================================
                  // ROW 1: TITLE & AMOUNT FIELDS SWITCHER TRACK
                  // ==========================================================
                  if (isLandscapeMode)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _titleController,
                            maxLength: 50,
                            decoration: const InputDecoration(
                              label: Text('Title'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              prefixText: '\$ ',
                              label: Text('Amount'),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          maxLength: 50,
                          decoration: const InputDecoration(
                            label: Text('Title'),
                          ),
                        ),
                      ],
                    ),
                  // ==========================================================
                  // ROW 2: AMOUNT, DATE & DROPDOWN ACCORDION SELECTION FIELDS
                  // ==========================================================
                  Row(
                    children: [
                      // If portrait, Amount field sits down here under Title
                      if (!isLandscapeMode)
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ), // Allows decimal numbers
                            // 📝 NOTE / HINTS:
                            // 7) PRECISE KEYBOARD REGEX FILTER ROW:
                            // What it does: This is an extra text validation layer operating inside your price input row.
                            // - 'FilteringTextInputFormatter.allow()' uses a strict regular expression mask layer (`RegExp(r'^\d*\.?\d*')`)
                            //   to block users from ever typing commas, minus signs, or text letters into your database number fields at the keyboard level.
                            inputFormatters: [
                              // This blocks minus signs and text characters completely at the keyboard level
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              prefixText:
                                  '\$ ', // Adds a dollar sign format prefix
                              label: Text('Amount'),
                            ),
                          ),
                        ),
                      // In landscape, Category dropdown pulls right next to your dates safely!
                      if (isLandscapeMode)
                        DropdownButton<Category>(
                          value: _selectedCategory,
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
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedCategory = value);
                          },
                        ),

                      const Spacer(),
                      // 📝 NOTE / HINTS:
                      // 5) DATE PICKER ROW:
                      // What it does: This builds a date picker row at the end of your transaction form.
                      Row(
                        //mainAxisAlignment: MainAxisAlignment.end,
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
                    ],
                  ),

                  // 1. Standard spacing between inputs and the submit actions
                  const SizedBox(height: 16),
                  // ==========================================================
                  // ROW 3: LOWER SYSTEM SUBMISSION ACTION BUTTONS TRACK
                  // ==========================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .end, // Aligns buttons beautifully to the right
                    children: [
                      // 📝 NOTE / HINTS:
                      // 8) ENUM VALUES DYNAMIC DROPDOWN MAPPER:
                      // What it does: This converts your rigid, coded category enum properties into a visual on-screen select option list.
                      // - It loops through 'Category.values' and map-transforms each attribute item straight into a 'DropdownMenuItem' text block,
                      //   automatically capitalizing the string name for a professional visual appearance.
                      // Let the dropdown take up half the row dynamically
                      // In portrait mode, Category dropdown sits down here right next to cancel
                      if (!isLandscapeMode)
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
      },
    );
  }
}
