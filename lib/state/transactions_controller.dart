import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/expense_transaction.dart';
import 'providers.dart';

/// Loads and mutates the full transaction list, keeping the in-memory state in
/// sync with the database. Exposed as an [AsyncValue] so the UI can show
/// loading/error states cleanly.
class TransactionsController
    extends AsyncNotifier<List<ExpenseTransaction>> {
  @override
  Future<List<ExpenseTransaction>> build() {
    final bookId = ref.watch(activeBookIdProvider);
    return ref.watch(transactionRepositoryProvider).getAll(bookId);
  }

  Future<void> _reload() async {
    final bookId = ref.read(activeBookIdProvider);
    final repo = ref.read(transactionRepositoryProvider);
    state = await AsyncValue.guard(() => repo.getAll(bookId));
  }

  Future<void> add(ExpenseTransaction transaction) async {
    final bookId = ref.read(activeBookIdProvider);
    final t = transaction.copyWith(bookId: bookId);
    await ref.read(transactionRepositoryProvider).add(t);
    await _reload();
  }

  Future<void> edit(ExpenseTransaction transaction) async {
    // Note: transaction already has a bookId from its creation, 
    // but we can ensure it stays in the active book, or keep its original bookId.
    // We assume it's edited within the active book.
    await ref.read(transactionRepositoryProvider).update(transaction);
    await _reload();
  }

  Future<void> delete(String id) async {
    await ref.read(transactionRepositoryProvider).delete(id);
    await _reload();
  }

  Future<void> deleteAll() async {
    final bookId = ref.read(activeBookIdProvider);
    await ref.read(transactionRepositoryProvider).deleteAll(bookId);
    await _reload();
  }
}

final transactionsControllerProvider =
    AsyncNotifierProvider<TransactionsController, List<ExpenseTransaction>>(
  TransactionsController.new,
);
