import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/unified_games_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_games/admin_games_screen.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/features/captain/providers/league_payment_provider.dart';
import 'package:pffl_managment/screens/games/widgets/role_based_game_card.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class UpcommingMatches extends StatelessWidget {
  final String title;
  final int maxGames;

  const UpcommingMatches({
    super.key,
    this.title = 'Upcoming Matches',
    this.maxGames = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<UnifiedGamesProvider, LeaguePaymentProvider>(
      builder: (context, gamesProvider, paymentProvider, child) {
        final matches = gamesProvider.upcomingGames;
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userRole = authProvider.userRole.toLowerCase();
        final userId = authProvider.userId;
        final isCaptain = userRole == 'captain';
        final isPlayer = userRole == 'player';
        final isRegistrationRole = isCaptain || isPlayer;

        // Pre-load payment statuses for all leagues if user is captain or player
        if (isRegistrationRole && userId.isNotEmpty && matches.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _preloadLeaguePaymentStatuses(matches, paymentProvider, userId);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTextStyles.headlineSmall),
                if (matches.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AdminGamesScreen(matches: matches),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'View more',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            ...matches
                .take(maxGames)
                .map(
                  (match) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildMatchCard(
                      context,
                      match,
                      paymentProvider,
                      userRole,
                      userId,
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }

  /// Pre-load payment statuses for all leagues in the matches list
  void _preloadLeaguePaymentStatuses(
    List<dynamic> matches,
    LeaguePaymentProvider paymentProvider,
    String userId,
  ) {
    final leagueIds = matches
        .map((match) => match.leagueId)
        .where((leagueId) => leagueId != null)
        .toSet()
        .cast<String>();

    debugPrint(
      '📊 [PRELOAD PAYMENT STATUS] Found ${leagueIds.length} unique leagues: $leagueIds',
    );

    // Load payment status for each unique league
    for (final leagueId in leagueIds) {
      final cachedStatus = paymentProvider.getCachedPaymentStatus(
        leagueId,
        userId,
      );
      final isLoading = paymentProvider.isLoading(leagueId, userId);

      debugPrint(
        '📊 [PRELOAD PAYMENT STATUS] League $leagueId: cached=$cachedStatus, loading=$isLoading',
      );

      // Only load if not already cached or loading
      if (cachedStatus == null && !isLoading) {
        debugPrint(
          '📊 [PRELOAD PAYMENT STATUS] Loading payment status for league $leagueId',
        );
        paymentProvider.checkLeaguePaymentStatus(leagueId, userId);
      } else {
        debugPrint(
          '📊 [PRELOAD PAYMENT STATUS] Skipping league $leagueId (already cached or loading)',
        );
      }
    }
  }

  Widget _buildMatchCard(
    BuildContext context,
    dynamic match,
    LeaguePaymentProvider paymentProvider,
    String userRole,
    String? userId,
  ) {
    final isCaptain = userRole == 'captain';
    final isPlayer = userRole == 'player';

    // For captains and players, check league payment status from cache
    if ((isCaptain || isPlayer) && userId != null && match.leagueId != null) {
      final hasPaid =
          paymentProvider.getCachedPaymentStatus(match.leagueId, userId) ??
          false;
      final shouldShowPaymentPrompt = !hasPaid;

      return RoleBasedGameCard(
        match: match,
        userRole: userRole,
        canEdit: false,
        shouldShowPaymentPrompt: shouldShowPaymentPrompt,
        onPayLeagueFee: shouldShowPaymentPrompt
            ? () => _handlePayLeagueFee(context, match.leagueId)
            : null,
      );
    }

    // For admins, use RoleBasedGameCard with edit functionality
    if (userRole == 'admin' || userRole == 'superadmin') {
      return RoleBasedGameCard(
        match: match,
        userRole: userRole,
        canEdit: true,
        shouldShowPaymentPrompt: false,
      );
    }

    // For other roles, use RoleBasedGameCard without payment or edit
    return RoleBasedGameCard(
      match: match,
      userRole: userRole,
      canEdit: false,
      shouldShowPaymentPrompt: false,
    );
  }

  void _handlePayLeagueFee(BuildContext context, String leagueId) {
    // Navigate to Payment History Screen where pending payments are shown
    Navigator.pushNamed(context, AppRoutes.freeAgentPaymentHistory);
  }
}
