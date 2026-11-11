import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../database/tables.dart';

/// Creating programs and exercises. Names are unique ignoring case: asking for
/// a name that already exists returns the existing row's id instead.
class CatalogRepository {
  CatalogRepository(this.db);
  final AppDatabase db;

  Future<int> createProgram(String name) {
    return db.transaction(() async {
      final clean = name.trim();
      if (clean.isEmpty) throw ArgumentError('Program name is empty');
      final key = clean.toLowerCase();

      final existing = await (db.select(db.programs)
            ..where((t) => t.nameKey.equals(key)))
          .getSingleOrNull();
      if (existing != null) return existing.id;

      final maxOrder = db.programs.sortOrder.max();
      final row =
          await (db.selectOnly(db.programs)..addColumns([maxOrder])).getSingle();
      return db.into(db.programs).insert(
            ProgramsCompanion.insert(
              name: clean,
              nameKey: key,
              sortOrder: Value((row.read(maxOrder) ?? -1) + 1),
            ),
          );
    });
  }

  Future<int> createExercise({
    required int programId,
    required String name,
    required ExerciseType type,
  }) {
    return db.transaction(() async {
      final clean = name.trim();
      if (clean.isEmpty) throw ArgumentError('Exercise name is empty');
      final key = clean.toLowerCase();

      final existing = await (db.select(db.exercises)
            ..where((t) => t.programId.equals(programId) & t.nameKey.equals(key)))
          .getSingleOrNull();
      if (existing != null) return existing.id;

      return db.into(db.exercises).insert(
            ExercisesCompanion.insert(
              programId: programId,
              name: clean,
              nameKey: key,
              type: type,
            ),
          );
    });
  }

  static const int maxProgramName = 40;
  static const int maxExerciseName = 60;

  /// Renames a program. Returns false (and changes nothing) when the name is
  /// empty, too long, or already used by another program (ignoring case).
  Future<bool> renameProgram(int id, String name) {
    return db.transaction(() async {
      final clean = name.trim();
      if (clean.isEmpty || clean.length > maxProgramName) return false;
      final key = clean.toLowerCase();
      final clash = await (db.select(db.programs)
            ..where((t) => t.nameKey.equals(key) & t.id.equals(id).not()))
          .getSingleOrNull();
      if (clash != null) return false;
      await (db.update(db.programs)..where((t) => t.id.equals(id)))
          .write(ProgramsCompanion(name: Value(clean), nameKey: Value(key)));
      return true;
    });
  }

  /// Archived programs disappear from pickers but stay in history.
  Future<void> setProgramArchived(int id, bool archived) =>
      (db.update(db.programs)..where((t) => t.id.equals(id)))
          .write(ProgramsCompanion(archived: Value(archived)));

  /// Renames an exercise. Names are unique within a program, so the same name
  /// may exist in another program. Returns false when it can't be used.
  Future<bool> renameExercise(int id, String name) {
    return db.transaction(() async {
      final clean = name.trim();
      if (clean.isEmpty || clean.length > maxExerciseName) return false;
      final key = clean.toLowerCase();
      final exercise = await (db.select(db.exercises)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      final clash = await (db.select(db.exercises)
            ..where((t) =>
                t.programId.equals(exercise.programId) &
                t.nameKey.equals(key) &
                t.id.equals(id).not()))
          .getSingleOrNull();
      if (clash != null) return false;
      await (db.update(db.exercises)..where((t) => t.id.equals(id)))
          .write(ExercisesCompanion(name: Value(clean), nameKey: Value(key)));
      return true;
    });
  }

  Future<void> setExerciseArchived(int id, bool archived) =>
      (db.update(db.exercises)..where((t) => t.id.equals(id)))
          .write(ExercisesCompanion(archived: Value(archived)));
}

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(ref.watch(appDatabaseProvider)),
);
