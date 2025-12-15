import 'package:flutter/material.dart';

/// Loading state widget
class InviteLoadingState extends StatelessWidget {
  const InviteLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

