import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/formatters.dart';
import '../data/models/category.dart';
import '../data/models/expense_transaction.dart';

/// Builds a CSV of transactions and hands it to the system share sheet.
class CsvExportService {
  const CsvExportService();

  static const _headers = [
    'Date',
    'Type',
    'Category',
    'Title',
    'Amount',
    'Signed Amount',
    'Note',
  ];

  static const _headersWithBook = [
    'Book',
    'Date',
    'Type',
    'Category',
    'Title',
    'Amount',
    'Signed Amount',
    'Note',
  ];

  /// Serializes [transactions] (newest first) to CSV text.
  /// If [bookNames] is provided, adds a 'Book' column.
  String buildCsv(List<ExpenseTransaction> transactions, {Map<String, String>? bookNames}) {
    final hasBooks = bookNames != null;
    final rows = <List<Object?>>[hasBooks ? _headersWithBook : _headers];
    for (final t in transactions) {
      final row = [
        DateFormats.csvTimestamp.format(t.date),
        t.type.label,
        Categories.byId(t.categoryId).label,
        t.title,
        t.amount.toStringAsFixed(2),
        t.signedAmount.toStringAsFixed(2),
        t.note ?? '',
      ];
      if (hasBooks) {
        row.insert(0, bookNames[t.bookId] ?? 'Unknown');
      }
      rows.add(row);
    }
    // BOM so spreadsheet apps render currency symbols / unicode correctly.
    return Csv(addBom: true).encode(rows);
  }

  /// Writes the CSV to a temporary file and opens the share sheet.
  /// Returns the number of transactions exported.
  Future<int> exportAndShare(List<ExpenseTransaction> transactions, {Map<String, String>? bookNames}) async {
    final csv = buildCsv(transactions, bookNames: bookNames);
    final dir = await getTemporaryDirectory();
    final stamp = DateFormats.fileStamp.format(DateTime.now());
    final file = File(p.join(dir.path, 'expenses_$stamp.csv'));
    await file.writeAsString(csv, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Expense Tracker export',
        text: 'My transactions exported from Expense Tracker.',
      ),
    );
    return transactions.length;
  }
}
