import 'package:drift/drift.dart';

import '../../domain/exercise_type.dart';

// The exercise kinds live in the domain layer (they are plain rules, not
// database details). Re-exported so existing imports of this file keep working.
export '../../domain/exercise_type.dart';

// Database tables (requirements, section 5).
//
// Units used everywhere:
//   dates       -> integer epoch-days of the LOCAL calendar date
//   timestamps  -> integer epoch-seconds
//   weight      -> integer hundredths of a kilogram (60 kg = 6000)
//   percentages -> integer tenths of a percent (+3.8% = 38)
//   volume      -> sum of (weight x reps), in weight units x reps
//
// SET_ENTRY is the source of truth. Every other "summary" column is a cache
// that can be rebuilt from it (requirements NFR-10).

@DataClassName('Program')
class Programs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();

  /// Lower-cased name, used to keep names unique ignoring case.
  TextColumn get nameKey => text().unique()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

@DataClassName('Exercise')
class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get programId => integer().references(Programs, #id)();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get nameKey => text()();
  IntColumn get type => intEnum<ExerciseType>()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  /// Timed and sport exercises can also record a distance for each set (running,
  /// jogging, cycling). Progress is then measured in distance.
  BoolColumn get tracksDistance => boolean().withDefault(const Constant(false))();

  // An exercise belongs to one program, so its history and comparisons are
  // per program automatically. Names are unique within a program.
  @override
  List<Set<Column>> get uniqueKeys => [
        {programId, nameKey},
      ];
}

@TableIndex(name: 'session_program_day', columns: {#programId, #day})
@DataClassName('Session')
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Local calendar date as epoch-day. Unique: one session per day in the MVP.
  /// To allow several sessions per day later, drop this unique key.
  IntColumn get day => integer()();
  IntColumn get programId => integer().references(Programs, #id)();
  IntColumn get timeIn => integer().nullable()();
  IntColumn get timeOut => integer().nullable()();

  // Cached values
  IntColumn get volume => integer().withDefault(const Constant(0))();
  IntColumn get setCount => integer().withDefault(const Constant(0))();
  IntColumn get summaryPct => integer().nullable()(); // null = "New"
  IntColumn get prevSessionId => integer()
      .nullable()
      .references(Sessions, #id, onDelete: KeyAction.setNull)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {day},
      ];
}

@TableIndex(name: 'exercise_log_exercise_day', columns: {#exerciseId, #day})
@DataClassName('ExerciseLog')
class ExerciseLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();

  /// Copy of the session's day, so exercise history is one indexed lookup.
  IntColumn get day => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  // Cached values
  IntColumn get volume => integer().withDefault(const Constant(0))();
  IntColumn get setCount => integer().withDefault(const Constant(0))();
  IntColumn get bestWeight => integer().nullable()();

  /// Most reps in one set at [bestWeight]. Used for personal-best detection.
  IntColumn get repsAtTop => integer().withDefault(const Constant(0))();
  IntColumn get pct => integer().nullable()(); // null = "New"
  IntColumn get prevLogId => integer()
      .nullable()
      .references(ExerciseLogs, #id, onDelete: KeyAction.setNull)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {sessionId, exerciseId},
      ];
}

@DataClassName('SetEntry')
class SetEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get exerciseLogId =>
      integer().references(ExerciseLogs, #id, onDelete: KeyAction.cascade)();

  /// 1-based position within the exercise; shown as "1.", "2.", ...
  IntColumn get idx => integer()();

  /// Null for pure bodyweight sets and for timed and sport exercises. For
  /// "BW + 10 kg" this holds the added weight.
  IntColumn get weight => integer().nullable()();
  /// Repetitions, or for timed and sport exercises the duration in seconds.
  IntColumn get reps => integer()();

  /// Whole metres, for timed and sport exercises that track distance.
  IntColumn get distance => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {exerciseLogId, idx},
      ];
}

/// One row per day that has a session or a rest mark. Feeds the heatmap
/// and the month list.
@DataClassName('DaySummary')
class DaySummaries extends Table {
  IntColumn get day => integer()();
  IntColumn get sessionId =>
      integer().nullable().references(Sessions, #id, onDelete: KeyAction.setNull)();
  IntColumn get setCount => integer().withDefault(const Constant(0))();
  BoolColumn get isRest => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {day};
}

/// Sessions per week (weeks start Monday), for the streak.
@DataClassName('WeekSummary')
class WeekSummaries extends Table {
  /// Epoch-day of the Monday that starts the week.
  IntColumn get weekStart => integer()();
  IntColumn get sessionCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {weekStart};
}

@DataClassName('ExerciseStat')
class ExerciseStats extends Table {
  IntColumn get exerciseId =>
      integer().references(Exercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get bestWeight => integer().nullable()();
  IntColumn get bestRepsAtWeight => integer().nullable()();
  IntColumn get bestVolume => integer().withDefault(const Constant(0))();
  IntColumn get lastLogId => integer()
      .nullable()
      .references(ExerciseLogs, #id, onDelete: KeyAction.setNull)();

  @override
  Set<Column> get primaryKey => {exerciseId};
}

/// Stored suggestion messages, so the day card reads them without recomputing.
@TableIndex(name: 'suggestion_session', columns: {#sessionId})
@DataClassName('Suggestion')
class Suggestions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseLogId => integer()
      .nullable()
      .references(ExerciseLogs, #id, onDelete: KeyAction.cascade)();
  TextColumn get ruleId => text()();
  IntColumn get priority => integer()();

  /// JSON with the values needed to render the message text.
  TextColumn get params => text().withDefault(const Constant('{}'))();
}

/// Single row (id = 1).
@DataClassName('StreakState')
class StreakStates extends Table {
  IntColumn get id => integer()();
  IntColumn get currentWeeks => integer().withDefault(const Constant(0))();
  IntColumn get longestWeeks => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Reserved for the future calorie tracker. Empty in the MVP.
@DataClassName('NutritionDay')
class NutritionDays extends Table {
  IntColumn get day => integer()();
  IntColumn get calories => integer().nullable()();
  IntColumn get protein => integer().nullable()();

  @override
  Set<Column> get primaryKey => {day};
}
