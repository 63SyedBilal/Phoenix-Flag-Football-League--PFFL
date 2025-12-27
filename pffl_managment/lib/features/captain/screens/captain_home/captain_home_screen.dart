import 'package:flutter/material.dart';
import 'package:pffl_managment/features/sponsors/screens/sponsor_banner_screen.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/captain/widgets/league_payment_card.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/shared_upcoming_matches.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/all_matches_screen.dart';
import 'package:pffl_managment/features/player/providers/player_dashboard_provider.dart';
import 'package:pffl_managment/core/services/payment_service.dart';
import 'package:pffl_managment/core/services/league_service.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/core/services/team_service.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_league_selection/providers/league_selection_provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CaptainHomeScreen extends StatelessWidget {
  const CaptainHomeScreen({super.key});

  Future<_PendingLeaguePaymentInfo?> _loadPendingPaymentInfo() async {
    try {
      final unpaid = await PaymentService.fetchUnpaidPayments();
      if (unpaid.isNotEmpty) {
        final first = unpaid.first;

        double? amountFromPayment;
        final amountRaw = first['amount'] ?? first['fee'] ?? first['perPlayerFee'];
        if (amountRaw is num) {
          amountFromPayment = amountRaw.toDouble();
        } else if (amountRaw is String) {
          final cleaned = amountRaw.replaceAll(RegExp(r'[^0-9\.]'), '');
          amountFromPayment = double.tryParse(cleaned);
        }

        String? leagueId;
        final leagueField = first['league'];
        if (leagueField is Map) {
          leagueId = leagueField['_id']?.toString() ?? leagueField['id']?.toString();
        }
        leagueId ??= first['leagueId']?.toString() ?? first['league_id']?.toString();

        if (leagueId != null && leagueId.isNotEmpty) {
          final leagueDetail = await LeagueService.getLeagueById(leagueId);
          final allLeagues = await LeagueService.getAllLeagues();
          final leagueModel = allLeagues.where((l) => l.id == leagueId).cast<LeagueModel?>().firstWhere(
                (l) => l != null,
                orElse: () => null,
              );

          if (leagueDetail != null) {
            final effectiveLeagueModel = leagueModel ??
                LeagueModel(
                  id: leagueId,
                  leagueName: leagueDetail.leagueName,
                  format: leagueDetail.format,
                  startDate: leagueDetail.startDate,
                  endDate: leagueDetail.endDate,
                  minimumPlayers: 0,
                  perPlayerLeagueFee: amountFromPayment ?? 0,
                  logo: null,
                  status: 'pending',
                  createdAt: null,
                );

            return _PendingLeaguePaymentInfo(
              leagueId: leagueId,
              leagueName: leagueDetail.leagueName,
              format: leagueDetail.format,
              startDate: leagueDetail.startDate,
              endDate: leagueDetail.endDate,
              perPlayerFee: effectiveLeagueModel.perPlayerLeagueFee,
              leagueModel: effectiveLeagueModel,
            );
          }
        }
      }

      // Fallback: try to infer league via saved leagueId.
      final prefs = await SharedPreferences.getInstance();
      final savedLeagueId = prefs.getString('leagueId');
      if (savedLeagueId != null && savedLeagueId.isNotEmpty) {
        final leagueDetail = await LeagueService.getLeagueById(savedLeagueId);
        final allLeagues = await LeagueService.getAllLeagues();
        final leagueModel = allLeagues.where((l) => l.id == savedLeagueId).cast<LeagueModel?>().firstWhere(
              (l) => l != null,
              orElse: () => null,
            );
        if (leagueDetail != null) {
          final effectiveLeagueModel = leagueModel ??
              LeagueModel(
                id: savedLeagueId,
                leagueName: leagueDetail.leagueName,
                format: leagueDetail.format,
                startDate: leagueDetail.startDate,
                endDate: leagueDetail.endDate,
                minimumPlayers: 0,
                perPlayerLeagueFee: 0,
                logo: null,
                status: 'pending',
                createdAt: null,
              );
          return _PendingLeaguePaymentInfo(
            leagueId: savedLeagueId,
            leagueName: leagueDetail.leagueName,
            format: leagueDetail.format,
            startDate: leagueDetail.startDate,
            endDate: leagueDetail.endDate,
            perPlayerFee: effectiveLeagueModel.perPlayerLeagueFee,
            leagueModel: effectiveLeagueModel,
          );
        }
      }

      // Fallback: infer league via team -> matches
      final userId = prefs.getString('userId');
      if (userId != null && userId.isNotEmpty) {
        final team = await TeamService.getTeamByCaptain();
        final teamId = team?['_id']?.toString() ?? team?['id']?.toString();
        if (teamId != null && teamId.isNotEmpty) {
          final matches = await MatchService.getAllMatches();
          if (matches.isEmpty) {
            return null;
          }

          final match = matches.firstWhere(
            (m) => (m.homeTeamId == teamId || m.awayTeamId == teamId) &&
                (m.leagueId != null && m.leagueId!.isNotEmpty),
            orElse: () => matches.first,
          );

          final inferredLeagueId = match.leagueId;
          if (inferredLeagueId != null && inferredLeagueId.isNotEmpty) {
            final leagueDetail = await LeagueService.getLeagueById(
              inferredLeagueId,
            );
            final allLeagues = await LeagueService.getAllLeagues();
            final leagueModel = allLeagues
                .where((l) => l.id == inferredLeagueId)
                .cast<LeagueModel?>()
                .firstWhere(
                  (l) => l != null,
                  orElse: () => null,
                );
            if (leagueDetail != null) {
              final effectiveLeagueModel = leagueModel ??
                  LeagueModel(
                    id: inferredLeagueId,
                    leagueName: leagueDetail.leagueName,
                    format: leagueDetail.format,
                    startDate: leagueDetail.startDate,
                    endDate: leagueDetail.endDate,
                    minimumPlayers: 0,
                    perPlayerLeagueFee: 0,
                    logo: null,
                    status: 'pending',
                    createdAt: null,
                  );
              return _PendingLeaguePaymentInfo(
                leagueId: inferredLeagueId,
                leagueName: leagueDetail.leagueName,
                format: leagueDetail.format,
                startDate: leagueDetail.startDate,
                endDate: leagueDetail.endDate,
                perPlayerFee: effectiveLeagueModel.perPlayerLeagueFee,
                leagueModel: effectiveLeagueModel,
              );
            }
          }
        }
      }
    } catch (_) {
      // Silent: keep placeholders
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<PlayerDashboardProvider>(context);
    final games = dashboardProvider.upcomingGames;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pending Payment',
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<_PendingLeaguePaymentInfo?>(
                  future: _loadPendingPaymentInfo(),
                  builder: (context, snapshot) {
                    final info = snapshot.data;

                    final dateFmt = DateFormat('d MMMM yyyy');
                    final startDateText = info != null
                        ? dateFmt.format(info.startDate)
                        : '10 December 2025';
                    final endDateText = info != null
                        ? dateFmt.format(info.endDate)
                        : '25 February 2026';

                    final fee = info?.perPlayerFee;
                    final feeText = fee != null ? '\$${fee.toStringAsFixed(0)}' : '\$200';

                    return LeaguePaymentCard(
                      title: info?.leagueName ?? 'Player League',
                      amount: feeText,
                      subtitle: 'League Fee Due',
                      format: info?.format ?? '5v5',
                      leagueFee: feeText,
                      startDate: startDateText,
                      endDate: endDateText,
                      onPayNow: () async {
                        var resolvedInfo = info;
                        resolvedInfo ??= await _loadPendingPaymentInfo();

                        if (resolvedInfo != null) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString(
                            'pendingLeagueId',
                            resolvedInfo.leagueId,
                          );
                        }

                        final leagueProvider =
                            Provider.of<LeagueSelectionProvider>(context, listen: false);
                        leagueProvider.clearAllSelections();
                        if (resolvedInfo?.leagueModel != null) {
                          leagueProvider.toggleLeagueSelection(
                            resolvedInfo!.leagueModel!,
                          );
                        }

                        if (context.mounted) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.freeAgentPaymentOption,
                          );
                        }
                      },
                    );
                  },
                ),

                const SizedBox(height: 12),
                // Show only the next game if available
                if (games.isNotEmpty)
                  SharedUpcomingMatches(
                    games: [games[0]], // Show only the next game
                    maxVisibleGames: 1, // Show only 1 game for "Next Game"
                    title: 'Your Next Game',
                    onViewMore: () {
                      // Navigate to full matches list
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllMatchesScreen(
                            matches: [games[0]],
                            title: 'Next Game',
                          ),
                        ),
                      );
                    },
                  ),
                SponsorBannerScreen(),

                const SizedBox(height: 8),

                SharedUpcomingMatches(
                  games: games,
                  maxVisibleGames: 3, // Show only 3 games in main view
                  title: 'Upcoming Games',
                  onViewMore: () {
                    // Navigate to full matches list
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllMatchesScreen(
                          matches: games,
                          title: 'Upcoming Games',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PendingLeaguePaymentInfo {
  final String leagueId;
  final String leagueName;
  final String format;
  final DateTime startDate;
  final DateTime endDate;
  final double? perPlayerFee;
  final LeagueModel? leagueModel;

  const _PendingLeaguePaymentInfo({
    required this.leagueId,
    required this.leagueName,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.perPlayerFee,
    required this.leagueModel,
  });
}
