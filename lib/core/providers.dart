import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Weight unit. A settings screen will change this later.
final weightUnitProvider = StateProvider<WeightUnit>((ref) => WeightUnit.kg);

/// Whether today's row on the dashboard is expanded.
final todayExpandedProvider = StateProvider<bool>((ref) => true);
