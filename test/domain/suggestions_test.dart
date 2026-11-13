import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/domain/exercise_type.dart';
import 'package:tonfit/domain/progress.dart';
import 'package:tonfit/domain/suggestions.dart';

ExerciseSession s(int day, List<SetData> sets) =>
    ExerciseSession.fromSets(day, sets);

// 3 x 8 at [kg]
List<SetData> flat(int kg) =>
    [SetData(kg * 100, 8), SetData(kg * 100, 8), SetData(kg * 100, 8)];

SuggestionContext ctx(List<ExerciseSession> newestFirst,
        {String name = 'Overhead Press', PriorBests? prior}) =>
    SuggestionContext(exerciseName: name, history: newestFirst, priorBests: prior);

void main() {
  final engine = SuggestionEngine();

  group('stall', () {
    test('fires after three sessions with no progress (needs 4 logged)', () {
      final hit = engine.evaluate(ctx([
        s(4, flat(40)), s(3, flat(40)), s(2, flat(40)), s(1, flat(40)),
      ]));
      expect(hit?.ruleId, equals('stall'));
      expect(suggestionMessage(hit!), contains('hasn’t progressed in 3 sessions'));
    });

    test('does not fire with only three logged sessions', () {
      final hit = engine.evaluate(ctx([s(3, flat(40)), s(2, flat(40)), s(1, flat(40))]));
      expect(hit, isNull);
    });

    test('identical sets add the tip', () {
      final hit = engine.evaluate(ctx([
        s(4, flat(40)), s(3, flat(40)), s(2, flat(40)), s(1, flat(40)),
      ]));
      expect(hit!.params['identical'], isTrue);
      expect(suggestionMessage(hit), contains('Try adding 1–2 reps'));
    });

    test('varied but flat volume gets no tip', () {
      final hit = engine.evaluate(ctx([
        s(4, [const SetData(4000, 8), const SetData(4000, 8)]),
        s(3, [const SetData(4000, 7), const SetData(4000, 9)]),
        s(2, [const SetData(4000, 9), const SetData(4000, 7)]),
        s(1, [const SetData(4000, 8), const SetData(4000, 8)]),
      ]));
      expect(hit?.ruleId, equals('stall'));
      expect(hit!.params['identical'], isFalse);
      expect(suggestionMessage(hit), isNot(contains('Try adding')));
    });

    test('any improvement inside the window prevents it', () {
      final hit = engine.evaluate(ctx([
        s(4, flat(40)), s(3, flat(40)), s(2, flat(42)), s(1, flat(40)),
      ]));
      expect(hit, isNull);
    });
  });

  group('timed exercises', () {
    List<SetData> hold(int seconds) =>
        [SetData(null, seconds), SetData(null, seconds)];

    ExerciseSession plank(int day, int seconds) =>
        ExerciseSession.fromSets(day, hold(seconds), type: ExerciseType.timed);

    test('a stall talks about time, not reps', () {
      final hit = engine.evaluate(SuggestionContext(
        exerciseName: 'Plank',
        timeBased: true,
        history: [plank(4, 60), plank(3, 60), plank(2, 60), plank(1, 60)],
      ));
      expect(hit?.ruleId, equals('stall'));
      final message = suggestionMessage(hit!);
      expect(message, contains('Try adding 5–10 seconds'));
      expect(message, isNot(contains('reps')));
    });

    test('a longer hold than ever before is a personal best', () {
      final hit = engine.evaluate(SuggestionContext(
        exerciseName: 'Plank',
        timeBased: true,
        history: [plank(2, 90)],
        priorBests: const PriorBests(maxWeight: 0, repsAtMaxWeight: 60),
      ));
      expect(hit?.ruleId, equals('pr'));
    });
  });

  group('decline and large drop', () {
    test('two consecutive declines', () {
      final hit = engine.evaluate(ctx([s(3, flat(38)), s(2, flat(39)), s(1, flat(40))]));
      expect(hit?.ruleId, equals('decline'));
    });

    test('one small drop is not enough', () {
      final hit = engine.evaluate(ctx([s(2, flat(39)), s(1, flat(40))]));
      expect(hit, isNull);
    });

    test('drop of more than 15% fires large_drop, and wins over decline', () {
      final hit = engine.evaluate(ctx([s(3, flat(30)), s(2, flat(39)), s(1, flat(40))]));
      expect(hit?.ruleId, equals('large_drop'));
      expect(suggestionMessage(hit!), contains('Tough session'));
    });

    test('exactly 15% is not a large drop', () {
      // 40 kg -> 34 kg is -15.0%
      final hit = engine.evaluate(ctx([s(2, flat(34)), s(1, flat(40))]));
      expect(hit, isNull);
    });
  });

  group('personal best', () {
    const prior = PriorBests(maxWeight: 6000, repsAtMaxWeight: 8);

    test('heavier weight', () {
      final hit = engine.evaluate(ctx(
        [s(2, [const SetData(6250, 5)]), s(1, flat(60))],
        name: 'Bench Press',
        prior: prior,
      ));
      expect(hit?.ruleId, equals('pr'));
      expect(hit!.params['kind'], equals('weight'));
      expect(suggestionMessage(hit), equals('New PR on Bench Press.'));
    });

    test('more reps at the same top weight', () {
      final hit = engine.evaluate(ctx(
        [s(2, [const SetData(6000, 9)]), s(1, flat(60))],
        prior: prior,
      ));
      expect(hit?.params['kind'], equals('reps'));
    });

    test('equalling the best is not a PR', () {
      final hit = engine.evaluate(ctx([s(2, [const SetData(6000, 8)])], prior: prior));
      expect(hit, isNull);
    });

    test('no PR message without prior history', () {
      final hit = engine.evaluate(ctx([s(1, flat(60))]));
      expect(hit, isNull);
    });

    test('bodyweight PR is judged on reps', () {
      final hit = engine.evaluate(ctx(
        [
          ExerciseSession.fromSets(2, const [SetData(null, 12)], type: ExerciseType.bodyweight),
        ],
        name: 'Pull-Up',
        prior: const PriorBests(maxWeight: 0, repsAtMaxWeight: 10),
      ));
      expect(hit?.ruleId, equals('pr'));
    });
  });

  group('session level', () {
    test('at most three messages, best priority first, ties keep order', () {
      SuggestionContext decline(String n) =>
          ctx([s(3, flat(38)), s(2, flat(39)), s(1, flat(40))], name: n);
      final pr = ctx(
        [s(2, [const SetData(7000, 5)])],
        name: 'Squat',
        prior: const PriorBests(maxWeight: 6000, repsAtMaxWeight: 8),
      );
      final hits = engine.evaluateSession([
        decline('A'), decline('B'), decline('C'), pr,
      ]);
      expect(hits.length, equals(3));
      expect(hits.map((h) => h.exerciseName).toList(), equals(['Squat', 'A', 'B']));
    });

    test('nothing fires on a quiet day', () {
      expect(engine.evaluateSession([ctx([s(1, flat(40))])]), isEmpty);
    });
  });

  group('rules are data', () {
    test('a custom rule can be added without touching the engine', () {
      final custom = SuggestionEngine(rules: [
        ...defaultSuggestionRules,
        SuggestionRule(
          id: 'low_calories',
          priority: 0,
          check: (c, cfg) => c.extras['calorieDeficit'] == true ? {} : null,
        ),
      ]);
      final hit = custom.evaluate(const SuggestionContext(
        exerciseName: 'Squat',
        history: [],
        extras: {'calorieDeficit': true},
      ));
      expect(hit?.ruleId, equals('low_calories'));
    });
  });
}
