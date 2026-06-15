import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../models/expense_transaction.dart';

/// Data-access layer for transactions. All persistence goes through here so the
/// rest of the app never touches SQL directly.
class TransactionRepository {
  TransactionRepository({AppDatabase? database})
      : _appDatabase = database ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  /// All transactions, newest first.
  Future<List<ExpenseTransaction>> getAll() async {
    final db = await _db;
    final rows = await db.query(
      AppDatabase.tableTransactions,
      orderBy: 'date DESC',
    );
    return rows.map(ExpenseTransaction.fromMap).toList(growable: false);
  }

  Future<void> add(ExpenseTransaction transaction) async {
    final db = await _db;
    await db.insert(
      AppDatabase.tableTransactions,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(ExpenseTransaction transaction) async {
    final db = await _db;
    await db.update(
      AppDatabase.tableTransactions,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(
      AppDatabase.tableTransactions,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await _db;
    await db.delete(AppDatabase.tableTransactions);
  }
}
