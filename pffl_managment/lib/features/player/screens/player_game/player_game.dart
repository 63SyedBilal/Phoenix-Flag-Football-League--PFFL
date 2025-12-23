import 'package:flutter/material.dart';
import 'package:pffl_managment/features/captain/providers/captain_games_provider.dart';
import 'package:pffl_managment/features/captain/view/games/widgets/date_selector.dart';
import 'package:provider/provider.dart';

class PlayerGame extends StatelessWidget {
  const PlayerGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CaptainGamesProvider(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const DateSelector(),
              const SizedBox(height: 24),
              Expanded(
                child: Consumer<CaptainGamesProvider>(
                  builder: (context, provider, child) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.games.length,
                      itemBuilder: (context, index) {
                        return null;   
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
