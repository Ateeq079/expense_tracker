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
  static const int _dbVersion = 1;

  static const String tableTransactions = 'transactions';

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
      CREATE TABLE $tableTransactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date INTEGER NOT NULL,
        note TEXT
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_transactions_date ON $tableTransactions(date)',
    );
  }

  /// Migration hook. As the schema evolves, branch on [oldVersion] here and
  /// keep [_dbVersion] in sync. Kept intentionally empty at v1.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
