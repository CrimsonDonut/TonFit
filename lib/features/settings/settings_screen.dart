import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_info.dart';
import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/session_repository.dart';
import '../../domain/weight.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _changeGoal(WidgetRef ref, int goal) async {
    await ref.read(weeklyGoalProvider.notifier).set(goal);
    // The streak is always measured against the current goal.
    await ref.read(sessionRepositoryProvider).refreshStreak();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final unit = ref.watch(weightUnitProvider);
    final goal = ref.watch(weeklyGoalProvider);

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
        children: [
          Text('TONFIT · PREFERENCES', style: text.labelSmall),
          const SizedBox(height: 8),
          Text('Settings', style: text.headlineLarge),
          const SizedBox(height: 16),
          const Divider(),
          _SettingRow(
            title: 'Weight unit',
            subtitle: 'Used for entry and display',
            trailing: SegmentedButton<WeightUnit>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
                ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
              ],
              selected: {unit},
              onSelectionChanged: (s) =>
                  ref.read(weightUnitProvider.notifier).set(s.first),
            ),
          ),
          const Divider(),
          _SettingRow(
            title: 'Weekly goal',
            subtitle: '${Fmt.plural(goal, 'session')} per week',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed:
                      goal > WeeklyGoalNotifier.min ? () => _changeGoal(ref, goal - 1) : null,
                ),
                SizedBox(
                  width: 24,
                  child: Center(child: Text('$goal', style: text.titleMedium)),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed:
                      goal < WeeklyGoalNotifier.max ? () => _changeGoal(ref, goal + 1) : null,
                ),
              ],
            ),
          ),
          const Divider(),
          _NavRow(
            title: 'Programs',
            subtitle: 'Create, rename and archive programs and exercises',
            onTap: () => context.push('/settings/programs'),
          ),
          const Divider(),
          const SizedBox(height: 48),
          Center(child: Text('TonFit v$appVersion', style: text.bodySmall)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
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
          trailing,
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

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
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
