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
import '../dashboard/heatmap_section.dart';
import '../session/day_card.dart';
import '../settings/dialogs.dart';

/// The History tab: every session of a year, newest first and grouped by
/// month, starting with the current year (arrows go to earlier years). Tap a
/// day to expand it in place and view or edit its sets; all summaries follow
/// the edit (requirements FR-16, FR-27, FR-28).
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _MonthHeader {
  const _MonthHeader(this.month, this.sessions);
  final int month;
  final int sessions;
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  /// Null follows the current year (including when it rolls over).
  int? _selectedYear;
  final Set<int> _expanded = {};

  void _goTo(int year) {
    setState(() {
      _selectedYear = year;
      _expanded.clear();
    });
  }

  void _toggle(int day) {
    setState(() {
      if (!_expanded.remove(day)) _expanded.add(day);
    });
  }

  /// Jump to the day's year and open it.
  void _reveal(int day) {
    setState(() {
      _selectedYear = EpochDay.toDate(day).year;
      _expanded.add(day);
    });
  }

  /// Log a session on, or mark as a rest day, a day that was missed.
  Future<void> _addPastDay(int today) async {
    final todayDate = EpochDay.toDate(today);
    final picked = await showDatePicker(
      context: context,
      initialDate: todayDate.subtract(const Duration(days: 1)),
      firstDate: DateTime(2020),
      lastDate: todayDate,
      helpText: 'WHICH DAY?',
    );
    if (picked == null || !mounted) return;
    final day = EpochDay.fromDate(picked);

    // That day already has a session: open it instead of making a second one.
    final existing = await ref.read(workoutQueriesProvider).loadDay(day);
    if (!mounted) return;
    if (existing != null) {
      _reveal(day);
      showMessage(context, 'That day already has a session. It is open below.');
      return;
    }

    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('${Fmt.dayLabel(picked)} ${Fmt.month(picked.month)} ${picked.year}'),
              subtitle: const Text('Nothing is logged on this day yet'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Log a session'),
              onTap: () => Navigator.of(ctx).pop('session'),
            ),
            ListTile(
              leading: const Icon(Icons.bedtime_outlined),
              title: const Text('Mark as rest day'),
              subtitle: const Text('Rest days never affect your streak'),
              onTap: () => Navigator.of(ctx).pop('rest'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;

    if (choice == 'session') {
      context.push('/programs?day=$day');
    } else {
      await ref.read(sessionRepositoryProvider).markRest(day);
      if (mounted) _reveal(day);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final today = ref.watch(todayProvider);
    final currentYear = EpochDay.toDate(today).year;
    final selectedYear = _selectedYear ?? currentYear;
    final data = ref.watch(yearDataProvider(selectedYear));
    final heat = ref.watch(heatmapProvider(selectedYear));

    // After logging a past day, open it when we come back to this tab.
    ref.listen<int?>(pendingExpandDayProvider, (previous, next) {
      if (next == null) return;
      _reveal(next);
      ref.read(pendingExpandDayProvider.notifier).state = null;
    });

    return data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (year) {
          // Flatten into month headers and day rows for a lazy list.
          final sessionsPerMonth = <int, int>{};
          for (final d in year.days) {
            if (d.sessionId == null) continue;
            final m = EpochDay.toDate(d.day).month;
            sessionsPerMonth[m] = (sessionsPerMonth[m] ?? 0) + 1;
          }
          final items = <Object>[];
          int? lastMonth;
          for (final d in year.days) {
            final m = EpochDay.toDate(d.day).month;
            if (m != lastMonth) {
              items.add(_MonthHeader(m, sessionsPerMonth[m] ?? 0));
              lastMonth = m;
            }
            items.add(d);
          }
          final total =
              sessionsPerMonth.values.fold<int>(0, (a, b) => a + b);

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.margin, 16, AppSpacing.margin, 0),
            itemCount: items.length + 2,
            itemBuilder: (context, i) {
              if (i == 0) {
                return _YearHeader(
                  year: selectedYear,
                  total: total,
                  canGoBack: selectedYear > year.firstYear,
                  canGoForward: selectedYear < currentYear,
                  onBack: () => _goTo(selectedYear - 1),
                  onForward: () => _goTo(selectedYear + 1),
                  onAddPastDay: () => _addPastDay(today),
                  heatmap: heat.when(
                    loading: () => const SizedBox(height: 120),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (h) => Column(
                      children: [
                        HeatmapGrid(data: h, todayDay: today),
                        const SizedBox(height: 8),
                        const HeatmapLegend(),
                      ],
                    ),
                  ),
                );
              }
              if (i == items.length + 1) {
                return total == 0
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text('No sessions in $selectedYear.',
                            style: text.bodyMedium),
                      )
                    : const SizedBox(height: 32);
              }

              final item = items[i - 1];
              if (item is _MonthHeader) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 8),
                  child: Row(
                    children: [
                      Text(Fmt.month(item.month).toUpperCase(),
                          style: text.labelSmall),
                      const Spacer(),
                      Text(Fmt.plural(item.sessions, 'session'),
                          style: text.bodySmall),
                    ],
                  ),
                );
              }
              final entry = item as YearDay;
              return _DayEntry(
                entry: entry,
                expanded: _expanded.contains(entry.day),
                onToggle: () => _toggle(entry.day),
              );
            },
          );
        },
    );
  }
}

