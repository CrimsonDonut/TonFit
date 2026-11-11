import 'package:go_router/go_router.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/session/add_exercise_screen.dart';
import '../features/session/choose_program_screen.dart';
import '../features/settings/backup_screen.dart';
import '../features/settings/program_detail_screen.dart';
import '../features/settings/programs_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/year/year_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/programs',
      builder: (context, state) => const ChooseProgramScreen(),
    ),
    GoRoute(
      path: '/session/:id/exercises',
      builder: (context, state) => AddExerciseScreen(
        sessionId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/backup',
      builder: (context, state) => const BackupScreen(),
    ),
    GoRoute(
      path: '/settings/programs',
      builder: (context, state) => const ProgramsScreen(),
    ),
    GoRoute(
      path: '/settings/programs/:id',
      builder: (context, state) => ProgramDetailScreen(
        programId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/year/:year',
      builder: (context, state) => YearScreen(
        year: int.parse(state.pathParameters['year']!),
      ),
    ),
  ],
);
