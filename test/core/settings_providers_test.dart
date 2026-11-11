import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tonfit/core/providers.dart';
import 'package:tonfit/domain/weight.dart';

Future<(ProviderContainer, SharedPreferences)> makeContainer(
  Map<String, Object> initial,
) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return (container, prefs);
}

void main() {
  group('weight unit', () {
    test('defaults to kg', () async {
      final (c, _) = await makeContainer({});
      expect(c.read(weightUnitProvider), equals(WeightUnit.kg));
    });

    test('is saved and restored', () async {
      final (c, prefs) = await makeContainer({});
      await c.read(weightUnitProvider.notifier).set(WeightUnit.lb);
      expect(c.read(weightUnitProvider), equals(WeightUnit.lb));
      expect(prefs.getString('weight_unit'), equals('lb'));

      // A fresh container over the same preferences restores it.
      final again = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(again.dispose);
      expect(again.read(weightUnitProvider), equals(WeightUnit.lb));
    });
  });

  group('weekly goal', () {
    test('defaults to 4', () async {
      final (c, _) = await makeContainer({});
      expect(c.read(weeklyGoalProvider), equals(4));
    });

    test('is saved and clamped to 1-7', () async {
      final (c, prefs) = await makeContainer({});
      await c.read(weeklyGoalProvider.notifier).set(6);
      expect(c.read(weeklyGoalProvider), equals(6));
      expect(prefs.getInt('weekly_goal'), equals(6));

      await c.read(weeklyGoalProvider.notifier).set(0);
      expect(c.read(weeklyGoalProvider), equals(1));
      await c.read(weeklyGoalProvider.notifier).set(99);
      expect(c.read(weeklyGoalProvider), equals(7));
    });

    test('a bad saved value is clamped on load', () async {
      final (c, _) = await makeContainer({'weekly_goal': 42});
      expect(c.read(weeklyGoalProvider), equals(7));
    });
  });
}
