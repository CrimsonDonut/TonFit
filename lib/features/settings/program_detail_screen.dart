import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/database/app_database.dart';
import '../../data/database/tables.dart';
import '../../data/queries/workout_queries.dart';
import '../../data/repositories/catalog_repository.dart';
import 'dialogs.dart';
import 'exercise_actions.dart';

/// One program: rename or archive it, and manage its exercises.
class ProgramDetailScreen extends ConsumerWidget {
  const ProgramDetailScreen({super.key, required this.programId});

  final int programId;

  Future<void> _renameProgram(
    BuildContext context,
    WidgetRef ref,
    Program program,
  ) async {
    final name = await promptText(
      context,
      title: 'Rename program',
      initial: program.name,
    );
    if (name == null) return;
    final ok =
        await ref.read(catalogRepositoryProvider).renameProgram(program.id, name);
    if (!ok && context.mounted) {
      showMessage(context, 'That name is empty or already used by another program.');
    }
  }

  Future<void> _newExercise(BuildContext context, WidgetRef ref) async {
    final result = await promptNewExercise(context);
    if (result == null || result.name.trim().isEmpty) return;
    await ref.read(catalogRepositoryProvider).createExercise(
          programId: programId,
          name: result.name,
          type: result.type,
          tracksDistance: result.trackDistance,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final detail = ref.watch(programDetailProvider(programId));

    return Scaffold(
      appBar: AppBar(),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (d) {
          final active = d.exercises.where((e) => !e.archived).toList();
          final archived = d.exercises.where((e) => e.archived).toList();

          Widget row(Exercise e) => Column(
                children: [
                  InkWell(
                    onTap: () => showExerciseActions(context, ref, e),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.name,
                                  style: text.bodyLarge?.copyWith(
                                    color:
                                        e.archived ? AppColors.textMuted : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  e.type.label,
                                  style: text.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.more_vert, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                ],
              );

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
            children: [
              Text(d.program.archived ? 'PROGRAM · ARCHIVED' : 'PROGRAM',
                  style: text.labelSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text(d.program.name, style: text.headlineLarge)),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _renameProgram(context, ref, d.program),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              for (final e in active) row(e),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _newExercise(context, ref),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New exercise'),
                ),
              ),
              if (archived.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('ARCHIVED EXERCISES', style: text.labelSmall),
                const SizedBox(height: 8),
                const Divider(),
                for (final e in archived) row(e),
              ],
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => ref
                    .read(catalogRepositoryProvider)
                    .setProgramArchived(d.program.id, !d.program.archived),
                style: TextButton.styleFrom(
                  foregroundColor: d.program.archived
                      ? AppColors.accent
                      : AppColors.negative,
                ),
                child: Text(
                  d.program.archived ? 'Restore program' : 'Archive program',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Archived items disappear from pickers but stay in your history.',
                style: text.bodySmall,
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}
