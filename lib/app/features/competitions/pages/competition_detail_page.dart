import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../fixtures/widgets/match_card.dart';
import '../../notifications/providers/notification_provider.dart';
import '../providers/competitions_provider.dart';

class CompetitionDetailPage extends StatefulWidget {
  final String competitionCode;
  final String competitionName;

  const CompetitionDetailPage({
    super.key,
    required this.competitionCode,
    required this.competitionName,
  });

  @override
  State<CompetitionDetailPage> createState() => _CompetitionDetailPageState();
}

class _CompetitionDetailPageState extends State<CompetitionDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<CompetitionsProvider>().fetchCompetitionMatches(
          widget.competitionCode,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.competitionName),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notifProvider, _) {
              final isSubscribed = notifProvider.isCompetitionSubscribed(
                widget.competitionCode,
              );
              return IconButton(
                icon: Icon(
                  isSubscribed
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  color: isSubscribed
                      ? AppTheme.accentBlue
                      : AppTheme.textSecondary,
                ),
                tooltip: isSubscribed
                    ? 'Turn off league alerts'
                    : 'Turn on league alerts',
                onPressed: () async {
                  final enabled = await notifProvider
                      .toggleCompetitionSubscription(widget.competitionCode);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          enabled
                              ? 'Alerts enabled for ${widget.competitionName}!'
                              : 'Alerts disabled for ${widget.competitionName}.',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.table_chart_outlined),
            tooltip: 'View Standings',
            onPressed: () {
              context.push('/standings/${widget.competitionCode}');
            },
          ),
        ],
      ),
      body: Consumer<CompetitionsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accentBlue),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppTheme.liveRed,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(provider.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchCompetitionMatches(
                        widget.competitionCode,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.matches.isEmpty) {
            return const Center(
              child: Text(
                'No matches available',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: provider.matches.length,
            itemBuilder: (context, index) {
              final match = provider.matches[index];
              return MatchCard(
                match: match,
                onTap: () => context.push('/match/${match.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
