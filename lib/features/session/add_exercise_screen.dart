import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/database/app_database.dart';
import '../../data/database/tables.dart';
import '../../data/queries/workout_queries.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../domain/weight.dart';

/// Pick exercises saved under the session's program, or create a new one.
class AddExerciseScreen extends ConsumerStatefulWidget {
  const AddExerciseScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends ConsumerState<AddExerciseScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add(int exerciseId) async {
    await ref
        .read(sessionRepositoryProvider)
        .addExercise(sessionId: widget.sessionId, exerciseId: exerciseId);
  }

  Future<void> _create(int programId) async {
    var type = ExerciseType.weighted;
    final chosen = await showDialog<ExerciseType>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Create “${_query.trim()}”'),
          content: SegmentedButton<ExerciseType>(
            segments: const [
              ButtonSegment(value: ExerciseType.weighted, label: Text('Weighted')),
              ButtonSegment(
                  value: ExerciseType.bodyweight, label: Text('Bodyweight')),
            ],
            selected: {type},
            onSelectionChanged: (s) => setState(() => type = s.first),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(type),
              child: const Text('Create and add'),
            ),
          ],
        ),
      ),
    );
    if (chosen == null) return;

    final id = await ref.read(catalogRepositoryProvider).createExercise(
          programId: programId,
          name: _query,
          type: chosen,
        );
    await _add(id);
    if (!mounted) return;
    _controller.clear();
    setState(() => _query = '');
  }

  String _lastLogged(ExerciseOption o, WeightUnit unit) {
    final reps = o.lastReps;
    if (reps == null || reps == 0) return 'Not logged yet';
    final label = Fmt.setLabel(
      weight: o.lastWeight,
      reps: reps,
      bodyweight: o.exercise.type == ExerciseType.bodyweight,
      unit: unit,
    );
    return 'Last logged: $label';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final unit = ref.watch(weightUnitProvider);
    final picker = ref.watch(exercisePickerProvider(widget.sessionId));

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ADD EXERCISE', style: text.labelSmall),
                const SizedBox(height: 8),
                Text('Add exercise', style: text.headlineLarge),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search or type a new exercise',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      borderSide: const BorderSide(color: AppColors.hairline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      borderSide: const BorderSide(color: AppColors.hairline),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: picker.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Could not load: $e')),
              data: (data) {
                final all = data.options;
                final q = _query.trim().toLowerCase();
                final shown = q.isEmpty
                    ? all
                    : all
                        .where((o) =>
                            o.exercise.name.toLowerCase().contains(q))
                        .toList();
                final exact = all.any((o) => o.exercise.name.toLowerCase() == q);
                final canCreate = q.isNotEmpty && !exact;
                final pid = data.programId;

                return ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
                  children: [
                    if (canCreate)
                      InkWell(
                        onTap: () => _create(pid),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.add, color: AppColors.accent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Create “${_query.trim()}”',
                                  style: text.bodyLarge
                                      ?.copyWith(color: AppColors.accent),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (canCreate) const Divider(),
                    for (final o in shown) ...[
                      InkWell(
                        onTap: o.added ? null : () => _add(o.exercise.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(o.exercise.name, style: text.bodyLarge),
                                    const SizedBox(height: 2),
                                    Text(_lastLogged(o, unit),
                                        style: text.bodySmall),
                                  ],
                                ),
                              ),
                              Icon(
                                o.added ? Icons.check : Icons.add,
                                color: o.added
                                    ? AppColors.positive
                                    : AppColors.textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                    ],
                  ],
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.margin),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
