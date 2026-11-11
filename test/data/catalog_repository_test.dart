import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/data/database/app_database.dart';
import 'package:tonfit/data/database/tables.dart';
import 'package:tonfit/data/queries/workout_queries.dart';
import 'package:tonfit/data/repositories/catalog_repository.dart';
import 'package:tonfit/data/repositories/session_repository.dart';

late AppDatabase db;
late CatalogRepository catalog;

Future<int> programId(String name) async => (await (db.select(db.programs)
          ..where((t) => t.name.equals(name)))
        .getSingle())
    .id;

Future<Exercise> exercise(String program, String name) async {
  final pid = await programId(program);
  return (db.select(db.exercises)
        ..where((t) => t.programId.equals(pid) & t.name.equals(name)))
      .getSingle();
}

void main() {
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    catalog = CatalogRepository(db);
  });
  tearDown(() => db.close());

  group('programs', () {
    test('rename rejects a name used by another program, ignoring case', () async {
      final pull = await programId('Pull');
      expect(await catalog.renameProgram(pull, 'push'), isFalse);
      expect((await db.select(db.programs).get()).map((p) => p.name),
          contains('Pull'));
    });

    test('rename accepts a new name and a case change of its own name', () async {
      final pull = await programId('Pull');
      expect(await catalog.renameProgram(pull, '  Pull Day '), isTrue);
      var row = await (db.select(db.programs)..where((t) => t.id.equals(pull))).getSingle();
      expect(row.name, equals('Pull Day'));
      expect(row.nameKey, equals('pull day'));

      expect(await catalog.renameProgram(pull, 'PULL DAY'), isTrue);
      row = await (db.select(db.programs)..where((t) => t.id.equals(pull))).getSingle();
      expect(row.name, equals('PULL DAY'));
    });

    test('empty and over-long names are refused', () async {
      final pull = await programId('Pull');
      expect(await catalog.renameProgram(pull, '   '), isFalse);
      expect(await catalog.renameProgram(pull, 'x' * 41), isFalse);
    });

    test('archived programs leave the picker but stay listed in settings', () async {
      final legs = await programId('Legs');
      await catalog.setProgramArchived(legs, true);
      final queries = WorkoutQueries(db);

      final picker = await queries.loadPrograms();
      expect(picker.map((p) => p.program.name), isNot(contains('Legs')));
      final all = await queries.loadPrograms(includeArchived: true);
      expect(all.map((p) => p.program.name), contains('Legs'));

      await catalog.setProgramArchived(legs, false);
      expect((await queries.loadPrograms()).map((p) => p.program.name), contains('Legs'));
    });

    test('creating an existing name returns the existing program', () async {
      final push = await programId('Push');
      expect(await catalog.createProgram('PUSH'), equals(push));
      expect((await db.select(db.programs).get()).length, equals(5));
    });
  });

  group('exercises', () {
    test('names are unique within a program but may repeat across programs', () async {
      final dips = await exercise('Push', 'Dips');
      expect(await catalog.renameExercise(dips.id, 'bench press'), isFalse);

      final facePull = await exercise('Pull', 'Face Pull');
      expect(await catalog.renameExercise(facePull.id, 'Bench Press'), isTrue);
    });

    test('archived exercises disappear from the session picker', () async {
      final dips = await exercise('Push', 'Dips');
      final repo = SessionRepository(db, clock: () => DateTime(2026, 10, 19, 18));
      final sid = await repo.startSession(programId: await programId('Push'));
      final queries = WorkoutQueries(db);

      var picker = await queries.loadExercisePicker(sid);
      expect(picker.options.map((o) => o.exercise.name), contains('Dips'));

      await catalog.setExerciseArchived(dips.id, true);
      picker = await queries.loadExercisePicker(sid);
      expect(picker.options.map((o) => o.exercise.name), isNot(contains('Dips')));
    });

    test('creating an exercise twice returns the same one', () async {
      final push = await programId('Push');
      final a = await catalog.createExercise(
          programId: push, name: 'Cable Fly', type: ExerciseType.weighted);
      final b = await catalog.createExercise(
          programId: push, name: 'cable fly', type: ExerciseType.bodyweight);
      expect(a, equals(b));
    });
  });
}
