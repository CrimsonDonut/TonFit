import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/database/app_database.dart';
import '../../data/database/tables.dart';
import '../../data/queries/workout_queries.dart';
import '../../data/repositories/session_repository.dart';
import '../../domain/weight.dart';

/// Opens the sheet to add a set to [view], or to edit/delete [editing].
Future<void> showAddSetSheet(
  BuildContext context, {
  required ExerciseLogView view,
  SetEntry? editing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => AddSetSheet(view: view, editing: editing),
  );
}

class AddSetSheet extends ConsumerStatefulWidget {
  const AddSetSheet({super.key, required this.view, this.editing});

  final ExerciseLogView view;
  final SetEntry? editing;

  @override
  ConsumerState<AddSetSheet> createState() => _AddSetSheetState();
}

class _AddSetSheetState extends ConsumerState<AddSetSheet> {
  late final WeightUnit _unit;
  late double _weight; // in display units
  late int _reps;

  /// Time-based exercises (timed, sport) log a duration instead.
  late int _seconds;
  bool _touched = false;
  int _added = 0;
  ({int? weight, int? reps})? _previous;

  ExerciseType get _type => widget.view.exercise.type;
  bool get _bodyweight => _type == ExerciseType.bodyweight;
  bool get _timeBased => _type.isTimeBased;
  bool get _isSport => _type == ExerciseType.sport;
  bool get _editing => widget.editing != null;

  /// Starting duration for an exercise with no history: 1 minute of work, or
  /// an hour of sport.
  int get _defaultSeconds => _isSport ? 3600 : 60;

  @override
  void initState() {
    super.initState();
    _unit = ref.read(weightUnitProvider);

    final editing = widget.editing;
    final sets = widget.view.sets;
    _weight = 0;
    _reps = 10;
    _seconds = _defaultSeconds;
    if (editing != null) {
      _weight = _toDisplay(editing.weight ?? 0);
      _reps = editing.reps;
      if (_timeBased) _seconds = editing.reps;
    } else if (sets.isNotEmpty) {
      _weight = _toDisplay(sets.last.weight ?? 0);
      _reps = sets.last.reps;
      if (_timeBased) _seconds = sets.last.reps;
    } else if (!_timeBased) {
      _weight = _bodyweight ? 0 : (_unit == WeightUnit.kg ? 20 : 45);
    }

    if (editing == null) _loadPrevious();
  }

  double _toDisplay(int stored) =>
      double.parse(Weight.format(stored, _unit));

  /// Prefill from the previous session when this exercise has no sets yet.
  Future<void> _loadPrevious() async {
    final prev =
        await ref.read(workoutQueriesProvider).previousTop(widget.view.log);
    if (!mounted || prev == null) return;
    setState(() {
      _previous = prev;
      if (!_touched && widget.view.sets.isEmpty) {
        if (_timeBased) {
          if ((prev.reps ?? 0) > 0) _seconds = prev.reps!;
        } else {
          _weight = _toDisplay(prev.weight ?? 0);
          if ((prev.reps ?? 0) > 0) _reps = prev.reps!;
        }
      }
    });
  }

  /// What goes in the set's `reps` field: repetitions, or seconds.
  int get _storedReps => _timeBased ? _seconds : _reps;

  int? get _storedWeight {
    if (_timeBased) return null; // timed and sport sets have no weight
    final stored = Weight.toStored(_weight, _unit);
    // Pure bodyweight sets store no weight at all.
    return (_bodyweight && stored == 0) ? null : stored;
  }

  String _numberText(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  void _changeWeight(int direction) {
    setState(() {
      _touched = true;
      final next = _weight + direction * Weight.step(_unit);
      _weight = next < 0 ? 0 : next;
    });
  }

  /// Moves the duration by [delta] seconds, never below [floor].
  void _changeSeconds(int delta, {int floor = 5}) {
    setState(() {
      _touched = true;
      final next = _seconds + delta;
      _seconds = next < floor ? floor : next;
    });
  }

  void _changeReps(int direction) {
    setState(() {
      _touched = true;
      final next = _reps + direction;
      _reps = next < 1 ? 1 : next;
    });
  }

  Future<void> _add() async {
    await ref.read(sessionRepositoryProvider).addSet(
          exerciseLogId: widget.view.log.id,
          weight: _storedWeight,
          reps: _storedReps,
        );
    if (mounted) setState(() => _added++);
  }

  Future<void> _save() async {
    await ref.read(sessionRepositoryProvider).updateSet(
          setId: widget.editing!.id,
          weight: _storedWeight,
          reps: _storedReps,
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    await ref.read(sessionRepositoryProvider).deleteSet(widget.editing!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final previous = _previous;
    final unitName = _unit.name;
    final nextSetNumber = widget.view.sets.length + _added + 1;

    final String subtitle;
    if (_editing) {
      subtitle = 'Editing set ${widget.editing!.idx}';
    } else if (previous != null && (previous.reps ?? 0) > 0) {
      final label = Fmt.setLabel(
        weight: previous.weight,
        reps: previous.reps!,
        type: _type,
        unit: _unit,
      );
      subtitle = 'Last session: $label';
    } else {
      subtitle = _isSport ? 'Time played' : 'Set $nextSetNumber';
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.margin,
          16,
          AppSpacing.margin,
          AppSpacing.margin,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.view.exercise.name,
                      style: text.headlineLarge?.copyWith(fontSize: 22)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Text(subtitle, style: text.bodySmall),
            if (!_editing && _added > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _isSport
                      ? '$_added logged this time'
                      : '${Fmt.plural(_added, 'set')} added this time',
                  style: text.bodySmall?.copyWith(color: AppColors.positive),
                ),
              ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            if (_isSport)
              // One wide stepper: games are logged in blocks of 5 minutes.
              _Stepper(
                label: 'Minutes played',
                value: '${_seconds ~/ 60}',
                onMinus: () => _changeSeconds(-300, floor: 300),
                onPlus: () => _changeSeconds(300, floor: 300),
              )
            else if (_timeBased)
              Row(
                children: [
                  Expanded(
                    child: _Stepper(
                      label: 'Minutes',
                      value: '${_seconds ~/ 60}',
                      onMinus: () => _changeSeconds(-60),
                      onPlus: () => _changeSeconds(60),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Stepper(
                      label: 'Seconds',
                      value: (_seconds % 60).toString().padLeft(2, '0'),
                      onMinus: () => _changeSeconds(-5),
                      onPlus: () => _changeSeconds(5),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _Stepper(
                      label: _bodyweight
                          ? 'Added weight ($unitName)'
                          : 'Weight ($unitName)',
                      value: _numberText(_weight),
                      onMinus: () => _changeWeight(-1),
                      onPlus: () => _changeWeight(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Stepper(
                      label: 'Reps',
                      value: '$_reps',
                      onMinus: () => _changeReps(-1),
                      onPlus: () => _changeReps(1),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            if (_editing)
              Row(
                children: [
                  TextButton(
                    onPressed: _delete,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.negative,
                    ),
                    child: Text(_isSport ? 'Delete' : 'Delete set'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _add,
                      child: Text(_isSport ? 'Log time' : 'Add set'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.bodySmall),
        const SizedBox(height: 8),
        Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.canvas,
            border: Border.all(color: AppColors.hairline),
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: onMinus,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    value,
                    style: text.headlineLarge?.copyWith(fontSize: 28),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: onPlus,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
