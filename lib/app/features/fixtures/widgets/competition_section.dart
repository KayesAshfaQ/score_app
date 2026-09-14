import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import '../../../core/theme/app_theme.dart';
import 'match_card.dart';

class CompetitionSection extends StatefulWidget {
  final CompetitionBrief competition;
  final List<MatchModel> matches;
  final Function(MatchModel)? onMatchTap;
  final VoidCallback? onHeaderTap;

  const CompetitionSection({
    super.key,
    required this.competition,
    required this.matches,
    this.onMatchTap,
    this.onHeaderTap,
  });

  @override
  State<CompetitionSection> createState() => _CompetitionSectionState();
}

class _CompetitionSectionState extends State<CompetitionSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final groupName = widget.matches.first.group;
    final stageName = widget.matches.first.stage;

    String subtitle = '';
    if (groupName != null && groupName.isNotEmpty) {
      subtitle = groupName.replaceAll('_', ' ');
    } else if (stageName != null && stageName != 'REGULAR_SEASON') {
      subtitle = stageName.replaceAll('_', ' ');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        InkWell(
          onTap:
              widget.onHeaderTap ??
              () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                _buildEmblem(widget.competition.emblem),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.competition.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Matches list
        if (_isExpanded)
          ...widget.matches.map(
            (match) => MatchCard(
              match: match,
              onTap: () => widget.onMatchTap?.call(match),
            ),
          ),
      ],
    );
  }

  Widget _buildEmblem(String? url) {
    if (url == null || url.isEmpty) {
      return const Icon(
        Icons.emoji_events,
        size: 20,
        color: AppTheme.accentBlue,
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: 20,
      height: 20,
      fit: BoxFit.contain,
      errorWidget: (_, _, _) =>
          const Icon(Icons.emoji_events, size: 20, color: AppTheme.accentBlue),
    );
  }
}
