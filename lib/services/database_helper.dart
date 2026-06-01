import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:expense_tracker/models/expense.dart'; // Make sure your path matches!

// 📝 NOTE / HINTS:
// 1) IMPORTS AND CLASS FRAMEWORK BLUEPRINTS:
// What it does: This is the backend infrastructure controller of your application.
// It works exactly like a PHP PDO connection file or an Eloquent database manager.
// - 'sqflite' handles the local physical file storage database system engine.
// - 'path' locates exactly where your app's directory sits on the hardware chip.
// How it connects: It maps your visual 'Expense' data objects straight into raw SQL columns.
class DatabaseHelper {
  // 1. Singleton pattern: Ensures our app only uses ONE open database channel to save memory

  // 📝 NOTE / HINTS:
  // 2) SINGLETON CONTROLLER BLUEPRINT:
  // What it does: This implements a strict "Singleton pattern". It guarantees that
  // your computer only opens ONE database lane in memory, no matter how many screens call it.
  // How it connects: It prevents the phone's RAM from loading duplicate files and crashing.
  // Any screen can safely access the database simply by referencing 'DatabaseHelper.instance'.
  static final DatabaseHelper instance = DatabaseHelper._init();
  static sql.Database? _database;
  DatabaseHelper._init();

  // 📝 NOTE / HINTS:
  // 3) CONNECTION INITIALIZATION & VERIFICATION GETTER BLUEPRINT:
  // What it does: This is a smart guard function (a Getter). Before running any CRUD operations,
  // it checks if a database file link is already open. If open, it reuses it. If completely fresh,
  // it triggers the native channel filesystem engine to initialize a new file called 'expenses.db'.
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

  // 📝 NOTE / HINTS:
  // 4) SQL DATABASE SCHEMA DEFINITION SCRIPT BLUEPRINT:
  // What it does: This is your database blueprint migration script. It executes a single
  // raw SQL statement ('CREATE TABLE expenses...') ONLY ONCE when the user opens your application
  // for the first time after installation.
  // How it connects: It defines your strict table schema types matching your 'Expense' model:
  // - Strings save as 'TEXT', numbers save as fractional 'REAL' values, and dates/enums convert to strings.
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
  // 📝 NOTE / HINTS:
  // 5) CRUD PART 1: CREATE (INSERT OPERATION):
  // What it does: This is your database CREATE function. It saves user receipts permanently to storage.
  // - Because SQLite doesn't understand custom Flutter data types, this function converts your
  //   Expense object fields into a plain Key-Value structure (Map) with standardized text properties.
  // How it connects: Triggered by your overlay submission form views whenever a user adds a receipt card.
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
  // 📝 NOTE / HINTS:
  // 6) CRUD PART 2: READ (SELECT QUERY MAPPER):
  // What it does: This is your database READ function. It pulls everything out of your offline storage.
  // - It runs the raw query statement: 'SELECT * FROM expenses'.
  // - It takes the raw table string maps and translates them back into a clean list of Flutter Expense objects.
  // How it connects: Feeds data into your list views and overview charts when your dashboard boots up.
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
  // 📝 NOTE / HINTS:
  // 7) CRUD PART 3: UPDATE (RECORD MODIFICATION ENGINE)
  // What it does: This is your database UPDATE function. It lets users overwrite information.
  // - It target matches your data schema specifically on the unique 'id' tracking column.
  // - 'whereArgs: [expense.id]' acts like a safe PHP PDO parameter binder to stop injection attacks.
  // How it connects: Runs instantly whenever a user selects an item card tile and submits edited values.
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
  // 📝 NOTE / HINTS:
  // 8) CRUD Part 4: DELETE (File Eraser Pipeline):
  // What it does: This is your database DELETE function. It purges structural logs from your disk.
  // - It uses an explicit 'where: id = ?' statement layer to delete only the single matching row.
  // How it connects: Fired directly by your 'Dismissible' swipe gestures or by clicking your visual red trash can buttons.
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
  // 📝 NOTE / HINTS:
  // 9) CONNECTION CLOSER / MEMORY GUARDIAN:
  // What it does: This safely shuts down your database connection pipeline. It ensures that
  // if your app closes, data pipes aren't left leaking memory trackers in the background systems.
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
