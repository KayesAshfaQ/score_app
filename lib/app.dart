import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:score_app/app/core/networks/dio_client.dart';
import 'package:score_app/app/core/theme/app_theme.dart';

import 'app/core/router/app_router.dart';
import 'app/features/competitions/data/competitions_repository.dart';
import 'app/features/competitions/providers/competitions_provider.dart';
import 'app/features/fixtures/data/fixtures_repository.dart';
import 'app/features/fixtures/providers/fixtures_provider.dart';
import 'app/features/match_details/data/match_detail_repository.dart';
import 'app/features/match_details/providers/match_detail_provider.dart';
import 'app/features/notifications/providers/notification_provider.dart';
import 'app/features/standings/data/standings_repository.dart';
import 'app/features/standings/providers/standings_provider.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core Firestore Client
        Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),

        // Core Network Client
        Provider<DioClient>(create: (_) => DioClient()),

        // Repositories
        ProxyProvider<FirebaseFirestore, FixturesRepository>(
          update: (_, firestore, _) =>
              FixturesRepository(firestore: firestore),
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
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider()..loadPreferences(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Scora Live Scores',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
