import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/dev/synthetic_history.dart';
import 'package:tonfit/domain/backup_format.dart';
import 'package:tonfit/domain/epoch_day.dart';

final end = EpochDay.fromDate(DateTime(2026, 11, 12));
final data = SyntheticHistory.generate(endDay: end);

void main() {
  test('is about ten years and about 100,000 sets', () {
    expect(data.sessions.length, inInclusiveRange(2300, 2800));
    expect(data.setCount, inInclusiveRange(85000, 110000));
    final span = data.sessions.last.day - data.sessions.first.day;
    expect(span, greaterThan(9 * 365));
  });

  test('is the same every time for the same seed, and differs for another', () {
    final again = SyntheticHistory.generate(endDay: end);
    expect(BackupFormat.encode(again), equals(BackupFormat.encode(data)));
    final other = SyntheticHistory.generate(endDay: end, seed: 7);
    expect(BackupFormat.encode(other), isNot(equals(BackupFormat.encode(data))));
  });

  test('is a valid backup: it passes the same checks as a real restore', () {
    final parsed = BackupFormat.parse(BackupFormat.encode(data));
    expect(parsed.sessions.length, equals(data.sessions.length));
    expect(parsed.setCount, equals(data.setCount));
  });

  test('has one session per day, oldest first, never in the future', () {
    final days = [for (final s in data.sessions) s.day];
    expect(days.toSet().length, equals(days.length));
    expect(days, equals([...days]..sort()));
    expect(days.last, lessThanOrEqualTo(end));
  });

  test('rest days fall on days with no session', () {
    final sessionDays = {for (final s in data.sessions) s.day};
    expect(data.restDays, isNotEmpty);
    for (final d in data.restDays) {
      expect(sessionDays.contains(d), isFalse);
      expect(d, lessThanOrEqualTo(end));
    }
  });

  test('every kind of exercise appears, with sensible sets', () {
    final byId = {for (final e in data.exercises) e.id: e};
    final kinds = {for (final e in data.exercises) e.type};
    expect(kinds, equals({'weighted', 'bodyweight', 'timed', 'sport'}));

    for (final s in data.sessions) {
      final seen = <int>{};
      for (final log in s.logs) {
        final ex = byId[log.exerciseId]!;
        expect(seen.add(log.exerciseId), isTrue); // once per session
        expect(log.sets, isNotEmpty);
        for (final set in log.sets) {
          expect(set.reps, greaterThanOrEqualTo(1));
          switch (ex.type) {
            case 'weighted':
              expect(set.weight, greaterThanOrEqualTo(100));
              expect(set.distance, isNull);
            case 'bodyweight':
              expect(set.distance, isNull);
            case 'timed':
            case 'sport':
              expect(set.weight, isNull);
              expect(set.distance != null, equals(ex.tracksDistance));
          }
        }
        if (ex.type == 'sport') expect(log.sets.length, equals(1));
      }
      expect(s.timeOut! > s.timeIn!, isTrue);
    }
  });

  test('strength rises over the years, then levels off', () {
    final bench = data.exercises
        .firstWhere((e) => e.name == 'Bench Press' && e.programId == 1)
        .id;
    double average(int fromYear, int toYear) {
      final loads = <int>[];
      for (final s in data.sessions) {
        final year = EpochDay.toDate(s.day).year;
        if (year < fromYear || year > toYear) continue;
        for (final log in s.logs) {
          if (log.exerciseId == bench) loads.add(log.sets.first.weight!);
        }
      }
      return loads.reduce((a, b) => a + b) / loads.length;
    }

    final early = average(2017, 2018);
    final middle = average(2021, 2022);
    final late = average(2025, 2026);
    expect(middle, greaterThan(early * 1.2));
    expect(late, greaterThan(middle));
    expect(late - middle, lessThan(middle - early)); // gains slow down
  });

  test('programs and exercises are the expected shape', () {
    expect(data.programs.map((p) => p.name).toList(),
        equals(['Push', 'Pull', 'Legs', 'Upper', 'Full Body', 'Cardio']));
    expect(data.exercises.length, greaterThan(40));
    expect(data.exercises.where((e) => e.tracksDistance).map((e) => e.name),
        equals(['Running']));
  });
}
