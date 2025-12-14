import 'package:flutter/material.dart';

class AddOfficials extends StatelessWidget {
  const AddOfficials({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildTitle(),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(child: _buildRefereesList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Referees',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF000000),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Choose referees for this Game.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search by Referees name',
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            suffixIcon: Icon(
              Icons.search,
              color: Colors.grey[400],
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRefereesList() {
    final referees = [
      _RefereeData('John Carter', 'assets/avatars/john.png'),
      _RefereeData('Michael Lee', 'assets/avatars/michael.png'),
      _RefereeData('Anthony Brooks', 'assets/avatars/anthony.png'),
      _RefereeData('John Carter', 'assets/avatars/john.png'),
      _RefereeData('Michael Lee', 'assets/avatars/michael.png'),
      _RefereeData('Anthony Brooks', 'assets/avatars/anthony.png'),
      _RefereeData('Michael Lee', 'assets/avatars/michael.png'),
      _RefereeData('Michael Lee', 'assets/avatars/michael.png'),
      _RefereeData('Michael Lee', 'assets/avatars/michael.png'),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: referees.length,
      itemBuilder: (context, index) {
        return _buildRefereeCard(referees[index]);
      },
    );
  }

  Widget _buildRefereeCard(_RefereeData referee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE5E7EB),
            ),
            child: ClipOval(
              child: Image.asset(
                referee.avatar,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  color: Color(0xFF9CA3AF),
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              referee.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.add,
              size: 22,
              color: Color(0xFF9CA3AF),
            ),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _RefereeData {
  final String name;
  final String avatar;

  _RefereeData(this.name, this.avatar);
}