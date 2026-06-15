import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/models/transaction_type.dart';
import '../../state/analytics.dart';
import '../../state/settings_controller.dart';
import '../common/empty_state.dart';
import '../common/period_selector.dart';

/// Stats tab: category-wise pie chart and breakdown for the selected period.
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  TransactionType _view = TransactionType.expense;
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(summaryProvider);
    final money = ref.watch(moneyFormatterProvider);

    final isExpense = _view == TransactionType.expense;
    final items =
        isExpense ? summary.expenseByCategory : summary.incomeByCategory;
    final total = isExpense ? summary.expense : summary.income;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SafeArea(
        child: Column(
          children: [
            const PeriodSelector(),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expenses'),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                  ),
                ],
                selected: {_view},
                onSelectionChanged: (s) => setState(() {
                  _view = s.first;
                  _touchedIndex = null;
                }),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? EmptyState(
                      icon: Icons.pie_chart_outline,
                      title: 'Nothing to show',
                      message:
                          'No ${isExpense ? 'expenses' : 'income'} recorded for this period.',
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      children: [
                        _Chart(
                          items: items,
                          total: total,
                          money: money,
                          touchedIndex: _touchedIndex,
                          onTouch: (i) => setState(() => _touchedIndex = i),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Total  ${money.format(total)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (final cs in items)
                          _CategoryRow(summary: cs, money: money),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({
    required this.items,
    required this.total,
    required this.money,
    required this.touchedIndex,
    required this.onTouch,
  });

  final List<CategorySummary> items;
  final double total;
  final MoneyFormatter money;
  final int? touchedIndex;
  final ValueChanged<int?> onTouch;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 56,
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              if (!event.isInterestedForInteractions ||
                  response?.touchedSection == null) {
                onTouch(null);
                return;
              }
              onTouch(response!.touchedSection!.touchedSectionIndex);
            },
          ),
          sections: [
            for (var i = 0; i < items.length; i++)
              _section(items[i], i == touchedIndex),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _section(CategorySummary cs, bool touched) {
    final pct = (cs.share * 100);
    return PieChartSectionData(
      value: cs.total,
      color: cs.category.color,
      title: pct >= 6 ? '${pct.toStringAsFixed(0)}%' : '',
      radius: touched ? 72 : 62,
      titleStyle: TextStyle(
        fontSize: touched ? 16 : 13,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      badgeWidget: touched
          ? _Badge(icon: cs.category.icon, color: cs.category.color)
          : null,
      badgePositionPercentageOffset: 1.05,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4),
        ],
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.summary, required this.money});

  final CategorySummary summary;
  final MoneyFormatter money;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cat = summary.category;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: cat.color.withValues(alpha: 0.15),
            foregroundColor: cat.color,
            child: Icon(cat.icon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cat.label, style: theme.textTheme.titleSmall),
                    Text(
                      money.format(summary.total),
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: summary.share.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: cat.color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(cat.color),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(summary.share * 100).toStringAsFixed(1)}%  ·  ${summary.count} ${summary.count == 1 ? 'entry' : 'entries'}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
