import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../models/standing_model.dart';
import '../providers/standings_provider.dart';

class StandingsPage extends StatefulWidget {
  final String competitionCode;

  const StandingsPage({super.key, required this.competitionCode});

  @override
  State<StandingsPage> createState() => _StandingsPageState();
}

class _StandingsPageState extends State<StandingsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<StandingsProvider>().fetchStandings(widget.competitionCode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.competitionCode} Standings'),
      ),
      body: Consumer<StandingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accentBlue));
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.liveRed, size: 48),
                    const SizedBox(height: 16),
                    Text(provider.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchStandings(widget.competitionCode),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.standings.isEmpty) {
            return const Center(
              child: Text('No standings available', style: TextStyle(color: AppTheme.textSecondary)),
            );
          }

          final totalStanding = provider.standings.firstWhere(
            (s) => s.type == 'TOTAL',
            orElse: () => provider.standings.first,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (totalStanding.group != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      totalStanding.group!.replaceAll('_', ' '),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                _buildTable(totalStanding.table),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTable(List<StandingEntry> entries) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(30),  // Pos
          1: FlexColumnWidth(3),    // Team
          2: FixedColumnWidth(30),  // P
          3: FixedColumnWidth(30),  // W
          4: FixedColumnWidth(30),  // D
          5: FixedColumnWidth(30),  // L
          6: FixedColumnWidth(36),  // GD
          7: FixedColumnWidth(36),  // Pts
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Header row
          const TableRow(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.dividerColor)),
            ),
            children: [
              _HeaderCell('#'),
              _HeaderCell('Team', align: Alignment.centerLeft),
              _HeaderCell('P'),
              _HeaderCell('W'),
              _HeaderCell('D'),
              _HeaderCell('L'),
              _HeaderCell('GD'),
              _HeaderCell('Pts', isBold: true),
            ],
          ),
          // Data rows
          ...entries.map((entry) {
            return TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.cardBackgroundLight, width: 0.5)),
              ),
              children: [
                _DataCell('${entry.position}', isMuted: true),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      if (entry.team.crest != null)
                        CachedNetworkImage(
                          imageUrl: entry.team.crest!,
                          width: 18,
                          height: 18,
                          errorWidget: (_, __, ___) => const SizedBox(width: 18),
                        )
                      else
                        const SizedBox(width: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.team.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _DataCell('${entry.playedGames}'),
                _DataCell('${entry.won}'),
                _DataCell('${entry.draw}'),
                _DataCell('${entry.lost}'),
                _DataCell('${entry.goalDifference}'),
                _DataCell('${entry.points}', isBold: true),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final Alignment align;
  final bool isBold;

  const _HeaderCell(
    this.text, {
    this.align = Alignment.center,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: align,
      child: Text(
        text,
        style: TextStyle(
          color: isBold ? AppTheme.textPrimary : AppTheme.textSecondary,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final bool isMuted;
  final bool isBold;

  const _DataCell(
    this.text, {
    this.isMuted = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: isBold
              ? AppTheme.accentBlue
              : (isMuted ? AppTheme.textMuted : AppTheme.textPrimary),
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}
