import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/currency.dart';
import '../../data/models/book.dart';
import '../../data/models/expense_transaction.dart';
import '../../services/csv_export_service.dart';
import '../../state/books_controller.dart';
import '../../state/providers.dart';
import '../../state/settings_controller.dart';
import '../../state/transactions_controller.dart';

/// Settings tab: currency, appearance, data export and reset.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          children: [
            _sectionHeader(context, 'Preferences'),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Currency'),
              subtitle: Text(
                '${settings.currency.name} (${settings.currency.symbol})',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickCurrency(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined),
              title: const Text('Appearance'),
              subtitle: Text(_themeLabel(settings.themeMode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickTheme(context, ref),
            ),
            const Divider(height: 32),
            _sectionHeader(context, 'Data'),
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: const Text('Export active book as CSV'),
              subtitle: const Text('Share transactions from the current book'),
              onTap: () => _exportCsv(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Export all books as CSV'),
              subtitle: const Text('Share all transactions across all your books'),
              onTap: () => _exportAllCsv(context, ref),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              title: Text(
                'Clear all data',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              subtitle: const Text('Permanently delete every transaction'),
              onTap: () => _clearAll(context, ref),
            ),
            const Divider(height: 32),
            _sectionHeader(context, 'About'),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Version'),
              subtitle: Text(_appVersion),
            ),
            const ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text('Your data stays on this device'),
              subtitle: Text(
                'No account, no tracking. Everything is stored locally.',
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'System default',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  Future<void> _pickCurrency(BuildContext context, WidgetRef ref) async {
    final current = ref.read(settingsControllerProvider).currency;
    final selected = await showModalBottomSheet<Currency>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: RadioGroup<Currency>(
            groupValue: current,
            onChanged: (value) => Navigator.pop(context, value),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final c in Currency.supported)
                  RadioListTile<Currency>(
                    value: c,
                    title: Text(c.name),
                    secondary: Text(
                      c.symbol,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) {
      await ref.read(settingsControllerProvider.notifier).setCurrency(selected);
    }
  }

  Future<void> _pickTheme(BuildContext context, WidgetRef ref) async {
    final current = ref.read(settingsControllerProvider).themeMode;
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: RadioGroup<ThemeMode>(
            groupValue: current,
            onChanged: (value) => Navigator.pop(context, value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final mode in ThemeMode.values)
                  RadioListTile<ThemeMode>(
                    value: mode,
                    title: Text(_themeLabel(mode)),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) {
      await ref.read(settingsControllerProvider.notifier).setThemeMode(selected);
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final transactions =
        ref.read(transactionsControllerProvider).value ?? const [];
    if (transactions.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No transactions to export')),
      );
      return;
    }
    try {
      await const CsvExportService().exportAndShare(transactions);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> _exportAllCsv(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final List<Book> books = ref.read(booksControllerProvider).value ?? <Book>[];
    if (books.isEmpty) return;

    try {
      final transactionRepo = ref.read(transactionRepositoryProvider);
      
      final allTransactions = <ExpenseTransaction>[];
      final bookNames = <String, String>{};
      
      for (final book in books) {
        bookNames[book.id] = book.name;
        final txs = await transactionRepo.getAll(book.id);
        allTransactions.addAll(txs);
      }
      
      // Sort newest first across all books
      allTransactions.sort((a, b) => b.date.compareTo(a.date));

      if (allTransactions.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No transactions to export')),
        );
        return;
      }

      await const CsvExportService().exportAndShare(
        allTransactions, 
        bookNames: bookNames,
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This permanently deletes every transaction. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(transactionsControllerProvider.notifier).deleteAll();
      messenger.showSnackBar(
        const SnackBar(content: Text('All transactions deleted')),
      );
    }
  }
}
