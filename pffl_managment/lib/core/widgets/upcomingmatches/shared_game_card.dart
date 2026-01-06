import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pffl_managment/core/models/game_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/features/captain/providers/league_payment_provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class SharedGameCard extends StatelessWidget {
  final GameModel game;
  final VoidCallback? onTap;
  final bool showYourGameTag;
  final bool showPaymentSection;

  const SharedGameCard({
    super.key,
    required this.game,
    this.onTap,
    this.showYourGameTag = false,
    this.showPaymentSection = false,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF000000).withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      game.leagueName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Lato',
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF111827),
                      size: 8,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTeamLogo(game.team1Logo),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          game.fullTeam1Name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Lato',
                            color: Color(0xFF111827),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('M/d').format(game.date),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Lato',
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        game.time,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Lato',
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
                // Team 2 - Expanded (icon first, then text)
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildTeamLogo(game.team2Logo),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          game.fullTeam2Name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Lato',
                            color: Color(0xFF111827),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildPaymentSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.userRole.toLowerCase();
    final userId = authProvider.userId;
    final isCaptain = userRole == 'captain';
    final isPlayer = userRole == 'player';

    if (!(isCaptain || isPlayer) || game.leagueId == null || userId.isEmpty) {
      return const SizedBox.shrink();
    }

    return Consumer<LeaguePaymentProvider>(
      builder: (context, paymentProvider, child) {
        final cachedStatus = paymentProvider.getCachedPaymentStatus(
          game.leagueId!,
          userId,
        );
        final isLoading = paymentProvider.isLoading(game.leagueId!, userId);

        // If status is not in cache and not loading, trigger a check
        if (cachedStatus == null && !isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            paymentProvider.checkLeaguePaymentStatus(game.leagueId!, userId);
          });
        }

        final hasPaid = cachedStatus ?? false;

        if (hasPaid) return const SizedBox.shrink();

        return Column(
          children: [
            Divider(
              height: 24,
              thickness: 0.5,
              color: const Color(0xFF000000).withValues(alpha: 0.12),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'League Fee: Unpaid',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Lato',
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.freeAgentPaymentHistory,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F173E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Pay League Fee',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Lato',
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTeamLogo(String logoUrl) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF000000).withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.5),
        child: CachedNetworkImage(
          imageUrl: logoUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.sports, size: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
