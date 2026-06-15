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
    return ref.watch(transactionRepositoryProvider).getAll();
  }

  Future<void> _reload() async {
    final repo = ref.read(transactionRepositoryProvider);
    state = await AsyncValue.guard(repo.getAll);
  }

  Future<void> add(ExpenseTransaction transaction) async {
    await ref.read(transactionRepositoryProvider).add(transaction);
    await _reload();
  }

  Future<void> edit(ExpenseTransaction transaction) async {
    await ref.read(transactionRepositoryProvider).update(transaction);
    await _reload();
  }

  Future<void> delete(String id) async {
    await ref.read(transactionRepositoryProvider).delete(id);
    await _reload();
  }

  Future<void> deleteAll() async {
    await ref.read(transactionRepositoryProvider).deleteAll();
    await _reload();
  }
}

final transactionsControllerProvider =
    AsyncNotifierProvider<TransactionsController, List<ExpenseTransaction>>(
  TransactionsController.new,
);
