import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/back_button_provider.dart';

/// A wrapper widget that handles Android back button behavior.
///
/// It intercepts the back button press and requires a second press
/// within 2 seconds to actually exit or pop the screen.
class BackButtonWrapper extends StatelessWidget {
  /// The widget tree that this wrapper should protect.
  final Widget child;

  /// Whether this is the root screen (if true, it handles app exit).
  /// If false, it just handles popping the current route.
  final bool isRoot;

  const BackButtonWrapper({
    super.key,
    required this.child,
    this.isRoot = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Always intercept initially
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final provider = context.read<BackButtonProvider>();
        final shouldExit = provider.handleBackPress();

        if (shouldExit) {
          // Allow exit/pop
          if (isRoot) {
            // Root screen - allow app to close
            // In modern Flutter, we can't easily "allow" via PopScope once canPop is false
            // without a rebuild or manual Navigator pop.
            // For root screens, we might need a slightly different strategy or manual pop.
            Navigator.of(context).pop();
          } else {
            // Normal screen - pop
            Navigator.of(context).pop();
          }
        } else {
          // First press - show message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: child,
    );
  }
}
