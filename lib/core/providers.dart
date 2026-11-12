import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/epoch_day.dart';
import '../domain/weight.dart';

/// The current local calendar day (epoch-day).
///
/// Rolls over at 12:00 AM using ONE timer scheduled for the next midnight, and
/// re-checks when the app returns to the foreground in case the device was
/// asleep (requirements FR-4). No background service or polling.
class TodayNotifier extends Notifier<int> with WidgetsBindingObserver {
  Timer? _timer;

  @override
  int build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      _timer?.cancel();
      WidgetsBinding.instance.removeObserver(this);
    });
    _schedule();
    return EpochDay.today();
  }

  void _schedule() {
    _timer?.cancel();
    final now = DateTime.now();
    // A second past midnight, so the timer never fires just before it.
    final delay = EpochDay.nextMidnight(now).difference(now) +
        const Duration(seconds: 1);
    _timer = Timer(delay, refresh);
  }

  void refresh() {
    final today = EpochDay.today();
    if (today != state) state = today;
    _schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) refresh();
  }
}

final todayProvider = NotifierProvider<TodayNotifier, int>(TodayNotifier.new);

/// A day the History tab should open (jump to its year and expand it), set
/// after logging a past day. History clears it once it has acted on it.
final pendingExpandDayProvider = StateProvider<int?>((ref) => null);

/// Whether today's row on the dashboard is expanded.
final todayExpandedProvider = StateProvider<bool>((ref) => true);

// -----------------------------------------------------------------------------
// Settings (kept in shared_preferences: small flags only)
// -----------------------------------------------------------------------------

/// Loaded once in main() and injected with an override.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  ),
);

class WeightUnitNotifier extends Notifier<WeightUnit> {
  static const key = 'weight_unit';

  @override
  WeightUnit build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(key);
    return saved == 'lb' ? WeightUnit.lb : WeightUnit.kg;
  }

  Future<void> set(WeightUnit unit) async {
    state = unit;
    await ref.read(sharedPreferencesProvider).setString(key, unit.name);
  }
}

final weightUnitProvider =
    NotifierProvider<WeightUnitNotifier, WeightUnit>(WeightUnitNotifier.new);

class WeeklyGoalNotifier extends Notifier<int> {
  static const key = 'weekly_goal';
  static const int min = 1;
  static const int max = 7;
  static const int defaultGoal = 4;

  static int _clamp(int v) => v < min ? min : (v > max ? max : v);

  @override
  int build() {
    final saved = ref.watch(sharedPreferencesProvider).getInt(key);
    return _clamp(saved ?? defaultGoal);
  }

  Future<void> set(int goal) async {
    final value = _clamp(goal);
    state = value;
    await ref.read(sharedPreferencesProvider).setInt(key, value);
  }
}

final weeklyGoalProvider =
    NotifierProvider<WeeklyGoalNotifier, int>(WeeklyGoalNotifier.new);
