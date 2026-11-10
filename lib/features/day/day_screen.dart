import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/theme/app_theme.dart';
import '../../data/queries/workout_queries.dart';
import '../../domain/epoch_day.dart';
import '../session/day_card.dart';

/// Any day with a session, opened from the heatmap. Sets can be edited here,
/// and every cached summary follows (requirements FR-16).
class DayScreen extends ConsumerWidget {
  const DayScreen({super.key, required this.day});

  final int day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final date = EpochDay.toDate(day);
    final detail = ref.watch(dayDetailProvider(day));

    return Scaffold(
      appBar: AppBar(),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (d) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
          children: [
            Text(Fmt.monthYear(date).toUpperCase(), style: text.labelSmall),
            const SizedBox(height: 8),
            Text(
              d == null
                  ? Fmt.dayLabel(date)
                  : '${Fmt.dayLabel(date)} · ${d.program.name}',
              style: text.headlineLarge,
            ),
            const SizedBox(height: 16),
            if (d == null)
              Text('No session on this day.', style: text.bodyMedium)
            else
              DayCard(detail: d),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
