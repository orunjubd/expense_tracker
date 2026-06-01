import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:expense_tracker/models/expense.dart'; // Make sure your path matches!

class DatabaseHelper {
  // 1. Singleton pattern: Ensures our app only uses ONE open database channel to save memory
  static final DatabaseHelper instance = DatabaseHelper._init();
  static sql.Database? _database;

  DatabaseHelper._init();

  // 1. FIXED GETTER: Reverted to a unified getter that handles caching cleanly
  Future<sql.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db'); // Local database file name
    return _database!;
  }

  // 3. Locates a safe hardware storage path on the phone to place the database file
  Future<sql.Database> _initDB(String filePath) async {
    final dbPath = await sql.getDatabasesPath();
    final localStoragePath = path.join(dbPath, filePath);

    // Opens the database and triggers the creation code if it's the first time running the app
    return await sql.openDatabase(
      localStoragePath,
      version: 1,
      onCreate: _createDB,
    );
  }

  // 4. THE SQL CREATION SCRIPT (Runs only ONCE when the user installs the app)
  Future _createDB(sql.Database db, int version) async {
    // Standard SQL schema setup tracking fields that match your pure Expense data model
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL
      )
    ''');
  }

  // =====================================================================
  // THE CRUD METHODS (Create, Read, Delete)
  // =====================================================================

  // 1. CREATE (INSERT) - Saves a new expense item permanently to the SQL table
  Future<void> insertExpense(Expense expense) async {
    final db = await instance.database;

    // We convert the Expense data model into a raw Map (Key-Value) structure for SQL
    await db.insert(
      'expenses',
      {
        'id': expense.id,
        'title': expense.title,
        'amount': expense.amount,
        'date': expense.date
            .toIso8601String(), // Convert DateTime object to searchable TEXT string
        'category': expense
            .category
            .name, // Convert Enum option directly to TEXT string (e.g. 'food')
      },
      conflictAlgorithm: sql
          .ConflictAlgorithm
          .replace, // Overwrites if an ID match happens (Failsafe)
    );
  }

  // 2. READ (SELECT) - Pulls all saved entries out of the SQL table rows
  Future<List<Expense>> getExpenses() async {
    final db = await instance.database;

    // Run a query statement: SELECT * FROM expenses
    final List<Map<String, dynamic>> maps = await db.query('expenses');

    // Convert the raw database text rows back into usable Flutter Expense objects!
    return List.generate(maps.length, (index) {
      return Expense(
        // Note: If your Expense constructor generates its own ID using uuid,
        // we will update your model in the next step so it accepts the saved database ID!
        id:
            maps[index]['id']
                as String, // 3. FIXED: Tell the model to keep its permanent stored database row ID!
        title: maps[index]['title'] as String,
        amount: maps[index]['amount'] as double,
        date: DateTime.parse(
          maps[index]['date'] as String,
        ), // Parse text back to DateTime
        category: Category.values.firstWhere(
          (cat) =>
              cat.name ==
              maps[index]['category'], // Match text string back to our enum options
        ),
      );
    });
  }

  // 4. UPDATE - Overwrites an existing expense record row matching its strict unique ID
  Future<void> updateExpense(Expense expense) async {
    final db = await instance.database;

    await db.update(
      'expenses',
      {
        'title': expense.title,
        'amount': expense.amount,
        'date': expense.date.toIso8601String(),
        'category': expense.category.name,
      },
      where: 'id = ?',
      whereArgs: [expense.id], // Prevents SQL injection attacks
    );
  }

  // 5. DELETE (DELETE) - Wipes an item rows out of the device storage chip
  Future<void> deleteExpense(String id) async {
    final db = await instance.database;

    await db.delete(
      'expenses',
      where:
          'id = ?', // Using ? parameter binders prevents SQL injection attacks (Like PHP PDO!)
      whereArgs: [id],
    );
  }

  // =====================================================================
  // END OF THE CRUD METHODS (Create, Read, Delete)
  // =====================================================================

  // 5. Close Connection method (Good practice to avoid memory leak states)
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
