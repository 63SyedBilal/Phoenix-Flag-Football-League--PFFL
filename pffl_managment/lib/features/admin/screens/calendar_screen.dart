import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/providers/calendar_provider.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/features/admin/provider/create_league_viewmodel.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/calendar_widgets/month_item_widget.dart';
import 'package:provider/provider.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calendarProvider = Provider.of<CalendarProvider>(context);
    final leagueViewModel = Provider.of<CreateLeagueViewModel>(
      context,
      listen: false,
    );

    // Generate list of months starting from current month
    final now = DateTime.now();
    final months = List.generate(13, (index) {
      return DateTime(now.year, now.month + index, 1);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: ArrowBackButton(
          onPressed: () {
            // Navigate back by switching index back to 0 (or previous)
            // But since this is used in League Creation flow, we should probably stick to what it was.
            // Actually, LeagueCreationScreen is a separate screen entirely?
            // Wait, I added it to the IndexedStack of AdminDashboard in my previous turn.
            // So switching back to index 0 is Home. But we want to go back to "Leagues" or wherever we were.
            // If it's used during League Creation, we should probably return to the creation flow.
            // However, the creation flow itself is a separate route currently?
            // Let me check.
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calender',
                    style: AppTextStyles.headlineLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a date from the calendar to view scheduled fixtures.',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: months.length,
                itemBuilder: (context, index) {
                  return MonthItemWidget(
                    month: months[index],
                    selectedDate: calendarProvider.selectedDate,
                    onDateSelected: (date) {
                      calendarProvider.selectDate(date);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: calendarProvider.selectedDate != null
          ? FloatingActionButton.extended(
              onPressed: () {
                final date = calendarProvider.selectedDate!;
                // Assign date to ViewModel
                if (calendarProvider.selectionType ==
                    DateSelectionType.startDate) {
                  leagueViewModel.setStartDate(date);
                } else {
                  leagueViewModel.setEndDate(date);
                }

                // Pop back to the previous screen (LeagueCreationScreen)
                Navigator.of(context).pop();
              },
              backgroundColor: const Color(0xFF0F173E),
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
