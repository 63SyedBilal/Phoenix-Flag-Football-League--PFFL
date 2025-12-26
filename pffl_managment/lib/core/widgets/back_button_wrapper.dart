import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/back_button_provider.dart';

class BackButtonWrapper extends StatelessWidget {
  final Widget child;
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
            // Root screen - Close the app
            await SystemNavigator.pop();
          } else {
            // Normal screen - pop
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        } else {
          // First press - show message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Press back again to exit'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,

                // 👇 Ye line main fix hai
                margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
              ),
            );
          }
        }
      },
      child: child,
    );
  }
}
