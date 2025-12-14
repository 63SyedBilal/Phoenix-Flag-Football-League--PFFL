import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/admin/game_widgets/upcomming_matches_screens/upcomming_matches_card_widget.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';

class AllMatchesScreen extends StatelessWidget {
  final List<MatchModel> matches;
  
  const AllMatchesScreen({super.key, required this.matches});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        leading: ArrowBackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('All Upcoming Matches'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: UpcommingMatchesCardWidget(match: matches[index]),
            );
          },
        ),
      ),
    );
  }
}