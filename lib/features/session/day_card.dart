import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/database/app_database.dart';
import '../../data/database/tables.dart';
import '../../data/queries/workout_queries.dart';
import '../../data/repositories/session_repository.dart';
import '../../domain/epoch_day.dart';
import '../../domain/progress.dart';
import '../../domain/weight.dart';
import '../settings/dialogs.dart';
import 'add_set_sheet.dart';

/// A percentage badge: "+3.8%" in green with a tint, "-2.1%" in coral,
/// "0.0%" muted, or "New".
class PctBadge extends StatelessWidget {
  const PctBadge(this.tenths, {super.key, this.badge = false});

  final int? tenths;

  /// Draw the green tinted background (used on the collapsed today row).
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final t = tenths;
    final color = t == null ? AppColors.textMuted : AppColors.change(t);
    final tinted = badge && t != null && t > 0;
    return Container(
      padding: tinted
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: tinted ? AppColors.positiveTint : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        Progress.format(t),
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontWeight: FontWeight.w500,
          color: color,
          fontSize: 14,
        ),
      ),
    );
  }
}

/// The body of a day: summary line, time in/out, every exercise with its sets,
/// "+ Add exercise", and suggestion messages. Used on the dashboard (today)
/// and on the day screen (any past day).
class DayCard extends ConsumerWidget {
  const DayCard({super.key, required this.detail});

  final DayDetail detail;

  /// Pick time in, then time out. A time out at or before the time in is taken
  /// to be after midnight (the next day).
  Future<void> _editTimes(
    BuildContext context,
    WidgetRef ref,
    Session session,
  ) async {
    final date = EpochDay.toDate(session.day);

    TimeOfDay initial(int? seconds, TimeOfDay fallback) => seconds == null
        ? fallback
        : TimeOfDay.fromDateTime(
            DateTime.fromMillisecondsSinceEpoch(seconds * 1000));

    final timeIn = await showTimePicker(
      context: context,
      initialTime: initial(session.timeIn, const TimeOfDay(hour: 18, minute: 0)),
      helpText: 'TIME IN',
    );
    if (timeIn == null || !context.mounted) return;

    final timeOut = await showTimePicker(
      context: context,
      initialTime: initial(session.timeOut, timeIn),
      helpText: 'TIME OUT',
    );
    if (timeOut == null) return;

    final start =
        DateTime(date.year, date.month, date.day, timeIn.hour, timeIn.minute);
    var end =
        DateTime(date.year, date.month, date.day, timeOut.hour, timeOut.minute);
    if (!end.isAfter(start)) end = end.add(const Duration(days: 1));

    await ref.read(sessionRepositoryProvider).setTimes(
          sessionId: session.id,
          timeIn: start.millisecondsSinceEpoch ~/ 1000,
          timeOut: end.millisecondsSinceEpoch ~/ 1000,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final unit = ref.watch(weightUnitProvider);
    final session = detail.session;
    final programName = detail.program.name;

    final timeIn = session.timeIn;
    final timeOut = session.timeOut;
    final String? timeLine = timeIn == null
        ? null
        : timeOut == null
            ? 'In ${Fmt.clock(timeIn)}'
            : 'In ${Fmt.clock(timeIn)} · Out ${Fmt.clock(timeOut)} · '
                '${Fmt.duration(timeOut - timeIn)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PctBadge(session.summaryPct),
            const SizedBox(width: 6),
            Text(
              session.summaryPct == null
                  ? 'first $programName session'
                  : 'vs last $programName session',
              style: text.bodySmall,
            ),
          ],
        ),
        InkWell(
          onTap: () => _editTimes(context, ref, session),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    timeLine ?? 'Add time in / out',
                    style: text.bodySmall,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.edit_outlined,
                    size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Divider(),
        for (final view in detail.logs) ...[
          _ExerciseSection(view: view, unit: unit),
          const Divider(),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => context.push('/session/${session.id}/exercises'),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add exercise'),
          ),
        ),
        if (detail.messages.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.hairline),
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < detail.messages.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  Text(detail.messages[i], style: text.bodyMedium),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ExerciseSection extends ConsumerWidget {
  const _ExerciseSection({required this.view, required this.unit});

  final ExerciseLogView view;
  final WeightUnit unit;

  String _label(int? weight, int reps, bool bodyweight) => Fmt.setLabel(
        weight: weight,
        reps: reps,
        bodyweight: bodyweight,
        unit: unit,
      );

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final sets = view.sets.length;
    final consequence =
        sets == 0 ? '' : ' Its ${Fmt.plural(sets, 'set')} will be deleted.';
    final ok = await confirmDialog(
      context,
      title: 'Remove ${view.exercise.name}?',
      message: 'It will be removed from this session.$consequence',
      confirm: 'Remove',
    );
    if (!ok) return;
    await ref.read(sessionRepositoryProvider).removeExercise(view.log.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final bodyweight = view.exercise.type == ExerciseType.bodyweight;

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(view.exercise.name, style: text.titleMedium)),
              if (view.sets.isNotEmpty) PctBadge(view.log.pct),
              PopupMenuButton<String>(
                tooltip: 'Exercise options',
                icon: const Icon(Icons.more_vert,
                    size: 20, color: AppColors.textMuted),
                onSelected: (_) => _remove(context, ref),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'remove',
                    child: Text(
                      'Remove from this session',
                      style: TextStyle(color: AppColors.negative),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final s in view.sets)
            InkWell(
              onTap: () => showAddSetSheet(context, view: view, editing: s),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Text(
                  '${s.idx}. ${_label(s.weight, s.reps, bodyweight)}',
                  style: text.bodyLarge,
                ),
              ),
            ),
          TextButton(
            onPressed: () => showAddSetSheet(context, view: view),
            child: const Text('+ Add set'),
          ),
        ],
      ),
    );
  }
}
