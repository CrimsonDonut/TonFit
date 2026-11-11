import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/backup/backup_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../domain/backup_format.dart';
import '../../domain/epoch_day.dart';
import '../../domain/weight.dart';
import 'dialogs.dart';

/// Settings > Export / Import: full backup, CSV, restore, and the repair action.
class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  String get _stamp => BackupFormat.dateLabel(EpochDay.today());

  Future<void> _export(
    BuildContext context,
    WidgetRef ref, {
    required bool csv,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      csv
          ? '${dir.path}/tonfit-sets-$_stamp.csv'
          : '${dir.path}/tonfit-backup-$_stamp.json.gz',
    );
    final backup = ref.read(backupRepositoryProvider);
    final settings = <String, Object?>{
      'weightUnit': ref.read(weightUnitProvider).name,
      'weeklyGoal': ref.read(weeklyGoalProvider),
    };

    if (!context.mounted) return;
    await runWithProgress(
      context,
      'Preparing your file...',
      () => csv
          ? backup.exportCsv(file)
          : backup.exportJson(file, settings: settings),
    );

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(file.path, mimeType: csv ? 'text/csv' : 'application/gzip'),
        ],
        subject: csv ? 'TonFit sets' : 'TonFit backup',
      ),
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final picked = await FilePicker.pickFile();
    if (picked == null || !context.mounted) return;

    final backup = ref.read(backupRepositoryProvider);
    final BackupData data;
    try {
      data = backup.read(await picked.readAsBytes());
    } on FormatException catch (e) {
      if (context.mounted) {
        await infoDialog(context, title: 'Can’t restore this file', message: e.message);
      }
      return;
    }
    if (!context.mounted) return;

    final confirmed = await confirmDialog(
      context,
      title: 'Replace all data?',
      message: 'This replaces everything in TonFit with '
          '${Fmt.plural(data.sessions.length, 'session')} '
          '(${Fmt.plural(data.setCount, 'set')}) from this backup. '
          'Your current data will be lost.',
      confirm: 'Replace',
    );
    if (!confirmed || !context.mounted) return;

    final summary = await runWithProgress(
      context,
      'Restoring your data...',
      () => backup.restore(data),
    );

    // Settings that were saved in the backup.
    final unit = data.settings['weightUnit'];
    if (unit == 'kg' || unit == 'lb') {
      await ref
          .read(weightUnitProvider.notifier)
          .set(unit == 'lb' ? WeightUnit.lb : WeightUnit.kg);
    }
    final goal = data.settings['weeklyGoal'];
    if (goal is int) {
      await ref.read(weeklyGoalProvider.notifier).set(goal);
      await ref.read(sessionRepositoryProvider).refreshStreak();
    }

    if (context.mounted) {
      showMessage(
        context,
        'Restored ${Fmt.plural(summary.sessions, 'session')} '
        'and ${Fmt.plural(summary.sets, 'set')}.',
      );
    }
  }

  Future<void> _rebuild(BuildContext context, WidgetRef ref) async {
    await runWithProgress(
      context,
      'Rebuilding summaries...',
      () => ref.read(sessionRepositoryProvider).rebuildAll(),
    );
    if (context.mounted) showMessage(context, 'Summaries rebuilt.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
        children: [
          Text('TONFIT · DATA', style: text.labelSmall),
          const SizedBox(height: 8),
          Text('Export / Import', style: text.headlineLarge),
          const SizedBox(height: 16),
          const Divider(),
          _ActionRow(
            icon: Icons.ios_share,
            title: 'Export full backup',
            subtitle: 'Compressed JSON. Restores everything, including history.',
            onTap: () => _export(context, ref, csv: false),
          ),
          const Divider(),
          _ActionRow(
            icon: Icons.table_chart_outlined,
            title: 'Export sets as CSV',
            subtitle: 'One row per set, for spreadsheets.',
            onTap: () => _export(context, ref, csv: true),
          ),
          const Divider(),
          _ActionRow(
            icon: Icons.file_open_outlined,
            title: 'Restore from backup',
            subtitle: 'Replaces all current data with a backup file.',
            onTap: () => _restore(context, ref),
          ),
          const Divider(),
          const SizedBox(height: 32),
          Text('REPAIR', style: text.labelSmall),
          const SizedBox(height: 8),
          const Divider(),
          _ActionRow(
            icon: Icons.build_outlined,
            title: 'Rebuild summaries',
            subtitle:
                'Recalculates percentages, heatmap, streak and suggestions from your sets. Takes a few seconds on a long history.',
            onTap: () => _rebuild(context, ref),
          ),
          const Divider(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.bodyLarge),
                  const SizedBox(height: 2),
                  Text(subtitle, style: text.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
