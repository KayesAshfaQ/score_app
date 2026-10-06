import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_theme.dart';
import '../../notifications/providers/notification_provider.dart';
import '../providers/match_detail_provider.dart';

class MatchDetailPage extends StatefulWidget {
  final int matchId;

  const MatchDetailPage({super.key, required this.matchId});

  @override
  State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<MatchDetailProvider>().fetchMatchDetail(widget.matchId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Details'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notifProvider, _) {
              final isSubscribed = notifProvider.isMatchSubscribed(
                widget.matchId,
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
                    ? 'Turn off match alerts'
                    : 'Turn on match alerts',
                onPressed: () async {
                  final enabled = await notifProvider.toggleMatchSubscription(
                    widget.matchId,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          enabled
                              ? 'Live match alerts enabled for this fixture!'
                              : 'Live match alerts turned off.',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<MatchDetailProvider>(
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
                      onPressed: () =>
                          provider.fetchMatchDetail(widget.matchId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final match = provider.match;
          if (match == null) {
            return const Center(
              child: Text(
                'Match not found',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header Score Board Card
                _buildHeaderCard(match),
                const SizedBox(height: 20),

                // Match Info Card
                _buildInfoCard(match),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(MatchModel match) {
    final localTime = match.utcDate.toLocal();
    final dateStr = DateFormat('EEE, d MMM yyyy · HH:mm').format(localTime);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Competition name
          Text(
            match.competition.name,
            style: const TextStyle(
              color: AppTheme.accentBlue,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 24),

          // Score / Crests Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home Team
              Expanded(
                child: Column(
                  children: [
                    _buildCrest(match.homeTeam.crest, size: 54),
                    const SizedBox(height: 10),
                    Text(
                      match.homeTeam.displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              // Score in Center
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (match.status.isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.liveRed.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          match.minute != null ? "${match.minute}'" : 'LIVE',
                          style: const TextStyle(
                            color: AppTheme.liveRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )
                    else if (match.status.isFinished)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackgroundLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'FT',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      match.status.isFinished || match.status.isLive
                          ? match.score.displayScore()
                          : DateFormat('HH:mm').format(localTime),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),

              // Away Team
              Expanded(
                child: Column(
                  children: [
                    _buildCrest(match.awayTeam.crest, size: 54),
                    const SizedBox(height: 10),
                    Text(
                      match.awayTeam.displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (match.score.halfTime.home != null) ...[
            const SizedBox(height: 20),
            Text(
              'Half Time: ${match.score.halfTime.home} - ${match.score.halfTime.away}',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(MatchModel match) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Match Information',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.dividerColor),
          if (match.venue != null) _buildInfoRow('Venue', match.venue!),
          if (match.matchday != null)
            _buildInfoRow('Matchday', 'Matchday ${match.matchday}'),
          if (match.stage != null)
            _buildInfoRow('Stage', match.stage!.replaceAll('_', ' ')),
          _buildInfoRow('Status', match.status.name.toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrest(String? url, {double size = 40}) {
    if (url == null || url.isEmpty) {
      return Icon(Icons.sports_soccer, size: size, color: AppTheme.textMuted);
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorWidget: (_, _, _) =>
          Icon(Icons.sports_soccer, size: size, color: AppTheme.textMuted),
    );
  }
}
