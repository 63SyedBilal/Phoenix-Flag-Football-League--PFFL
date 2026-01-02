import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';

/// Sponsors section screen (Admin only)
class SponsorsScreen extends StatelessWidget {
  const SponsorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const ArrowBackButton(),
        title: const Text(
          'Sponsors',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Sponsors Screen',
          style: TextStyle(fontSize: 18, color: Color(0xFF1A1A1A)),
        ),
      ),
    );
  }
}
