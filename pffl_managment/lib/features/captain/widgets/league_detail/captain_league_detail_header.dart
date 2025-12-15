import 'package:flutter/material.dart';

class CaptainLeagueDetailHeader extends StatelessWidget {
  final String leagueName;
  final String subtitle;
  final VoidCallback onBackPressed;

  const CaptainLeagueDetailHeader({
    super.key,
    required this.leagueName,
    required this.subtitle,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBackPressed,
                child: const Icon(Icons.arrow_back, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  leagueName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}