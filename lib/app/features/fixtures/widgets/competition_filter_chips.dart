import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import '../../../core/theme/app_theme.dart';

class CompetitionFilterChips extends StatelessWidget {
  final String? selectedCode;
  final ValueChanged<String?> onSelected;

  const CompetitionFilterChips({
    super.key,
    required this.selectedCode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final comps = CompetitionConstants.freeCompetitions;

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" Chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
              selected: selectedCode == null,
              onSelected: (_) => onSelected(null),
              selectedColor: AppTheme.accentBlue,
              backgroundColor: AppTheme.cardBackground,
              labelStyle: TextStyle(
                color: selectedCode == null ? Colors.white : AppTheme.textSecondary,
                fontWeight: selectedCode == null ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              showCheckmark: false,
            ),
          ),
          ...comps.entries.map((entry) {
            final code = entry.key;
            final info = entry.value;
            final isSelected = selectedCode == code;
            final flag = info['flag'] ?? '';
            final name = info['name'] ?? code;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('$flag $code'),
                tooltip: name,
                selected: isSelected,
                onSelected: (_) => onSelected(code),
                selectedColor: AppTheme.accentBlue,
                backgroundColor: AppTheme.cardBackground,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                showCheckmark: false,
              ),
            );
          }),
        ],
      ),
    );
  }
}
