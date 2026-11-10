import 'package:go_router/go_router.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/day/day_screen.dart';
import '../features/session/add_exercise_screen.dart';
import '../features/session/choose_program_screen.dart';

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
      path: '/day/:day',
      builder: (context, state) => DayScreen(
        day: int.parse(state.pathParameters['day']!),
      ),
    ),
  ],
);
