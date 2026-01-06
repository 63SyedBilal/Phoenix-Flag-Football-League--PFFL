import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';

/// Screen header with back button widget
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const ArrowBackButton(),
        ],
      ),
    );
  }
}

