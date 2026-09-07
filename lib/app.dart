import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:score_app/app/core/networks/dio_client.dart';

import 'app/core/router/app_router.dart';
import 'app/features/competitions/data/competitions_repository.dart';
import 'app/features/competitions/providers/competitions_provider.dart';
import 'app/features/fixtures/data/fixtures_repository.dart';
import 'app/features/fixtures/providers/fixtures_provider.dart';
import 'app/features/match_details/data/match_detail_repository.dart';
import 'app/features/match_details/providers/match_detail_provider.dart';
import 'app/features/standings/data/standings_repository.dart';
import 'app/features/standings/providers/standings_provider.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core Network Client
        Provider<DioClient>(create: (_) => DioClient()),

        // Repositories
        ProxyProvider<DioClient, FixturesRepository>(
          update: (_, dioClient, __) =>
              FixturesRepository(dioClient: dioClient),
        ),
        ProxyProvider<DioClient, CompetitionsRepository>(
          update: (_, dioClient, __) =>
              CompetitionsRepository(dioClient: dioClient),
        ),
        ProxyProvider<DioClient, StandingsRepository>(
          update: (_, dioClient, __) =>
              StandingsRepository(dioClient: dioClient),
        ),
        ProxyProvider<DioClient, MatchDetailRepository>(
          update: (_, dioClient, __) =>
              MatchDetailRepository(dioClient: dioClient),
        ),

        // Providers
        ChangeNotifierProxyProvider<FixturesRepository, FixturesProvider>(
          create: (context) =>
              FixturesProvider(repository: context.read<FixturesRepository>()),
          update: (_, repo, previous) =>
              previous ?? FixturesProvider(repository: repo),
        ),
        ChangeNotifierProxyProvider<
          CompetitionsRepository,
          CompetitionsProvider
        >(
          create: (context) => CompetitionsProvider(
            repository: context.read<CompetitionsRepository>(),
          ),
          update: (_, repo, previous) =>
              previous ?? CompetitionsProvider(repository: repo),
        ),
        ChangeNotifierProxyProvider<StandingsRepository, StandingsProvider>(
          create: (context) => StandingsProvider(
            repository: context.read<StandingsRepository>(),
          ),
          update: (_, repo, previous) =>
              previous ?? StandingsProvider(repository: repo),
        ),
        ChangeNotifierProxyProvider<MatchDetailRepository, MatchDetailProvider>(
          create: (context) => MatchDetailProvider(
            repository: context.read<MatchDetailRepository>(),
          ),
          update: (_, repo, previous) =>
              previous ?? MatchDetailProvider(repository: repo),
        ),
      ],
      child: MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
