import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/backup/backup_repository.dart';
import '../data/database/database_provider.dart';
import '../data/queries/workout_queries.dart';
import '../data/repositories/session_repository.dart';
import '../domain/epoch_day.dart';
import '../features/settings/dialogs.dart';
import 'benchmark_runner.dart';
import 'stats.dart';
import 'synthetic_history.dart';

/// Developer tools: fill the app with a 10-year history and time the operations
/// the requirements set targets for. Only reachable in debug and profile
/// builds (the route and the Settings row are removed from release builds).
///
/// For honest numbers run it on a real phone in PROFILE mode:
///   flutter run --profile
class DevToolsScreen extends ConsumerStatefulWidget {
  const DevToolsScreen({super.key});

  @override
  ConsumerState<DevToolsScreen> createState() => _DevToolsScreenState();
}

class _DevToolsScreenState extends ConsumerState<DevToolsScreen> {
  String _report = '';

  void _add(String text) => setState(() => _report = '$text\n\n$_report');

  BenchmarkRunner _runner() => BenchmarkRunner(
        db: ref.read(appDatabaseProvider),
        queries: ref.read(workoutQueriesProvider),
        repo: ref.read(sessionRepositoryProvider),
      );

  /// Size of the database file after folding the write-ahead log into it.
  Future<int?> _databaseBytes() async {
    await ref
        .read(appDatabaseProvider)
        .customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/tonfit.sqlite');
    return await file.exists() ? file.length() : null;
  }

  Future<void> _load() async {
    final ok = await confirmDialog(
      context,
      title: 'Replace all data?',
      message: 'This replaces everything in TonFit with about 100,000 generated '
          'sets over ten years. Export a backup first if you want to keep your '
          'own data (Settings > Export / Import).',
      confirm: 'Replace',
    );
    if (!ok || !mounted) return;

    final sw = Stopwatch()..start();
    try {
      final summary = await runWithProgress(
        context,
        'Loading test data. This can take a minute or two...',
        () => ref.read(backupRepositoryProvider).restore(
              SyntheticHistory.generate(endDay: EpochDay.today()),
            ),
      );
      _add('Loaded ${summary.sessions} sessions and ${summary.sets} sets in '
          '${sw.elapsed.inSeconds} s (includes rebuilding every summary).');
    } catch (e) {
      _add('Loading failed: $e');
    }
  }

  Future<void> _benchmark() async {
    try {
      final results = await runWithProgress(
        context,
        'Running the benchmark...',
        () => _runner().run(),
      );
      final size = await _databaseBytes();
      _add(formatReport(
        results,
        dbSizeBytes: size,
        header: 'Benchmark, ${DateTime.now().toIso8601String()}',
      ));
    } catch (e) {
      _add('Benchmark failed: $e');
    }
  }

  Future<void> _rebuild() async {
    try {
      final ms = await runWithProgress(
        context,
        'Rebuilding every summary...',
        () => _runner().timeRebuildAll(),
      );
      _add('Rebuild all summaries took ${(ms / 1000).toStringAsFixed(1)} s.');
    } catch (e) {
      _add('Rebuild failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
        children: [
          Text('TONFIT · DEBUG AND PROFILE ONLY', style: text.labelSmall),
          const SizedBox(height: 8),
          Text('Developer tools', style: text.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Run on a real phone with flutter run --profile for honest numbers.',
            style: text.bodySmall,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _load,
            child: const Text('Load 10-year test data'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _benchmark,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.hairline),
            ),
            child: const Text('Run benchmark'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _rebuild,
            child: const Text('Time “Rebuild summaries” (slow)'),
          ),
          const SizedBox(height: 16),
          if (_report.isNotEmpty) ...[
            Row(
              children: [
                Text('RESULTS', style: text.labelSmall),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _report));
                    if (context.mounted) showMessage(context, 'Copied.');
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy'),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            SelectableText(
              _report,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
