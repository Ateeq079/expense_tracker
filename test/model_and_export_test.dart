import 'package:expensetracker/core/currency.dart';
import 'package:expensetracker/core/formatters.dart';
import 'package:expensetracker/data/models/expense_transaction.dart';
import 'package:expensetracker/data/models/transaction_type.dart';
import 'package:expensetracker/services/csv_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseTransaction', () {
    test('round-trips through toMap/fromMap', () {
      final tx = ExpenseTransaction(
        id: 'abc',
        title: 'Lunch',
        amount: 12.5,
        type: TransactionType.expense,
        categoryId: 'food',
        date: DateTime(2026, 6, 16, 13, 30),
        note: 'with team',
      );
      final restored = ExpenseTransaction.fromMap(tx.toMap());
      expect(restored, tx);
    });

    test('signedAmount is negative for expense, positive for income', () {
      final expense = ExpenseTransaction(
        id: '1',
        title: '',
        amount: 10,
        type: TransactionType.expense,
        categoryId: 'food',
        date: DateTime(2026),
      );
      final income = expense.copyWith(type: TransactionType.income);
      expect(expense.signedAmount, -10);
      expect(income.signedAmount, 10);
    });

    test('fromMap tolerates missing/legacy fields', () {
      final restored = ExpenseTransaction.fromMap({
        'id': 'x',
        'amount': 5,
        'type': 'expense',
        'category': 'unknown_cat',
        'date': 0,
      });
      expect(restored.title, '');
      expect(restored.categoryId, 'unknown_cat');
    });
  });

  group('MoneyFormatter', () {
    test('formats USD with two decimals', () {
      final f = MoneyFormatter(Currency.fromCode('USD'));
      expect(f.format(1234.5), '\$1,234.50');
    });

    test('JPY shows no decimal places', () {
      final f = MoneyFormatter(Currency.fromCode('JPY'));
      expect(f.format(1000), '¥1,000');
    });

    test('formatSigned prefixes sign', () {
      final f = MoneyFormatter(Currency.fromCode('USD'));
      expect(f.formatSigned(10), '+\$10.00');
      expect(f.formatSigned(-10), '-\$10.00');
    });
  });

  group('CsvExportService.buildCsv', () {
    test('includes header and one row per transaction', () {
      final csv = const CsvExportService().buildCsv([
        ExpenseTransaction(
          id: '1',
          title: 'Coffee',
          amount: 3.5,
          type: TransactionType.expense,
          categoryId: 'food',
          date: DateTime(2026, 6, 16, 9, 0),
        ),
      ]);
      expect(csv, contains('Date'));
      expect(csv, contains('Coffee'));
      expect(csv, contains('Food & Dining'));
      expect(csv, contains('3.50'));
      // header + 1 data row
      expect(csv.trim().split('\n').length, 2);
    });
  });
}
