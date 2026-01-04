import 'package:flutter/material.dart';
import 'package:pffl_managment/core/models/game_model.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/shared_game_card.dart';
import 'package:pffl_managment/core/utils/game_navigation_helper.dart';

class AllMatchesScreen extends StatelessWidget {
  final List<GameModel> matches;
  final String title;

  const AllMatchesScreen({
    super.key,
    required this.matches,
    this.title = 'All Matches',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: ArrowBackButton()),
      body: matches.isEmpty
          ? const Center(
              child: Text(
                'No matches available',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(6.0),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                return SharedGameCard(
                  game: matches[index],
                  showYourGameTag: true,
                  onTap: () => GameNavigationHelper.navigateToGameDetail(
                    context,
                    matches[index],
                  ),
                );
              },
            ),
    );
  }
}
