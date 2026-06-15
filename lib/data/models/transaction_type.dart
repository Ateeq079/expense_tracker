/// Whether a transaction adds to (income) or subtracts from (expense) balance.
enum TransactionType {
  income,
  expense;

  String get label => switch (this) {
        TransactionType.income => 'Income',
        TransactionType.expense => 'Expense',
      };

  /// Stable value persisted in the database. Never change these strings.
  String get storageValue => name;

  static TransactionType fromStorage(String value) {
    return TransactionType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => TransactionType.expense,
    );
  }
}
