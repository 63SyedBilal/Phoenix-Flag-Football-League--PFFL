import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/league_service.dart';

/// Provider for managing league payment status for users (captains or players)
class LeaguePaymentProvider extends ChangeNotifier {
  /// Map to cache payment status by leagueId-userId key
  final Map<String, bool> _paymentStatusCache = {};

  /// Map to track loading state by leagueId-userId key
  final Map<String, bool> _loadingStatus = {};

  /// Map to track error messages by leagueId-userId key
  final Map<String, String?> _errorMessages = {};

  /// Check if a user has paid league registration fee for a specific league
  /// Returns cached value if available, otherwise fetches from API
  Future<bool> checkLeaguePaymentStatus(String leagueId, String userId) async {
    final cacheKey = '$leagueId-$userId';

    // Return cached value if available
    if (_paymentStatusCache[cacheKey] != null) {
      return _paymentStatusCache[cacheKey]!;
    }

    // Set loading state
    _loadingStatus[cacheKey] = true;
    _errorMessages[cacheKey] = null;
    notifyListeners();

    try {
      debugPrint(
        '💳 [PAYMENT CHECK] Checking payment for league: $leagueId, user: $userId',
      );
      final response = await LeagueService.checkLeaguePaymentStatus(
        leagueId,
        userId,
      );

      if (response['success'] == true && response['data'] != null) {
        final isPaid = response['data']['isPaid'] == true;
        _paymentStatusCache[cacheKey] = isPaid;
        _loadingStatus[cacheKey] = false;
        debugPrint(
          '✅ [PAYMENT CHECK] Payment status: ${isPaid ? "PAID" : "UNPAID"}',
        );
        notifyListeners();
        return isPaid;
      } else {
        final errorMsg =
            response['message']?.toString() ??
            response['error']?.toString() ??
            '';
        debugPrint('⚠️ League payment status check failed: $errorMsg');

        // Check if error is about "no team" - this is a backend issue
        if (errorMsg.toLowerCase().contains('no team') ||
            errorMsg.toLowerCase().contains('no teams')) {
          debugPrint(
            '⚠️ [PAYMENT CHECK] Backend error: User has no team in league (this should not block payment check)',
          );
          debugPrint(
            '⚠️ [PAYMENT CHECK] Treating as UNPAID - Backend needs to fix this logic!',
          );
          // Don't cache this error - it's a backend issue
          _paymentStatusCache[cacheKey] = false;
          _loadingStatus[cacheKey] = false;
          notifyListeners();
          return false;
        }

        _paymentStatusCache[cacheKey] = false;
        _loadingStatus[cacheKey] = false;
        _errorMessages[cacheKey] = errorMsg;
        notifyListeners();
        return false;
      }
    } catch (e) {
      final errorStr = e.toString();
      debugPrint('❌ Error checking league payment status: $errorStr');

      // Check if it's the "no team" error
      if (errorStr.toLowerCase().contains('no team') ||
          errorStr.toLowerCase().contains('no teams')) {
        debugPrint(
          '⚠️ [PAYMENT CHECK] Caught "no team" error - Backend issue!',
        );
        debugPrint(
          '⚠️ [PAYMENT CHECK] Backend should check payment records, not team membership!',
        );
        _paymentStatusCache[cacheKey] = false;
        _loadingStatus[cacheKey] = false;
        notifyListeners();
        return false;
      }

      _errorMessages[cacheKey] = errorStr;
      _paymentStatusCache[cacheKey] = false;
      _loadingStatus[cacheKey] = false;
      notifyListeners();
      return false; // Default to unpaid on error
    }
  }

  /// Get cached payment status without API call
  bool? getCachedPaymentStatus(String leagueId, String userId) {
    final cacheKey = '$leagueId-$userId';
    return _paymentStatusCache[cacheKey];
  }

  /// Check if payment status is being loaded
  bool isLoading(String leagueId, String userId) {
    final cacheKey = '$leagueId-$userId';
    return _loadingStatus[cacheKey] == true;
  }

  /// Get error message for payment status check
  String? getError(String leagueId, String userId) {
    final cacheKey = '$leagueId-$userId';
    return _errorMessages[cacheKey];
  }

  /// Clear cache for a specific league-user combination
  void clearCache(String leagueId, String userId) {
    final cacheKey = '$leagueId-$userId';
    _paymentStatusCache.remove(cacheKey);
    _loadingStatus.remove(cacheKey);
    _errorMessages.remove(cacheKey);
    notifyListeners();
  }

  /// Clear all cached data
  void clearAllCache() {
    _paymentStatusCache.clear();
    _loadingStatus.clear();
    _errorMessages.clear();
    notifyListeners();
  }

  /// Refresh payment status for a specific league-user combination
  Future<bool> refreshPaymentStatus(String leagueId, String userId) async {
    clearCache(leagueId, userId);
    return await checkLeaguePaymentStatus(leagueId, userId);
  }

  /// Refresh payment status for multiple leagues at once
  Future<void> refreshMultipleLeagues(
    List<String> leagueIds,
    String userId,
  ) async {
    final futures = leagueIds.map(
      (leagueId) => refreshPaymentStatus(leagueId, userId),
    );
    await Future.wait(futures);
  }

  /// Clear all cached data and force refresh
  Future<void> forceRefresh() async {
    clearAllCache();
    notifyListeners();
  }
}
