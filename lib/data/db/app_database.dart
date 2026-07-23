import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Owns the SQLite connection and schema migrations.
///
/// A single instance is shared app-wide via the repository. Opening is lazy and
/// idempotent.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _dbName = 'expense_tracker.db';
  static const int _dbVersion = 2;

  static const String tableTransactions = 'transactions';
  static const String tableBooks = 'books';

  Database? _db;

  Future<Database> get database async {
    return _db ??= await _open();
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableBooks (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        sort_order INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    
    // Insert a default book for new installations.
    await db.insert(tableBooks, {
      'id': 'default_book_id',
      'name': 'My Book',
      'sort_order': 0,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });

    await db.execute('''
      CREATE TABLE $tableTransactions (
        id TEXT PRIMARY KEY,
        book_id TEXT NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date INTEGER NOT NULL,
        note TEXT,
        FOREIGN KEY(book_id) REFERENCES $tableBooks(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_transactions_date ON $tableTransactions(date)',
    );
  }

  /// Migration hook. As the schema evolves, branch on [oldVersion] here and
  /// keep [_dbVersion] in sync.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 1. Create the books table
      await db.execute('''
        CREATE TABLE $tableBooks (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          sort_order INTEGER NOT NULL,
          created_at INTEGER NOT NULL
        )
      ''');
      
      // 2. Insert the default book
      await db.insert(tableBooks, {
        'id': 'default_book_id',
        'name': 'My Book',
        'sort_order': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      // 3. Add book_id column to transactions, with default value
      await db.execute(
        "ALTER TABLE $tableTransactions ADD COLUMN book_id TEXT NOT NULL DEFAULT 'default_book_id'",
      );
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
