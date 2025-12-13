import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/models/game_model.dart';
import '../../../providers/captain_games_provider.dart';
import 'package:intl/intl.dart';
import 'package:pffl_managment/features/captain/view/match_details/captain_match_details_screen.dart';

class CaptainGameCard extends StatelessWidget {
  final GameModel game;
  final bool showSponsorBanner;
  final bool showPaymentSection;

  const CaptainGameCard({
    super.key,
    required this.game,
    this.showSponsorBanner = false,
    this.showPaymentSection = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CaptainMatchDetailsScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            game.leagueName,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                      if (game.isMyGame)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Your Game',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildTeamInfo(game.team1Name, game.team1Logo),
                      ),
                      Column(
                        children: [
                          Text(
                            DateFormat('MM/dd').format(game.date),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            game.time,
                            style: TextStyle(
                              color: const Color(0xFF6B7280),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: _buildTeamInfo(
                          game.team2Name,
                          game.team2Logo,
                          isRightAligned: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!game.isFeePaid && game.isMyGame) ...[
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your league fee is still unpaid.',
                      style: TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<CaptainGamesProvider>(
                          context,
                          listen: false,
                        ).payLeagueFee(game.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Pay League Fee',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTeamInfo(
    String name,
    String logoPath, {
    bool isRightAligned = false,
  }) {
    return Row(
      mainAxisAlignment: isRightAligned
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (!isRightAligned) ...[
          _buildLogo(logoPath),
          const SizedBox(width: 12),
        ],
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF111827),
          ),
        ),
        if (isRightAligned) ...[
          const SizedBox(width: 12),
          _buildLogo(logoPath),
        ],
      ],
    );
  }

  Widget _buildLogo(String logoPath) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: Image.asset(
          logoPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade100,
              child: const Icon(Icons.shield, color: Colors.grey, size: 20),
            );
          },
        ),
      ),
    );
  }
}
