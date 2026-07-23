import 'package:expensetracker/data/models/expense_transaction.dart';
import 'package:expensetracker/data/models/transaction_type.dart';
import 'package:expensetracker/state/analytics.dart';
import 'package:flutter_test/flutter_test.dart';

ExpenseTransaction _tx({
  required String id,
  required double amount,
  required TransactionType type,
  required String category,
  DateTime? date,
}) {
  return ExpenseTransaction(
    id: id,
    bookId: 'default_book_id',
    title: 't',
    amount: amount,
    type: type,
    categoryId: category,
    date: date ?? DateTime(2026, 6, 1),
  );
}

void main() {
  group('summarize', () {
    test('empty list yields zeroed summary', () {
      final s = summarize([]);
      expect(s.income, 0);
      expect(s.expense, 0);
      expect(s.balance, 0);
      expect(s.transactionCount, 0);
      expect(s.expenseByCategory, isEmpty);
    });

    test('aggregates income and expense totals and balance', () {
      final s = summarize([
        _tx(id: '1', amount: 1000, type: TransactionType.income, category: 'salary'),
        _tx(id: '2', amount: 200, type: TransactionType.expense, category: 'food'),
        _tx(id: '3', amount: 50, type: TransactionType.expense, category: 'food'),
        _tx(id: '4', amount: 100, type: TransactionType.expense, category: 'transport'),
      ]);
      expect(s.income, 1000);
      expect(s.expense, 350);
      expect(s.balance, 650);
      expect(s.transactionCount, 4);
    });

    test('groups by category, sorted by total descending', () {
      final s = summarize([
        _tx(id: '1', amount: 200, type: TransactionType.expense, category: 'food'),
        _tx(id: '2', amount: 50, type: TransactionType.expense, category: 'food'),
        _tx(id: '3', amount: 100, type: TransactionType.expense, category: 'transport'),
      ]);
      expect(s.expenseByCategory.length, 2);
      expect(s.expenseByCategory.first.category.id, 'food');
      expect(s.expenseByCategory.first.total, 250);
      expect(s.expenseByCategory.first.count, 2);
      // share is fraction of total expense (350).
      expect(s.expenseByCategory.first.share, closeTo(250 / 350, 1e-9));
    });

    test('income and expense categories are tracked separately', () {
      final s = summarize([
        _tx(id: '1', amount: 1000, type: TransactionType.income, category: 'salary'),
        _tx(id: '2', amount: 300, type: TransactionType.income, category: 'business'),
        _tx(id: '3', amount: 100, type: TransactionType.expense, category: 'food'),
      ]);
      expect(s.incomeByCategory.length, 2);
      expect(s.expenseByCategory.length, 1);
      expect(s.incomeByCategory.first.category.id, 'salary');
    });
  });

  group('StatsPeriod.contains', () {
    final now = DateTime(2026, 6, 16);

    test('thisMonth matches same month/year only', () {
      expect(StatsPeriod.thisMonth.contains(DateTime(2026, 6, 1), now), isTrue);
      expect(StatsPeriod.thisMonth.contains(DateTime(2026, 5, 31), now), isFalse);
      expect(StatsPeriod.thisMonth.contains(DateTime(2025, 6, 1), now), isFalse);
    });

    test('lastMonth handles year boundary', () {
      final jan = DateTime(2026, 1, 10);
      expect(StatsPeriod.lastMonth.contains(DateTime(2025, 12, 25), jan), isTrue);
      expect(StatsPeriod.lastMonth.contains(DateTime(2026, 1, 1), jan), isFalse);
    });

    test('thisYear matches any month of same year', () {
      expect(StatsPeriod.thisYear.contains(DateTime(2026, 1, 1), now), isTrue);
      expect(StatsPeriod.thisYear.contains(DateTime(2025, 12, 31), now), isFalse);
    });

    test('all always matches', () {
      expect(StatsPeriod.all.contains(DateTime(2000, 1, 1), now), isTrue);
    });
  });
}
