import 'package:flutter/material.dart';

import 'transaction_type.dart';

/// A fixed spending/earning category. Categories are predefined (not user
/// editable) so the breakdown and charts stay meaningful and stable across
/// app versions.
@immutable
class Category {
  const Category({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.type,
  });

  /// Stable key persisted with each transaction. Never change these strings.
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final TransactionType type;
}

/// Central catalog of categories. Looked up by [id] everywhere else.
class Categories {
  Categories._();

  static const Category _uncategorized = Category(
    id: 'uncategorized',
    label: 'Uncategorized',
    icon: Icons.help_outline,
    color: Color(0xFF9E9E9E),
    type: TransactionType.expense,
  );

  static const List<Category> expense = [
    Category(
      id: 'food',
      label: 'Food & Dining',
      icon: Icons.restaurant,
      color: Color(0xFFEF5350),
      type: TransactionType.expense,
    ),
    Category(
      id: 'groceries',
      label: 'Groceries',
      icon: Icons.local_grocery_store,
      color: Color(0xFF66BB6A),
      type: TransactionType.expense,
    ),
    Category(
      id: 'transport',
      label: 'Transport',
      icon: Icons.directions_car,
      color: Color(0xFF42A5F5),
      type: TransactionType.expense,
    ),
    Category(
      id: 'shopping',
      label: 'Shopping',
      icon: Icons.shopping_bag,
      color: Color(0xFFAB47BC),
      type: TransactionType.expense,
    ),
    Category(
      id: 'bills',
      label: 'Bills & Utilities',
      icon: Icons.receipt_long,
      color: Color(0xFFFFA726),
      type: TransactionType.expense,
    ),
    Category(
      id: 'entertainment',
      label: 'Entertainment',
      icon: Icons.movie,
      color: Color(0xFFEC407A),
      type: TransactionType.expense,
    ),
    Category(
      id: 'health',
      label: 'Health',
      icon: Icons.favorite,
      color: Color(0xFF26A69A),
      type: TransactionType.expense,
    ),
    Category(
      id: 'education',
      label: 'Education',
      icon: Icons.school,
      color: Color(0xFF5C6BC0),
      type: TransactionType.expense,
    ),
    Category(
      id: 'travel',
      label: 'Travel',
      icon: Icons.flight,
      color: Color(0xFF29B6F6),
      type: TransactionType.expense,
    ),
    Category(
      id: 'other_expense',
      label: 'Other',
      icon: Icons.category,
      color: Color(0xFF78909C),
      type: TransactionType.expense,
    ),
  ];

  static const List<Category> income = [
    Category(
      id: 'salary',
      label: 'Salary',
      icon: Icons.account_balance_wallet,
      color: Color(0xFF66BB6A),
      type: TransactionType.income,
    ),
    Category(
      id: 'business',
      label: 'Business',
      icon: Icons.business_center,
      color: Color(0xFF26A69A),
      type: TransactionType.income,
    ),
    Category(
      id: 'investments',
      label: 'Investments',
      icon: Icons.trending_up,
      color: Color(0xFF42A5F5),
      type: TransactionType.income,
    ),
    Category(
      id: 'gifts',
      label: 'Gifts',
      icon: Icons.card_giftcard,
      color: Color(0xFFEC407A),
      type: TransactionType.income,
    ),
    Category(
      id: 'other_income',
      label: 'Other',
      icon: Icons.attach_money,
      color: Color(0xFF78909C),
      type: TransactionType.income,
    ),
  ];

  static List<Category> forType(TransactionType type) =>
      type == TransactionType.income ? income : expense;

  static final Map<String, Category> _byId = {
    for (final c in [...expense, ...income]) c.id: c,
  };

  /// Resolves a category by id, falling back to a safe placeholder so the UI
  /// never crashes on unknown/legacy data.
  static Category byId(String id) => _byId[id] ?? _uncategorized;
}
