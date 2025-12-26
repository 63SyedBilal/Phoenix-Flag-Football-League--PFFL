import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/providers/calendar_provider.dart';
import 'package:provider/provider.dart';

class MonthItemWidget extends StatelessWidget {
  final DateTime month;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const MonthItemWidget({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final calendarProvider = Provider.of<CalendarProvider>(context);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstDayOffset = DateTime(month.year, month.month, 1).weekday % 7;
    final monthName = DateFormat('MMMM yyyy').format(month).toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            monthName,
            style: AppTextStyles.labelLarge.copyWith(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
        ),
        const SizedBox(height: 8),
        _buildWeekdayHeader(),
        const SizedBox(height: 8),
        _buildDateGrid(daysInMonth, firstDayOffset, calendarProvider),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekdays.map((day) {
          final isWeekend = day == 'SUN' || day == 'SAT';
          return SizedBox(
            width: 40,
            child: Center(
              child: Text(
                day,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isWeekend
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateGrid(
    int daysInMonth,
    int offset,
    CalendarProvider calendarProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 12,
          crossAxisSpacing: 0,
        ),
        itemCount: daysInMonth + offset,
        itemBuilder: (context, index) {
          if (index < offset) {
            return const SizedBox.shrink();
          }
          final day = index - offset + 1;
          final date = DateTime(month.year, month.month, day);
          final isSelected =
              selectedDate != null && DateUtils.isSameDay(date, selectedDate!);

          final isWeekend =
              date.weekday == DateTime.sunday ||
              date.weekday == DateTime.saturday;
          final isSelectable = calendarProvider.isDateSelectable(date);

          return GestureDetector(
            onTap: isSelectable ? () => onDateSelected(date) : null,
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected
                          ? Colors.white
                          : (isSelectable
                                ? (isWeekend
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF1E293B))
                                : const Color(0xFFCBD5E1)),
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
