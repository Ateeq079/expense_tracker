import 'package:intl/intl.dart';

import 'currency.dart';

/// Formats monetary amounts using the user's selected [Currency].
///
/// Cheap to construct; built fresh whenever the currency changes.
class MoneyFormatter {
  MoneyFormatter(this.currency)
      : _format = NumberFormat.currency(
          symbol: currency.symbol,
          decimalDigits: _decimalDigitsFor(currency.code),
        );

  final Currency currency;
  final NumberFormat _format;

  /// Currencies with no minor unit shouldn't show cents.
  static int _decimalDigitsFor(String code) {
    const zeroDecimal = {'JPY', 'CNY'};
    return zeroDecimal.contains(code) ? 0 : 2;
  }

  String format(double amount) => _format.format(amount);

  /// Signed display, e.g. "+$10.00" / "-$4.50", for transaction rows.
  String formatSigned(double signedAmount) {
    final sign = signedAmount > 0 ? '+' : signedAmount < 0 ? '-' : '';
    return '$sign${_format.format(signedAmount.abs())}';
  }
}

/// Shared date formatting helpers.
class DateFormats {
  DateFormats._();

  static final DateFormat dayMonthYear = DateFormat('d MMM yyyy');
  static final DateFormat monthYear = DateFormat('MMMM yyyy');
  static final DateFormat weekday = DateFormat('EEE, d MMM');
  static final DateFormat csvTimestamp = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat fileStamp = DateFormat('yyyyMMdd_HHmmss');
}
