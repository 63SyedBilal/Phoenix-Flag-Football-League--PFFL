import 'package:flutter/material.dart';

class LeagueOfficialsList extends StatelessWidget {
  const LeagueOfficialsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Referee',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Color.fromRGBO(17, 24, 39, 1),
                  fontFamily: 'Lato',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 24),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddOfficialPage(officialType: 'Referee'),
                    ),
                  );
                },
              ),
            ],
          ),
          _RefereeList(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Stat Keeper',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Color.fromRGBO(17, 24, 39, 1),
                  fontFamily: 'Lato',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 24),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddOfficialPage(officialType: 'Stat Keeper'),
                    ),
                  );
                },
              ),
            ],
          ),
          _StatKeeperList(),
        ],
      ),
    );
  }
}

class _RefereeList extends StatelessWidget {
  _RefereeList();

  final List<Map<String, String>> _referees = [
    {'name': 'Anthony Brooks', 'image': 'assets/images/Image 12.png'},
    {'name': 'Michael Johnson', 'image': 'assets/images/Image 12.png'},
    {'name': 'Sarah Williams', 'image': 'assets/images/Image 12.png'},
    {'name': 'David Thompson', 'image': 'assets/images/Image 12.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _referees.map((referee) {
        return _buildRefereeItem(context, referee);
      }).toList(),
    );
  }

  Widget _buildRefereeItem(BuildContext context, Map<String, String> referee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        border: Border.all(
          color: const Color.fromRGBO(229, 231, 235, 1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromRGBO(229, 231, 235, 1),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/Image 12.png', // Use the same image for all officials
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color.fromRGBO(243, 244, 246, 1),
                    child: const Icon(
                      Icons.person,
                      color: Color.fromRGBO(156, 163, 175, 1),
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Referee name
          Expanded(
            child: Text(
              referee['name']!,
              style: const TextStyle(
                color: Color.fromRGBO(17, 24, 39, 1),
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Gmail icon instead of delete icon
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invite sent to ${referee['name']}'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Icon(
              Icons.mail_outline,
              color: Colors.blueGrey,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatKeeperList extends StatelessWidget {
  _StatKeeperList();

  final List<Map<String, String>> _statKeepers = [
    {'name': 'Emily Davis', 'image': 'assets/images/Image 12.png'},
    {'name': 'James Brown', 'image': 'assets/images/Image 12.png'},
    {'name': 'Linda White', 'image': 'assets/images/Image 12.png'},
    {'name': 'Robert Green', 'image': 'assets/images/Image 12.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _statKeepers.map((statKeeper) {
        return _buildStatKeeperItem(context, statKeeper);
      }).toList(),
    );
  }

  Widget _buildStatKeeperItem(
    BuildContext context,
    Map<String, String> statKeeper,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        border: Border.all(
          color: const Color.fromRGBO(229, 231, 235, 1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromRGBO(229, 231, 235, 1),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/Image 12.png', // Use the same image for all officials
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color.fromRGBO(243, 244, 246, 1),
                    child: const Icon(
                      Icons.person,
                      color: Color.fromRGBO(156, 163, 175, 1),
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Stat Keeper name
          Expanded(
            child: Text(
              statKeeper['name']!,
              style: const TextStyle(
                color: Color.fromRGBO(17, 24, 39, 1),
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Gmail icon instead of delete icon
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invite sent to ${statKeeper['name']}'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Icon(
              Icons.mail_outline,
              color: Colors.blueGrey,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class AddOfficialPage extends StatefulWidget {
  final String officialType;

  const AddOfficialPage({super.key, required this.officialType});

  @override
  _AddOfficialPageState createState() => _AddOfficialPageState();
}

class _AddOfficialPageState extends State<AddOfficialPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Determine tabs based on official type
    List<String> tabs = [];
    if (widget.officialType.toLowerCase() == 'referee') {
      tabs = ['Referee', 'Free Agent'];
    } else if (widget.officialType.toLowerCase() == 'stat keeper') {
      tabs = ['Stat Keeper', 'Free Agent'];
    } else {
      tabs = ['Search', 'Suggested'];
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add ${widget.officialType}',
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invite ${widget.officialType} to join this league. You can search existing officials.',
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Dynamic tabs based on official type
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedIndex == 0 
                          ? const Color(0xFF4285F4) // Blue button color
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedIndex == 0 
                            ? const Color(0xFF3B82F6) 
                            : const Color(0xFFE5E7EB),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tabs[0],
                        style: TextStyle(
                          color: _selectedIndex == 0 
                              ? Colors.white // White text for blue button
                              : const Color(0xFF111827),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedIndex == 1 
                          ? const Color(0xFF4285F4) // Blue button color
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedIndex == 1 
                            ? const Color(0xFF3B82F6) 
                            : const Color(0xFFE5E7EB),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tabs[1],
                        style: TextStyle(
                          color: _selectedIndex == 1 
                              ? Colors.white // White text for blue button
                              : const Color(0xFF111827),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search bar - always visible for both tabs
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD1D5DB)),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search by official name',
                  hintStyle: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12.0, // Reduced hint text size
                  ),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Suggested Officials',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _SuggestedOfficialsList(),
          ],
        ),
      ),
    );
  }
}

class _SuggestedOfficialsList extends StatelessWidget {
  _SuggestedOfficialsList();

  final List<Map<String, String>> _officials = [
    {
      'name': 'John Smith',
      'role': 'Professional Referee',
      'experience': '5 years',
      'rating': '4.8',
      'image': 'assets/images/Image 12.png',
    },
    {
      'name': 'Michael Johnson',
      'role': 'Certified Stat Keeper',
      'experience': '3 years',
      'rating': '4.6',
      'image': 'assets/images/Image 12.png',
    },
    {
      'name': 'Sarah Williams',
      'role': 'Senior Referee',
      'experience': '8 years',
      'rating': '4.9',
      'image': 'assets/images/Image 12.png',
    },
    {
      'name': 'David Thompson',
      'role': 'Lead Stat Keeper',
      'experience': '6 years',
      'rating': '4.7',
      'image': 'assets/images/Image 12.png',
    },
    {
      'name': 'Emily Davis',
      'role': 'Professional Referee',
      'experience': '4 years',
      'rating': '4.5',
      'image': 'assets/images/Image 12.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _officials.map((official) {
        return _buildOfficialItem(context, official);
      }).toList(),
    );
  }

  Widget _buildOfficialItem(
    BuildContext context,
    Map<String, String> official,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromRGBO(229, 231, 235, 1),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                official['image'] ?? 'assets/images/Image 12.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color.fromRGBO(243, 244, 246, 1),
                    child: const Icon(
                      Icons.person,
                      color: Color.fromRGBO(156, 163, 175, 1),
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Official info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  official['name']!,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invite sent to ${official['name']}'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Icon(
              Icons.mail_outline,
              color: Colors.blueGrey,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}