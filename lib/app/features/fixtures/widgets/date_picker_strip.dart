import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class DatePickerStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final bool hasLive;

  const DatePickerStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.hasLive = false,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    // Generate 7 days centered on today (-3 to +3)
    final days = List.generate(7, (i) => today.add(Duration(days: i - 3)));

    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: AppTheme.darkBackground,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final date = days[index];
          final isSelected = _isSameDay(date, selectedDate);
          final isToday = _isSameDay(date, today);

          final dayName = isToday ? 'Tod' : DateFormat('EEE').format(date);
          final dayNum = DateFormat('dd').format(date);

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => onDateSelected(date),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 52,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.accentBlue : AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: isToday && !isSelected
                      ? Border.all(color: AppTheme.accentBlue, width: 1.5)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayNum,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                    if (isToday && hasLive)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppTheme.liveRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
