import 'package:flutter/foundation.dart';

import 'transaction_type.dart';

/// A single income or expense entry.
///
/// [amount] is always stored as a positive magnitude; the sign is derived from
/// [type] when computing balances. This keeps validation and display simple.
@immutable
class ExpenseTransaction {
  const ExpenseTransaction({
    required this.id,
    required this.bookId,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
  });

  final String id;
  final String bookId;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String? note;

  /// Signed contribution to the running balance (income positive, expense
  /// negative).
  double get signedAmount =>
      type == TransactionType.income ? amount : -amount;

  ExpenseTransaction copyWith({
    String? id,
    String? bookId,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    String? note,
  }) {
    return ExpenseTransaction(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'title': title,
      'amount': amount,
      'type': type.storageValue,
      'category': categoryId,
      'date': date.millisecondsSinceEpoch,
      'note': note,
    };
  }

  factory ExpenseTransaction.fromMap(Map<String, Object?> map) {
    return ExpenseTransaction(
      id: map['id'] as String,
      bookId: map['book_id'] as String? ?? 'default_book_id',
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      type: TransactionType.fromStorage(map['type'] as String? ?? 'expense'),
      categoryId: map['category'] as String? ?? 'other_expense',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int? ?? 0),
      note: map['note'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ExpenseTransaction &&
      other.id == id &&
      other.bookId == bookId &&
      other.title == title &&
      other.amount == amount &&
      other.type == type &&
      other.categoryId == categoryId &&
      other.date == date &&
      other.note == note;

  @override
  int get hashCode =>
      Object.hash(id, bookId, title, amount, type, categoryId, date, note);
}
