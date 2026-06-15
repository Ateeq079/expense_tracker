import 'package:flutter/foundation.dart';

/// A supported display currency. The app is fully offline and does no FX
/// conversion — changing the currency only changes the symbol/formatting used
/// to display the numbers the user enters.
@immutable
class Currency {
  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });

  final String code;
  final String symbol;
  final String name;

  static const List<Currency> supported = [
    Currency(code: 'USD', symbol: '\$', name: 'US Dollar'),
    Currency(code: 'EUR', symbol: '€', name: 'Euro'),
    Currency(code: 'GBP', symbol: '£', name: 'British Pound'),
    Currency(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
    Currency(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    Currency(code: 'CAD', symbol: 'CA\$', name: 'Canadian Dollar'),
    Currency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
    Currency(code: 'CNY', symbol: 'CN¥', name: 'Chinese Yuan'),
    Currency(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
    Currency(code: 'PKR', symbol: '₨', name: 'Pakistani Rupee'),
  ];

  static const Currency fallback =
      Currency(code: 'USD', symbol: '\$', name: 'US Dollar');

  static Currency fromCode(String code) {
    return supported.firstWhere(
      (c) => c.code == code,
      orElse: () => fallback,
    );
  }
}
