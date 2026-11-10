import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// One database for the whole app, closed when the provider container is disposed.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
