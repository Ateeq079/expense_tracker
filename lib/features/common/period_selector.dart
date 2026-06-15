import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/analytics.dart';

/// Horizontal chip row to pick the active [StatsPeriod].
class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedPeriodProvider);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: StatsPeriod.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final period = StatsPeriod.values[i];
          return ChoiceChip(
            label: Text(period.label),
            selected: selected == period,
            onSelected: (_) =>
                ref.read(selectedPeriodProvider.notifier).set(period),
          );
        },
      ),
    );
  }
}
