import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/admin_navigation_provider.dart';

/// Helper for Admin Dashboard summary card navigation
/// Now behaves like Bottom Navigation tab switching
class AdminNavigationHelper {
  /// Switch to Leagues Tab
  static void navigateToLeagues(BuildContext context) {
    Provider.of<AdminNavigationProvider>(context, listen: false).setIndex(1);
  }

  /// Switch to Games Tab
  static void navigateToGames(BuildContext context) {
    Provider.of<AdminNavigationProvider>(context, listen: false).setIndex(2);
  }

  /// Switch to Users Tab
  static void navigateToUsers(BuildContext context) {
    Provider.of<AdminNavigationProvider>(context, listen: false).setIndex(3);
  }

  /// Switch to Payment History (a sub-index of Settings tab)
  static void navigateToPayments(BuildContext context) {
    Provider.of<AdminNavigationProvider>(context, listen: false).setIndex(5);
  }
}
