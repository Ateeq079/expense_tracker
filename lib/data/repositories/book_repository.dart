import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../models/book.dart';

/// Data-access layer for books (ledgers).
class BookRepository {
  BookRepository({AppDatabase? database})
      : _appDatabase = database ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  /// All books, ordered by sortOrder then createdAt.
  Future<List<Book>> getAll() async {
    final db = await _db;
    final rows = await db.query(
      AppDatabase.tableBooks,
      orderBy: 'sort_order ASC, created_at ASC',
    );
    return rows.map(Book.fromMap).toList(growable: false);
  }

  Future<void> add(Book book) async {
    final db = await _db;
    await db.insert(
      AppDatabase.tableBooks,
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Book book) async {
    final db = await _db;
    await db.update(
      AppDatabase.tableBooks,
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db;
    // Note: Database should have foreign keys enabled. Deleting a book
    // will cascade and delete its transactions if we set it up, but
    // since we didn't specify ON DELETE CASCADE in the PRD, we should
    // delete its transactions manually here to be safe.
    await db.transaction((txn) async {
      await txn.delete(
        AppDatabase.tableTransactions,
        where: 'book_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        AppDatabase.tableBooks,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}
