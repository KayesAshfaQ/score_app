import 'package:go_router/go_router.dart';

import '../../features/fixtures/pages/fixtures_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const FixturesPage()),
      /* GoRoute(
        path: '/competition/:code',
        builder: (context, state) {
          final code = state.pathParameters['code'] ?? 'PL';
          final name = state.extra as String? ?? code;
          return CompetitionDetailPage(competitionCode: code, competitionName: name);
        },
      ),
      GoRoute(
        path: '/match/:id',
        builder: (context, state) {
          final matchId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return MatchDetailPage(matchId: matchId);
        },
      ),
      GoRoute(
        path: '/standings/:code',
        builder: (context, state) {
          final code = state.pathParameters['code'] ?? 'PL';
          return StandingsPage(competitionCode: code);
        },
      ), */
    ],
  );
}
