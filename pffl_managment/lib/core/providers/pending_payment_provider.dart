import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/team_service.dart';
import 'package:pffl_managment/core/services/league_service.dart';
import 'package:pffl_managment/core/services/payment_service.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';
import 'package:provider/provider.dart';

class PendingPaymentModel {
  final String leagueId;
  final String leagueName;
  final String amount;
  final String subTitle;
  final String format;
  final String startDate;
  final String endDate;

  PendingPaymentModel({
    required this.leagueId,
    required this.leagueName,
    required this.amount,
    required this.subTitle,
    required this.format,
    required this.startDate,
    required this.endDate,
  });
}

class PendingPaymentProvider extends ChangeNotifier {
  bool _isLoading = false;
  PendingPaymentModel? _pendingPayment;
  String? _error;

  bool get isLoading => _isLoading;
  PendingPaymentModel? get pendingPayment => _pendingPayment;
  bool get hasPendingPayment => _pendingPayment != null;
  String? get error => _error;

  Future<void> loadPendingPayment(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userProvider = Provider.of<UserPreferenceProvider>(
        context,
        listen: false,
      );
      final userId = userProvider.userId;
      final userRole = userProvider.userRole;

      if (userId == null) {
        throw Exception("User ID not found");
      }

      // 1. Get User's Team
      Map<String, dynamic>? team;
      print('🔍 Checking team for Role: $userRole');

      if (userRole?.toLowerCase() == 'captain') {
        team = await TeamService.getTeamByCaptain();
      } else {
        team = await TeamService.getTeamByPlayer(userId);
      }

      if (team == null) {
        print('⚠️ No team found for user $userId');
        _isLoading = false;
        notifyListeners();
        return;
      }

      print('✅ Found Team: ${team['teamName']}');
      print('   Team Keys: ${team.keys.toList()}');

      // 2. Get League for the Team
      final unpaidPayments = await PaymentService.fetchUnpaidPayments();
      print('💰 Unpaid Payments: ${unpaidPayments.length}');

      if (unpaidPayments.isNotEmpty) {
        final leaguePayment = unpaidPayments.firstWhere(
          (p) => p['leagueId'] != null || p['league'] != null,
          orElse: () => <String, dynamic>{},
        );

        if (leaguePayment.isNotEmpty) {
          dynamic leagueIdRaw =
              leaguePayment['leagueId'] ?? leaguePayment['league'];
          String? leagueId;

          if (leagueIdRaw is Map) {
            leagueId =
                leagueIdRaw['_id']?.toString() ?? leagueIdRaw['id']?.toString();
          } else if (leagueIdRaw is String) {
            leagueId = leagueIdRaw;
          }

          print('🔗 Found unpaid payment for league: $leagueId');

          if (leagueId != null) {
            final league = await LeagueService.getLeagueById(leagueId);

            if (league != null) {
              _pendingPayment = PendingPaymentModel(
                leagueId: leagueId,
                leagueName: league.leagueName,
                amount:
                    '\$${leaguePayment['amount'] ?? league.perPlayerLeagueFee}',
                subTitle: 'League Fee Due',
                format: league.format,
                startDate: _formatDate(league.startDate),
                endDate: _formatDate(league.endDate),
              );
            }
          }
        }
      }

      if (_pendingPayment == null) {
        // Fallback: Check team's league directly
        String? leagueId = team['leagueId']?.toString();

        // Try getting league from object if populated
        if (leagueId == null && team['league'] is Map) {
          leagueId =
              team['league']['_id']?.toString() ??
              team['league']['id']?.toString();
        }
        // Try getting league from object if it's just an ID string in 'league' field
        if (leagueId == null && team['league'] is String) {
          leagueId = team['league'];
        }

        print('🔍 Extracted League ID from Team: $leagueId');

        if (leagueId != null && leagueId.isNotEmpty) {
          // Check payment status for this league
          print('💳 Checking payment status for league $leagueId...');
          final payment = await PaymentService.getOrCreatePayment(leagueId);
          print('   Payment Status: ${payment?['status']}');

          if (payment != null && payment['status'] != 'paid') {
            final league = await LeagueService.getLeagueById(leagueId);
            if (league != null) {
              _pendingPayment = PendingPaymentModel(
                leagueId: leagueId,
                leagueName: league.leagueName,
                amount: '\$${league.perPlayerLeagueFee}',
                subTitle: 'League Fee Due',
                format: league.format,
                startDate: _formatDate(league.startDate),
                endDate: _formatDate(league.endDate),
              );
            }
          }
        } else {
          print(
            '⚠️ No League ID found in team object. User might be in a team that is not in a league yet.',
          );
        }
      }
    } catch (e) {
      print('Error loading pending payment: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
