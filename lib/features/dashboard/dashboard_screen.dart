import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/models/expense_transaction.dart';
import '../../state/analytics.dart';
import '../../state/transactions_controller.dart';
import '../add_edit/add_edit_transaction_screen.dart';
import '../common/empty_state.dart';
import '../common/period_selector.dart';
import '../transactions/transaction_tile.dart';
import 'summary_card.dart';

/// Home tab: balance overview, period filter and the transaction feed.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SummaryCard(),
            const PeriodSelector(),
            const SizedBox(height: 4),
            Expanded(
              child: filtered.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Something went wrong:\n$e')),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return const EmptyState(
                      icon: Icons.receipt_long,
                      title: 'No transactions yet',
                      message:
                          'Tap the Add button to record your first income or expense.',
                    );
                  }
                  return _TransactionList(transactions: transactions);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends ConsumerWidget {
  const _TransactionList({required this.transactions});

  final List<ExpenseTransaction> transactions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group by calendar day, preserving the newest-first order.
    final groups = <DateTime, List<ExpenseTransaction>>{};
    for (final t in transactions) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      groups.putIfAbsent(day, () => []).add(t);
    }
    final days = groups.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: days.length,
      itemBuilder: (context, i) {
        final day = days[i];
        final items = groups[day]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                _dayLabel(day),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            for (final t in items)
              Dismissible(
                key: ValueKey(t.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  color: Theme.of(context).colorScheme.errorContainer,
                  padding: const EdgeInsets.only(right: 24),
                  child: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                confirmDismiss: (_) => _confirmDelete(context),
                onDismissed: (_) async {
                  await ref
                      .read(transactionsControllerProvider.notifier)
                      .delete(t.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transaction deleted')),
                    );
                  }
                },
                child: TransactionTile(
                  transaction: t,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          AddEditTransactionScreen(existing: t),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormats.weekday.format(day);
  }
}
