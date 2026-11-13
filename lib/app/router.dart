import 'package:go_router/go_router.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/history/history_screen.dart';
import '../features/session/add_exercise_screen.dart';
import '../features/session/choose_program_screen.dart';
import '../features/settings/backup_screen.dart';
import '../features/settings/program_detail_screen.dart';
import '../features/settings/programs_screen.dart';
import '../features/settings/settings_screen.dart';
import 'app_shell.dart';

final appRouter = GoRouter(
  routes: [
    // The two main tabs share a top bar and a bottom navigation bar.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
      ],
    ),

    // Full-screen flows, pushed above the tabs.
    GoRoute(
      path: '/programs',
      builder: (context, state) => ChooseProgramScreen(
        day: int.tryParse(state.uri.queryParameters['day'] ?? ''),
      ),
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
      path: '/my-programs',
      builder: (context, state) => const ProgramsScreen(),
    ),
    GoRoute(
      path: '/my-programs/:id',
      builder: (context, state) => ProgramDetailScreen(
        programId: int.parse(state.pathParameters['id']!),
      ),
    ),
  ],
);
