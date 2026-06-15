import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/category.dart';
import '../data/models/expense_transaction.dart';
import '../data/models/transaction_type.dart';
import 'transactions_controller.dart';

/// Time window used to scope the dashboard and stats.
enum StatsPeriod {
  thisMonth('This Month'),
  lastMonth('Last Month'),
  thisYear('This Year'),
  all('All Time');

  const StatsPeriod(this.label);
  final String label;

  /// Returns true if [date] falls inside this period, relative to [now].
  bool contains(DateTime date, DateTime now) {
    switch (this) {
      case StatsPeriod.thisMonth:
        return date.year == now.year && date.month == now.month;
      case StatsPeriod.lastMonth:
        final lm = DateTime(now.year, now.month - 1);
        return date.year == lm.year && date.month == lm.month;
      case StatsPeriod.thisYear:
        return date.year == now.year;
      case StatsPeriod.all:
        return true;
    }
  }
}

/// Holds the period the user is currently viewing.
class SelectedPeriodController extends Notifier<StatsPeriod> {
  @override
  StatsPeriod build() => StatsPeriod.thisMonth;

  void set(StatsPeriod period) => state = period;
}

final selectedPeriodProvider =
    NotifierProvider<SelectedPeriodController, StatsPeriod>(
  SelectedPeriodController.new,
);

/// Per-category aggregation within a period.
@immutable
class CategorySummary {
  const CategorySummary({
    required this.category,
    required this.total,
    required this.share,
    required this.count,
  });

  final Category category;
  final double total;

  /// Fraction of the period's total for this category's type, 0..1.
  final double share;
  final int count;
}

/// Rolled-up figures for a period.
@immutable
class FinanceSummary {
  const FinanceSummary({
    required this.income,
    required this.expense,
    required this.expenseByCategory,
    required this.incomeByCategory,
    required this.transactionCount,
  });

  final double income;
  final double expense;
  final List<CategorySummary> expenseByCategory;
  final List<CategorySummary> incomeByCategory;
  final int transactionCount;

  double get balance => income - expense;

  static const empty = FinanceSummary(
    income: 0,
    expense: 0,
    expenseByCategory: [],
    incomeByCategory: [],
    transactionCount: 0,
  );
}

/// Pure aggregation — broken out from providers so it can be unit-tested.
FinanceSummary summarize(List<ExpenseTransaction> transactions) {
  double income = 0;
  double expense = 0;
  final expenseTotals = <String, double>{};
  final expenseCounts = <String, int>{};
  final incomeTotals = <String, double>{};
  final incomeCounts = <String, int>{};

  for (final t in transactions) {
    if (t.type == TransactionType.income) {
      income += t.amount;
      incomeTotals.update(t.categoryId, (v) => v + t.amount,
          ifAbsent: () => t.amount);
      incomeCounts.update(t.categoryId, (v) => v + 1, ifAbsent: () => 1);
    } else {
      expense += t.amount;
      expenseTotals.update(t.categoryId, (v) => v + t.amount,
          ifAbsent: () => t.amount);
      expenseCounts.update(t.categoryId, (v) => v + 1, ifAbsent: () => 1);
    }
  }

  List<CategorySummary> build(
    Map<String, double> totals,
    Map<String, int> counts,
    double grandTotal,
  ) {
    final list = totals.entries.map((e) {
      return CategorySummary(
        category: Categories.byId(e.key),
        total: e.value,
        share: grandTotal > 0 ? e.value / grandTotal : 0,
        count: counts[e.key] ?? 0,
      );
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    return list;
  }

  return FinanceSummary(
    income: income,
    expense: expense,
    expenseByCategory: build(expenseTotals, expenseCounts, expense),
    incomeByCategory: build(incomeTotals, incomeCounts, income),
    transactionCount: transactions.length,
  );
}

/// Transactions filtered to the currently selected period, newest first.
final filteredTransactionsProvider =
    Provider<AsyncValue<List<ExpenseTransaction>>>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  final async = ref.watch(transactionsControllerProvider);
  final now = DateTime.now();
  return async.whenData(
    (list) => list.where((t) => period.contains(t.date, now)).toList(),
  );
});

/// Summary for the selected period.
final summaryProvider = Provider<FinanceSummary>((ref) {
  final filtered = ref.watch(filteredTransactionsProvider);
  return filtered.maybeWhen(
    data: summarize,
    orElse: () => FinanceSummary.empty,
  );
});