class _YearHeader extends StatelessWidget {
  const _YearHeader({
    required this.year,
    required this.total,
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
    required this.onAddPastDay,
    required this.heatmap,
  });

  final int year;
  final int total;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onAddPastDay;
  final Widget heatmap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TONFIT · SESSION LOG', style: text.labelSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('$year', style: text.headlineLarge),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: canGoBack ? onBack : null,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: canGoForward ? onForward : null,
            ),
          ],
        ),
        Text(Fmt.plural(total, 'session'), style: text.bodySmall),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onAddPastDay,
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Log or mark a past day'),
        ),
        const SizedBox(height: 8),
        heatmap,
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }
}

/// One day: a collapsed row, or the full editable day card when expanded.
class _DayEntry extends ConsumerWidget {
  const _DayEntry({
    required this.entry,
    required this.expanded,
    required this.onToggle,
  });

  final YearDay entry;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final date = EpochDay.toDate(entry.day);
    final label = '${date.day} ${Fmt.weekday(date.weekday)}';

    // A rest day: nothing to open, but the mark can be removed.
    if (entry.sessionId == null) {
      return Column(
        children: [
          InkWell(
            onTap: () async {
              final ok = await confirmDialog(
                context,
                title: 'Remove rest day?',
                message: 'This day will no longer be marked as a rest day.',
                confirm: 'Remove',
              );
              if (ok) {
                await ref
                    .read(sessionRepositoryProvider)
                    .markRest(entry.day, rest: false);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: Text(label,
                        style: text.bodyLarge
                            ?.copyWith(color: AppColors.textMuted)),
                  ),
                  Expanded(
                    child: Text('Rest',
                        style: text.bodyLarge
                            ?.copyWith(color: AppColors.textMuted)),
                  ),
                  Text('Tap to remove', style: text.bodySmall),
                ],
              ),
            ),
          ),
          const Divider(),
        ],
      );
    }

    final detail =
        expanded ? ref.watch(dayDetailProvider(entry.day)).valueOrNull : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                SizedBox(width: 72, child: Text(label, style: text.titleMedium)),
                Expanded(
                  child: Text(entry.programName ?? '', style: text.bodyLarge),
                ),
                if (entry.setCount == 0)
                  Text('No sets', style: text.bodySmall)
                else
                  PctBadge(entry.summaryPct),
                const SizedBox(width: 8),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: detail == null
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : DayCard(detail: detail),
          ),
        const Divider(),
      ],
    );
  }
}
