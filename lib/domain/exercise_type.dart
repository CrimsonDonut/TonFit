/// The kinds of exercise TonFit can log.
///
/// The order is stored in the database as a number, so new kinds are only ever
/// appended, never inserted or reordered.
enum ExerciseType {
  /// Weight x reps: bench press, squat.
  weighted,

  /// Reps, with optional added weight: pull-ups, dips.
  bodyweight,

  /// A duration per set: cardio (running, rowing) and isometric holds (plank).
  timed,

  /// Time spent playing a sport, such as basketball. No sets to compare, so
  /// there is no percentage and no suggestions.
  sport;

  /// Logged as weight and reps (weighted and bodyweight).
  bool get isStrength => this == weighted || this == bodyweight;

  /// Logged as a duration. The duration in seconds is stored in a set's
  /// `reps` field, and its weight is empty.
  bool get isTimeBased => this == timed || this == sport;

  /// Whether sessions are compared with the previous one for this exercise.
  bool get tracksProgress => this != sport;

  String get label => switch (this) {
        weighted => 'Weighted',
        bodyweight => 'Bodyweight',
        timed => 'Timed',
        sport => 'Sport',
      };

  /// One line for the picker, with examples.
  String get description => switch (this) {
        weighted => 'Weight × reps. Bench press, squat.',
        bodyweight => 'Reps, with optional added weight. Pull-ups, dips.',
        timed => 'Time per set. Running, rowing, plank, wall sit.',
        sport => 'Time played, with no sets. Basketball, football.',
      };
}
