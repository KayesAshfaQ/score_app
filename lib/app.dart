import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:score_app/app/core/networks/dio_client.dart';

import 'app/core/router/app_router.dart';
import 'app/features/fixtures/data/fixtures_repository.dart';
import 'app/features/fixtures/providers/fixtures_provider.dart';

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

        // Providers
        ChangeNotifierProxyProvider<FixturesRepository, FixturesProvider>(
          create: (context) =>
              FixturesProvider(repository: context.read<FixturesRepository>()),
          update: (_, repo, previous) =>
              previous ?? FixturesProvider(repository: repo),
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
