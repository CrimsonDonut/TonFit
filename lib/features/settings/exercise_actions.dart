import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../data/database/tables.dart';
import '../../data/repositories/catalog_repository.dart';
import 'dialogs.dart';

/// The actions for one exercise of a program: rename, archive or restore, and
/// delete. Shared by Settings > Programs and the Add exercise screen (press and
/// hold a row).
///
/// Delete only works for an exercise that has never been logged, because
/// deleting one with history would erase real sets. Archiving hides it from
/// pickers and keeps the history.
Future<void> showExerciseActions(
  BuildContext context,
  WidgetRef ref,
  Exercise e,
) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(e.name),
            subtitle: Text(
              e.type == ExerciseType.bodyweight ? 'Bodyweight' : 'Weighted',
            ),
          ),
          const Divider(),
          if (!e.archived)
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () => Navigator.of(ctx).pop('rename'),
            ),
          ListTile(
            leading: Icon(
              e.archived ? Icons.unarchive_outlined : Icons.archive_outlined,
            ),
            title: Text(e.archived ? 'Restore' : 'Archive'),
            subtitle: e.archived
                ? null
                : const Text('Hidden from pickers, kept in your history'),
            onTap: () => Navigator.of(ctx).pop('archive'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.negative),
            title: const Text(
              'Delete',
              style: TextStyle(color: AppColors.negative),
            ),
            subtitle: const Text('Only if it has never been logged'),
            onTap: () => Navigator.of(ctx).pop('delete'),
          ),
        ],
      ),
    ),
  );
  if (action == null || !context.mounted) return;

  final catalog = ref.read(catalogRepositoryProvider);
  switch (action) {
    case 'archive':
      await catalog.setExerciseArchived(e.id, !e.archived);

    case 'rename':
      final name = await promptText(
        context,
        title: 'Rename exercise',
        initial: e.name,
        maxLength: 60,
      );
      if (name == null) return;
      final ok = await catalog.renameExercise(e.id, name);
      if (!ok && context.mounted) {
        showMessage(context, 'That name is empty or already used in this program.');
      }

    case 'delete':
      final confirmed = await confirmDialog(
        context,
        title: 'Delete “${e.name}”?',
        message: 'It will be removed from this program.',
        confirm: 'Delete',
      );
      if (!confirmed) return;
      final deleted = await catalog.deleteExercise(e.id);
      if (!deleted && context.mounted) {
        await infoDialog(
          context,
          title: 'Can’t delete this exercise',
          message: '“${e.name}” has been logged in past sessions, and deleting '
              'it would erase that history. Archive it instead: it disappears '
              'from pickers and your history stays intact.',
        );
      }
  }
}
