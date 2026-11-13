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
class DayCard extends ConsumerStatefulWidget {
  const DayCard({super.key, required this.detail});

  final DayDetail detail;

  @override
  ConsumerState<DayCard> createState() => _DayCardState();
}

class _DayCardState extends ConsumerState<DayCard> {
  DayDetail get detail => widget.detail;

  /// Exercise-log ids in the order just chosen by dragging. Shown straight away
  /// so the list doesn't snap back while the database catches up, and dropped
  /// once the database order matches it.
  List<int>? _localOrder;

  @override
  void didUpdateWidget(covariant DayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final local = _localOrder;
    if (local == null) return;
    final saved = [for (final v in widget.detail.logs) v.log.id];
    if (saved.length == local.length) {
      var same = true;
      for (var i = 0; i < saved.length; i++) {
        if (saved[i] != local[i]) same = false;
      }
      if (same) _localOrder = null;
    }
  }

  List<ExerciseLogView> _ordered() {
    final local = _localOrder;
    if (local == null) return detail.logs;
    final byId = {for (final v in detail.logs) v.log.id: v};
    return [
      for (final id in local)
        if (byId[id] != null) byId[id]!,
      // Anything added since the drag goes at the end.
      ...detail.logs.where((v) => !local.contains(v.log.id)),
    ];
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final ids = [for (final v in _ordered()) v.log.id];
    final moved = ids.removeAt(oldIndex);
    ids.insert(newIndex, moved);
    setState(() => _localOrder = ids);
    ref.read(sessionRepositoryProvider).reorderExercises(
          sessionId: detail.session.id,
          orderedLogIds: ids,
        );
  }

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

  Future<void> _deleteSession(BuildContext context, WidgetRef ref) async {
    final sets = detail.logs.fold<int>(0, (a, v) => a + v.sets.length);
    final consequence = sets == 0
        ? ''
        : ' Its ${Fmt.plural(detail.logs.length, 'exercise')} and '
            '${Fmt.plural(sets, 'set')} will be deleted.';
    final ok = await confirmDialog(
      context,
      title: 'Delete this ${detail.program.name} session?',
      message: 'The day will go back to having nothing logged.$consequence '
          'This can’t be undone.',
      confirm: 'Delete',
    );
    if (!ok) return;
    await ref.read(sessionRepositoryProvider).deleteSession(detail.session.id);
  }

  @override
  Widget build(BuildContext context) {
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
        // Press and hold an exercise, then drag it to a new place.
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          onReorder: _onReorder,
          proxyDecorator: (child, index, animation) => Material(
            color: AppColors.surface,
            elevation: 4,
            shadowColor: Colors.black,
            borderRadius: BorderRadius.circular(AppRadius.input),
            child: child,
          ),
          children: [
            for (final view in _ordered())
              Column(
                key: ValueKey(view.log.id),
                children: [
                  _ExerciseSection(view: view, unit: unit),
                  const Divider(),
                ],
              ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => context.push('/session/${session.id}/exercises'),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add exercise'),
          ),
        ),
        if (detail.logs.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Press and hold an exercise to change its order.',
              style: text.bodySmall,
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
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _deleteSession(context, ref),
            icon: const Icon(Icons.delete_outline, size: 20),
            label: const Text('Delete session'),
            style: TextButton.styleFrom(foregroundColor: AppColors.negative),
          ),
        ),
      ],
    );
  }
}

class _ExerciseSection extends ConsumerWidget {
  const _ExerciseSection({required this.view, required this.unit});

  final ExerciseLogView view;
  final WeightUnit unit;

  String _label(int? weight, int reps) => Fmt.setLabel(
        weight: weight,
        reps: reps,
        type: view.exercise.type,
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
    final type = view.exercise.type;
    final isSport = type == ExerciseType.sport;
    // Sport has no percentage; its header shows the total time played.
    final totalSeconds = view.sets.fold<int>(0, (a, s) => a + s.reps);

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(view.exercise.name, style: text.titleMedium)),
              if (view.sets.isNotEmpty && type.tracksProgress)
                PctBadge(view.log.pct)
              else if (view.sets.isNotEmpty && isSport)
                Text(Fmt.duration(totalSeconds), style: text.bodySmall),
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
                  '${s.idx}. ${_label(s.weight, s.reps)}',
                  style: text.bodyLarge,
                ),
              ),
            ),
          TextButton(
            onPressed: () => showAddSetSheet(context, view: view),
            child: Text(isSport ? '+ Add time' : '+ Add set'),
          ),
        ],
      ),
    );
  }
}
