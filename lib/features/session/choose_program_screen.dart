import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/queries/workout_queries.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/session_repository.dart';

/// Start session, step 1: pick the target program. Tapping a program starts
/// today's session in it and moves on to Add exercise.
class ChooseProgramScreen extends ConsumerWidget {
  /// [day] is an epoch-day for logging a past day; null means today.
  const ChooseProgramScreen({super.key, this.day});

  final int? day;

  Future<void> _start(BuildContext context, WidgetRef ref, int programId) async {
    final sessionId = await ref
        .read(sessionRepositoryProvider)
        .startSession(programId: programId, day: day);
    // When logging a past day, History opens that day when we come back.
    if (day != null) ref.read(pendingExpandDayProvider.notifier).state = day;
    if (context.mounted) context.pushReplacement('/session/$sessionId/exercises');
  }

  Future<void> _newProgram(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New program'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'e.g. Arms'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    await ref.read(catalogRepositoryProvider).createProgram(name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final programs = ref.watch(programsProvider);

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
        children: [
          Text('TONFIT · PROGRAMS', style: text.labelSmall),
          const SizedBox(height: 8),
          Text('Choose program', style: text.headlineLarge),
          const SizedBox(height: 16),
          const Divider(),
          programs.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Could not load programs: $e'),
            ),
            data: (list) => Column(
              children: [
                for (final p in list) ...[
                  InkWell(
                    onTap: () => _start(context, ref, p.program.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.program.name, style: text.bodyLarge),
                                const SizedBox(height: 2),
                                Text(
                                  Fmt.plural(p.exerciseCount, 'exercise'),
                                  style: text.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _newProgram(context, ref),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('New program'),
            ),
          ),
        ],
      ),
    );
  }
}
