import 'package:flutter/material.dart';
import 'package:pffl_managment/features/captain/providers/captain_league_detail_provider.dart';
import 'package:provider/provider.dart';

class CaptainLeagueOfficialsList extends StatelessWidget {
  const CaptainLeagueOfficialsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CaptainLeagueDetailProvider>(
      builder: (context, provider, child) {
        // For now, we'll create mock data since we don't have a method in the provider
        final officials = [
          {
            'id': '1',
            'name': 'Robert Wilson',
            'role': 'Referee',
            'email': 'robert.w@pffl.com',
            'phone': '+1234567890',
          },
          {
            'id': '2',
            'name': 'Jennifer Lee',
            'role': 'Stat Keeper',
            'email': 'jennifer.l@pffl.com',
            'phone': '+1234567891',
          },
        ];
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Officials',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (officials.isEmpty)
                const Center(
                  child: Text(
                    'No officials data available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                Column(
                  children: officials.map((official) {
                    return _buildOfficialCard(context, official);
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOfficialCard(BuildContext context, dynamic official) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    official['name'].toString().substring(0, 1),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      official['name'].toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      official['role'].toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.email, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                official['email'].toString(),
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                official['phone'].toString(),
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}