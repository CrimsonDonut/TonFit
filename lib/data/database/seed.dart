import 'package:drift/drift.dart';

import 'app_database.dart';
import 'tables.dart';

class _Ex {
  const _Ex(this.name, [this.type = ExerciseType.weighted]);
  final String name;
  final ExerciseType type;
}

/// Starter data (requirements FR-30). Small text only, no media.
const _starterPrograms = <String, List<_Ex>>{
  'Push': [
    _Ex('Bench Press'),
    _Ex('Incline Dumbbell Press'),
    _Ex('Overhead Press'),
    _Ex('Lateral Raise'),
    _Ex('Triceps Pushdown'),
    _Ex('Dips', ExerciseType.bodyweight),
  ],
  'Pull': [
    _Ex('Pull-Up', ExerciseType.bodyweight),
    _Ex('Barbell Row'),
    _Ex('Lat Pulldown'),
    _Ex('Seated Cable Row'),
    _Ex('Face Pull'),
    _Ex('Biceps Curl'),
  ],
  'Legs': [
    _Ex('Squat'),
    _Ex('Romanian Deadlift'),
    _Ex('Leg Press'),
    _Ex('Leg Curl'),
    _Ex('Calf Raise'),
    _Ex('Lunge'),
  ],
  'Upper': [
    _Ex('Bench Press'),
    _Ex('Barbell Row'),
    _Ex('Overhead Press'),
    _Ex('Lat Pulldown'),
    _Ex('Biceps Curl'),
    _Ex('Triceps Pushdown'),
    _Ex('Lateral Raise'),
  ],
  'Full Body': [
    _Ex('Squat'),
    _Ex('Bench Press'),
    _Ex('Barbell Row'),
    _Ex('Overhead Press'),
    _Ex('Romanian Deadlift'),
    _Ex('Pull-Up', ExerciseType.bodyweight),
    _Ex('Lunge'),
  ],
};

/// Runs once, when the database file is first created. Called from onCreate,
/// which already runs inside a transaction.
Future<void> seedDefaults(AppDatabase db) async {
  var order = 0;
  for (final entry in _starterPrograms.entries) {
    final programId = await db.into(db.programs).insert(
          ProgramsCompanion.insert(
            name: entry.key,
            nameKey: entry.key.toLowerCase(),
            sortOrder: Value(order++),
          ),
        );
    for (final ex in entry.value) {
      await db.into(db.exercises).insert(
            ExercisesCompanion.insert(
              programId: programId,
              name: ex.name,
              nameKey: ex.name.toLowerCase(),
              type: ex.type,
            ),
          );
    }
  }

  // The single streak row.
await db.into(db.streakStates).insert(StreakStatesCompanion.insert(id: const Value(1)));
}
