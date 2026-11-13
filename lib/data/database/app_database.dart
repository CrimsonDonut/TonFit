import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'seed.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Programs,
    Exercises,
    Sessions,
    ExerciseLogs,
    SetEntries,
    DaySummaries,
    WeekSummaries,
    ExerciseStats,
    Suggestions,
    StreakStates,
    NutritionDays,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Pass an executor in tests (e.g. an in-memory database).
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// Version 1 is the schema of the first public release. From then on, any
  /// change to tables.dart needs: schemaVersion + 1, a new `if (from < N)`
  /// block in onUpgrade below, and a migration test (see docs/RELEASE.md).
  /// Never edit an old block: users upgrade from every version they ever had.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await seedDefaults(this);
        },
        onUpgrade: (m, from, to) async {
          // Example for a future version 2 that adds a column:
          //   if (from < 2) {
          //     await m.addColumn(setEntries, setEntries.someNewColumn);
          //   }
          // Nothing to do yet: version 1 is the first released schema.
        },
        beforeOpen: (details) async {
          // Needed for the ON DELETE CASCADE / SET NULL rules in tables.dart.
          await customStatement('PRAGMA foreign_keys = ON');
          // Write-ahead logging: faster writes, readers don't block the writer.
          await customStatement('PRAGMA journal_mode = WAL');
        },
      );

  /// Opens the database file in a background isolate, so queries never block
  /// the UI thread (requirements NFR-3).
  static QueryExecutor _openConnection() => driftDatabase(name: 'tonfit');
}
