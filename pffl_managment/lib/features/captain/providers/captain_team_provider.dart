import 'package:flutter/material.dart';
import '../model/player_model.dart';
import '../model/team_model.dart';

class CaptainTeamProvider extends ChangeNotifier {
  Map<String, TeamModel> _teams = {};
  String _selectedFormat = '5v5';
  bool _isLoading = false;

  TeamModel? get team => _teams[_selectedFormat];
  String get selectedFormat => _selectedFormat;
  bool get isLoading => _isLoading;

  CaptainTeamProvider() {
    loadTeamData();
  }

  void setFormat(String format) {
    if (_selectedFormat != format) {
      _selectedFormat = format;
      notifyListeners();
    }
  }

  Future<void> loadTeamData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock Data
    _teams = {
      '5v5': TeamModel(
        id: 't1',
        name: 'STA',
        logoUrl: 'assets/images/image 12.png',
        format: '5v5',
        maxPlayers: 8,
        players: [
          PlayerModel(
            id: 'p1',
            name: 'James Richardson',
            number: '10',
            email: 'james.r@pffl.com',
            position: 'Rusher',
            isCaptain: true,
            isPaid: true,
            additionalPositionsCount: 5,
            imageUrl: 'assets/images/image 14.png',
          ),
          PlayerModel(
            id: 'p2',
            name: 'George Martin',
            number: '10',
            email: 'georgemartin.j@pffl.com',
            position: 'Rusher',
            isCaptain: false,
            isPaid: true,
            isVerified: true,
            additionalPositionsCount: 5,
            imageUrl: 'assets/images/image 15.png',
          ),
          PlayerModel(
            id: 'p3',
            name: 'George Martin',
            number: '10',
            email: 'georgemartin.j@pffl.com',
            position: 'Rusher',
            isCaptain: false,
            isPaid: true,
            isVerified: true,
            additionalPositionsCount: 5,
            imageUrl: 'assets/images/image 15.png',
          ),
          PlayerModel(
            id: 'p4',
            name: 'George Lee',
            number: '27',
            email: 'georgelee.j@pffl.com',
            position: 'Rusher',
            isCaptain: false,
            isPaid: false,
            hasAlert: true,
            additionalPositionsCount: 5,
            imageUrl: 'assets/images/image 15.png',
          ),
          PlayerModel(
            id: 'p5',
            name: 'George Martin',
            number: '10',
            email: 'georgemartin.j@pffl.com',
            position: 'Rusher',
            isCaptain: false,
            isPaid: true,
            hasAlert: true,
            additionalPositionsCount: 5,
            imageUrl: 'assets/images/image 15.png',
          ),
        ],
      ),
      '7v7': TeamModel(
        id: 't2',
        name: 'STA 7s',
        logoUrl: 'assets/images/image 12.png',
        format: '7v7',
        maxPlayers: 12,
        players: [
          PlayerModel(
            id: 'p6',
            name: 'Sarah Connor',
            number: '01',
            email: 'sarah.c@pffl.com',
            position: 'Receiver',
            isCaptain: true,
          ),
          PlayerModel(
            id: 'p7',
            name: 'Kyle Reese',
            number: '02',
            email: 'kyle.r@pffl.com',
            position: 'Quarterback',
          ),
          PlayerModel(
            id: 'p8',
            name: 'John Doe',
            number: '03',
            email: 'john.d@pffl.com',
            position: 'Rusher',
          ),
        ],
      ),
    };

    _isLoading = false;
    notifyListeners();
  }
}
