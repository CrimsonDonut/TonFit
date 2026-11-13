import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/queries/workout_queries.dart';
import '../../data/repositories/catalog_repository.dart';
import 'dialogs.dart';

/// Settings > Programs: every program, with archived ones listed last.
class ProgramsScreen extends ConsumerWidget {
  const ProgramsScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final name = await promptText(
      context,
      title: 'New program',
      hint: 'e.g. Arms',
      confirm: 'Create',
    );
    if (name == null || name.trim().isEmpty) return;
    await ref.read(catalogRepositoryProvider).createProgram(name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final programs = ref.watch(allProgramsProvider);

    return Scaffold(
      appBar: AppBar(),
      body: programs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (all) {
          final active = all.where((p) => !p.program.archived).toList();
          final archived = all.where((p) => p.program.archived).toList();

          Widget row(ProgramView p) => Column(
                children: [
                  InkWell(
                    onTap: () => context.push('/my-programs/${p.program.id}'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.program.name,
                                  style: text.bodyLarge?.copyWith(
                                    color: p.program.archived
                                        ? AppColors.textMuted
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(Fmt.plural(p.exerciseCount, 'exercise'),
                                    style: text.bodySmall),
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
              );

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
            children: [
              Text('TONFIT · MANAGE', style: text.labelSmall),
              const SizedBox(height: 8),
              Text('Programs', style: text.headlineLarge),
              const SizedBox(height: 16),
              const Divider(),
              for (final p in active) row(p),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _create(context, ref),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New program'),
                ),
              ),
              if (archived.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('ARCHIVED', style: text.labelSmall),
                const SizedBox(height: 8),
                const Divider(),
                for (final p in archived) row(p),
              ],
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}
