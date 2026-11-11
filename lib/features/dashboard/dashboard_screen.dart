import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/queries/workout_queries.dart';
import '../../data/repositories/session_repository.dart';
import '../../domain/epoch_day.dart';
import '../session/day_card.dart';
import 'heatmap_section.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final today = ref.watch(todayProvider);
    final date = EpochDay.toDate(today);
    final detail = ref.watch(dayDetailProvider(today)).valueOrNull;

    // Start a session if today has none, otherwise keep adding to it.
    void primaryAction() {
      final d = detail;
      if (d != null) {
        context.push('/session/${d.session.id}/exercises');
      } else {
        context.push('/programs');
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margin,
        16,
        AppSpacing.margin,
        24,
      ),
      children: [
        Text(Fmt.monthYear(date), style: text.headlineLarge),
        const SizedBox(height: 16),
        const Divider(),
        const _StreakRow(),
        const Divider(),
        const _TodayRow(),
        const Divider(),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: primaryAction,
          child: Text(detail != null ? 'Add exercise' : 'Start session'),
        ),
        const SizedBox(height: 24),
        const HeatmapSection(),
      ],
    );
  }
}

class _StreakRow extends ConsumerWidget {
  const _StreakRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final streak = ref.watch(streakProvider).valueOrNull;
    final current = streak?.currentWeeks ?? 0;
    final longest = streak?.longestWeeks ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Text(
            current == 0 ? 'No streak yet' : '$current week streak',
            style: text.titleMedium?.copyWith(
              color: current == 0 ? AppColors.textMuted : AppColors.accent,
            ),
          ),
          const Spacer(),
          Text('Longest: ${Fmt.plural(longest, 'week')}', style: text.bodySmall),
        ],
      ),
    );
  }
}

/// Today's row: date on the left, program and % on the right, expandable.
class _TodayRow extends ConsumerWidget {
  const _TodayRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final today = ref.watch(todayProvider);
    final date = EpochDay.toDate(today);
    final detail = ref.watch(dayDetailProvider(today)).valueOrNull;
    final expanded = ref.watch(todayExpandedProvider);
    final isRest = ref.watch(restDayProvider(today)).valueOrNull ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: detail == null
              ? null
              : () => ref.read(todayExpandedProvider.notifier).state = !expanded,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Text(
                  detail == null
                      ? Fmt.dayLabel(date)
                      : '${Fmt.dayLabel(date)} · ${detail.program.name}',
                  style: text.titleMedium,
                ),
                const Spacer(),
                if (detail == null)
                  Text(isRest ? 'Rest day' : 'No session yet',
                      style: text.bodySmall)
                else ...[
                  if (!expanded) ...[
                    Text(detail.program.name, style: text.bodyMedium),
                    const SizedBox(width: 8),
                    PctBadge(detail.session.summaryPct, badge: true),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textMuted,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (detail == null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => ref
                  .read(sessionRepositoryProvider)
                  .markRest(today, rest: !isRest),
              child: Text(isRest ? 'Undo rest day' : 'Mark as rest day'),
            ),
          ),
        if (detail != null && expanded) ...[
          DayCard(detail: detail),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
