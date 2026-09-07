import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/match_model.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback? onTap;

  const MatchCard({super.key, required this.match, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: AppTheme.cardBackground,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Home Team
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        match.homeTeam.displayName,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildCrest(match.homeTeam.crest),
                  ],
                ),
              ),

              // Center Score / Status
              Container(
                width: 80,
                alignment: Alignment.center,
                child: _buildCenterStatus(),
              ),

              // Away Team
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildCrest(match.awayTeam.crest),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        match.awayTeam.displayName,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterStatus() {
    if (match.status.isLive) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.liveRed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              match.minute != null ? "${match.minute}'" : 'LIVE',
              style: const TextStyle(
                color: AppTheme.liveRed,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            match.score.displayScore(isLive: true),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      );
    } else if (match.status.isFinished) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.cardBackgroundLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'FT',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            match.score.displayScore(),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      );
    } else {
      // Scheduled / Timed
      final localTime = match.utcDate.toLocal();
      final timeStr = DateFormat('HH:mm').format(localTime);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            timeStr,
            style: const TextStyle(
              color: AppTheme.accentBlue,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          if (match.status == MatchStatus.postponed)
            const Text(
              'POSTP',
              style: TextStyle(color: AppTheme.liveRed, fontSize: 10),
            ),
        ],
      );
    }
  }

  Widget _buildCrest(String? url) {
    if (url == null || url.isEmpty) {
      return const CircleAvatar(
        radius: 14,
        backgroundColor: AppTheme.cardBackgroundLight,
        child: Icon(Icons.sports_soccer, size: 14, color: AppTheme.textMuted),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: 28,
      height: 28,
      fit: BoxFit.contain,
      placeholder: (context, url) => const SizedBox(
        width: 28,
        height: 28,
        child: Center(
          child: SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
        ),
      ),
      errorWidget: (context, url, error) =>
          const Icon(Icons.sports_soccer, size: 24, color: AppTheme.textMuted),
    );
  }
}
