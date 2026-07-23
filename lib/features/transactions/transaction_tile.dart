import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/models/category.dart';
import '../../data/models/expense_transaction.dart';
import '../../data/models/transaction_type.dart';
import '../../state/settings_controller.dart';

/// A single row in the transaction list.
class TransactionTile extends ConsumerWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  final ExpenseTransaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyFormatterProvider);
    final category = Categories.byId(transaction.categoryId);
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppTheme.income : AppTheme.expense;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: category.color.withValues(alpha: 0.15),
        foregroundColor: category.color,
        child: Icon(category.icon),
      ),
      title: Text(
        transaction.title.isEmpty ? category.label : transaction.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(category.label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            money.formatSigned(transaction.signedAmount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
        ],
      ),
    );
  }
}
