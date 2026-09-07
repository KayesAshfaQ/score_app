import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/fixtures_provider.dart';
import '../widgets/competition_filter_chips.dart';
import '../widgets/competition_section.dart';
import '../widgets/date_picker_strip.dart';

class FixturesPage extends StatelessWidget {
  const FixturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scora'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<FixturesProvider>().fetchMatches(forceRefresh: true);
            },
          ),
        ],
      ),
      body: Consumer<FixturesProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Date picker
              DatePickerStrip(
                selectedDate: provider.selectedDate,
                onDateSelected: (date) => provider.selectDate(date),
                hasLive: provider.hasLiveMatches,
              ),

              // Competition Filter Chips
              CompetitionFilterChips(
                selectedCode: provider.selectedCompetitionCode,
                onSelected: (code) => provider.selectCompetition(code),
              ),

              const Divider(color: AppTheme.dividerColor, height: 1),

              // Content Area
              Expanded(
                child: _buildBody(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, FixturesProvider provider) {
    if (provider.isLoading && provider.allMatches.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentBlue),
      );
    }

    if (provider.errorMessage != null && provider.allMatches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.liveRed, size: 48),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.fetchMatches(forceRefresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.groupedMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.sports_soccer_outlined, color: AppTheme.textMuted, size: 48),
            SizedBox(height: 12),
            Text(
              'No matches scheduled for this day',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchMatches(forceRefresh: true),
      color: AppTheme.accentBlue,
      backgroundColor: AppTheme.cardBackground,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: provider.groupedMatches.length,
        itemBuilder: (context, index) {
          final entry = provider.groupedMatches.entries.elementAt(index);
          return CompetitionSection(
            competition: entry.key,
            matches: entry.value,
            onMatchTap: (match) {
              context.push('/match/${match.id}');
            },
            onHeaderTap: () {
              context.push('/competition/${entry.key.code}', extra: entry.key.name);
            },
          );
        },
      ),
    );
  }
}
