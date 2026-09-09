import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../notifications/providers/notification_provider.dart';
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
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              _showNotificationSettings(context);
            },
          ),
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
              Expanded(child: _buildBody(context, provider)),
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
              const Icon(
                Icons.error_outline,
                color: AppTheme.liveRed,
                size: 48,
              ),
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
            Icon(
              Icons.sports_soccer_outlined,
              color: AppTheme.textMuted,
              size: 48,
            ),
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
              context.push(
                '/competition/${entry.key.code}',
                extra: entry.key.name,
              );
            },
          );
        },
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Consumer<NotificationProvider>(
          builder: (context, notifProvider, _) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.notifications_active_rounded,
                        color: AppTheme.accentBlue,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Notification Channels',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppTheme.textSecondary,
                        ),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'All Live Goals Broadcast',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      subtitle: const Text(
                        'Receive instant notifications for any goal across all free leagues.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      value: notifProvider.allGoalsEnabled,
                      activeThumbColor: AppTheme.accentBlue,
                      onChanged: (val) {
                        notifProvider.toggleAllGoals();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Active Subscriptions: ${notifProvider.subscribedMatchIds.length} match(es), ${notifProvider.subscribedCompetitionCodes.length} league(s)',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tip: Tap the bell icon on any match or league page to follow specific fixtures.',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
