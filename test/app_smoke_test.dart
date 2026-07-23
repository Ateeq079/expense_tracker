import 'package:expensetracker/app.dart';
import 'package:expensetracker/data/models/expense_transaction.dart';
import 'package:expensetracker/data/models/transaction_type.dart';
import 'package:expensetracker/data/repositories/transaction_repository.dart';
import 'package:expensetracker/features/add_edit/add_edit_transaction_screen.dart';
import 'package:expensetracker/state/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory stand-in so widget tests never touch the real SQLite database.
class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository([List<ExpenseTransaction>? seed])
      : _items = [...?seed];

  final List<ExpenseTransaction> _items;

  @override
  Future<List<ExpenseTransaction>> getAll(String bookId) async {
    final filtered = _items.where((t) => t.bookId == bookId).toList();
    final sorted = [...filtered]..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  @override
  Future<void> add(ExpenseTransaction transaction) async {
    _items.add(transaction);
  }

  @override
  Future<void> update(ExpenseTransaction transaction) async {
    final i = _items.indexWhere((t) => t.id == transaction.id);
    if (i >= 0) _items[i] = transaction;
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((t) => t.id == id);
  }

  @override
  Future<void> deleteAll(String bookId) async {
    _items.removeWhere((t) => t.bookId == bookId);
  }
}

Future<ProviderScope> _bootable(List<ExpenseTransaction> seed) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      transactionRepositoryProvider
          .overrideWithValue(FakeTransactionRepository(seed)),
    ],
    child: const ExpenseTrackerApp(),
  );
}

void main() {
  testWidgets('boots to dashboard and shows empty state', (tester) async {
    await tester.pumpWidget(await _bootable([]));
    await tester.pumpAndSettle();

    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.text('No transactions yet'), findsOneWidget);
    // Bottom navigation present.
    expect(find.text('Stats'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('renders seeded transactions and balance', (tester) async {
    final seed = [
      ExpenseTransaction(
        id: '1',
        bookId: 'default_book_id',
        title: 'Paycheck',
        amount: 2000,
        type: TransactionType.income,
        categoryId: 'salary',
        date: DateTime.now(),
      ),
      ExpenseTransaction(
        id: '2',
        bookId: 'default_book_id',
        title: 'Groceries run',
        amount: 75,
        type: TransactionType.expense,
        categoryId: 'groceries',
        date: DateTime.now(),
      ),
    ];
    await tester.pumpWidget(await _bootable(seed));
    await tester.pumpAndSettle();

    expect(find.text('Paycheck'), findsOneWidget);
    expect(find.text('Groceries run'), findsOneWidget);
  });

  testWidgets('add button opens the add transaction form', (tester) async {
    await tester.pumpWidget(await _bootable([]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.byType(AddEditTransactionScreen), findsOneWidget);
    expect(find.text('Add Transaction'), findsOneWidget);
  });
}
