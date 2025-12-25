import 'package:flutter/material.dart';

class EmptyLeaguesState extends StatelessWidget {
  const EmptyLeaguesState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No active leagues available.'));
  }
}
