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
}

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(ref.watch(appDatabaseProvider)),
);
