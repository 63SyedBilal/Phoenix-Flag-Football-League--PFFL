import 'package:flutter/material.dart';
import 'package:pffl_managment/core/utils/validators.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/features/admin/leagues/providers/enhanced_leagues_provider.dart';
import 'package:provider/provider.dart';

enum EntryFeeType { captain, perPlayer, free }

class CreateLeagueViewModel extends ChangeNotifier {
  final TextEditingController perPlayerFeeController = TextEditingController();
  final TextEditingController leagueNameController = TextEditingController();
  

  int _currentStep = 0;
  String _leagueName = '';
  String _selectedLogoId = '1'; // Default to first logo
  String _uploadedLogoPath = '';
  List<String> _selectedPlayerIds = [];
  List<String> _selectedRefereeIds = []; // New property for referees
  List<String> _selectedStatKeeperIds = []; // New property for stat keepers
  String _captainId =
      ''; // Keep for now to avoid breaking changes, but not used
  double _registrationFee = 50.0;
  DateTime? _startDate = DateTime(2025, 12, 10); // Default start date
  DateTime? _endDate = DateTime(2026, 3, 20); // Default end date
  int _minPlayers = 8;
  int _formatPlayers = 5;

  // Text editing controllers state
  String _leagueNameText = '';
  String _perPlayerFeeText = '250';

  // Map to track email sending status for each referee
  final Map<String, bool> _emailSendingStatus = {};
  // Map to track email sending status for stat keepers
  final Map<String, bool> _statKeeperEmailStatus = {};

  // Search query for referees
  String _refereeSearchQuery = '';
  // Search query for stat keepers
  String _statKeeperSearchQuery = '';

  // Team expansion state
  final Map<String, bool> _teamExpansionState = {};

  EntryFeeType _entryFeeType = EntryFeeType.captain;
  double _perPlayerFee = 250.0;
  bool _isLoading = false;

  int get currentStep => _currentStep;
  String get leagueName => _leagueName;
  String get selectedLogoId => _selectedLogoId;
  String get uploadedLogoPath => _uploadedLogoPath;
  List<String> get selectedPlayerIds => _selectedPlayerIds;
  List<String> get selectedRefereeIds => _selectedRefereeIds; // New getter
  List<String> get selectedStatKeeperIds =>
      _selectedStatKeeperIds; // New getter
  String get captainId =>
      _captainId; // Keep for now to avoid breaking changes, but not used
  double get registrationFee => _registrationFee;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  int get minPlayers => _minPlayers;
  int get formatPlayers => _formatPlayers;
  EntryFeeType get entryFeeType => _entryFeeType;
  double get perPlayerFee => _perPlayerFee;
  bool get isLoading => _isLoading;

  // Text editing getters
  String get leagueNameText => _leagueNameText;
  String get perPlayerFeeText => _perPlayerFeeText;
  String get refereeSearchQuery => _refereeSearchQuery;
  String get statKeeperSearchQuery => _statKeeperSearchQuery;

  // Method to check if an email is being sent to a referee
  bool isEmailSending(String refereeId) =>
      _emailSendingStatus[refereeId] ?? false;

  // Method to check if an email has been sent to a stat keeper
  bool isEmailSent(String statKeeperId) =>
      _statKeeperEmailStatus[statKeeperId] ?? false;

  // Validation errors
  String? _leagueNameError;
  String? _perPlayerFeeError;
  String? _dateRangeError;
  String? _minPlayersError;

  String? get leagueNameError => _leagueNameError;
  String? get perPlayerFeeError => _perPlayerFeeError;
  String? get dateRangeError => _dateRangeError;
  String? get minPlayersError => _minPlayersError;

  // Validation flags
  bool get isStep1Valid =>
      _leagueName.trim().isNotEmpty &&
      _leagueNameError == null &&
      (_perPlayerFeeError == null || _entryFeeType != EntryFeeType.perPlayer) &&
      (_selectedLogoId.isNotEmpty || _uploadedLogoPath.isNotEmpty) &&
      _startDate != null &&
      _endDate != null &&
      _startDate!.isBefore(_endDate!) &&
      _dateRangeError == null &&
      _minPlayers > 0 &&
      _minPlayersError == null;
  bool get isStep2Valid =>
      _selectedRefereeIds.isNotEmpty; // At least one referee must be selected
  bool get isStep3Valid =>
      _selectedStatKeeperIds.isNotEmpty; // At least one stat keeper must be selected
  bool get isStep4Valid =>
      (_entryFeeType != EntryFeeType.perPlayer ||
      (_perPlayerFee > 0 &&
          _perPlayerFeeError == null)); // Fee setting step validation

  // Available team logos
  List<TeamLogoModel> get teamLogos => [
    TeamLogoModel(
      id: '1',
      url:
          'https://api.dicebear.com/7.x/shapes/png?seed=Phoenix&backgroundColor=db1f35',
      name: 'Phoenix',
    ),
    TeamLogoModel(
      id: '2',
      url:
          'https://api.dicebear.com/7.x/shapes/png?seed=Thunder&backgroundColor=3b82f6',
      name: 'Thunder',
    ),
    TeamLogoModel(
      id: '3',
      url:
          'https://api.dicebear.com/7.x/shapes/png?seed=Storm&backgroundColor=10b981',
      name: 'Storm',
    ),
    TeamLogoModel(
      id: '4',
      url:
          'https://api.dicebear.com/7.x/shapes/png?seed=Lightning&backgroundColor=f59e0b',
      name: 'Lightning',
    ),
    TeamLogoModel(
      id: '5',
      url:
          'https://api.dicebear.com/7.x/shapes/png?seed=Falcons&backgroundColor=8b5cf6',
      name: 'Falcons',
    ),
    TeamLogoModel(
      id: '6',
      url:
          'https://api.dicebear.com/7.x/shapes/png?seed=Dragons&backgroundColor=ec4899',
      name: 'Dragons',
    ),
  ];

  // Available players
  List<PlayerModel> get availablePlayers => [
    PlayerModel(
      id: '1',
      name: 'Marcus Johnson',
      email: 'marcus.j@pffl.com',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Marcus',
    ),
    PlayerModel(
      id: '2',
      name: 'Sarah Mitchell',
      email: 'sarah.m@pffl.com',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Sarah',
    ),
    PlayerModel(
      id: '3',
      name: 'David Thompson',
      email: 'david.t@pffl.com',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=David',
    ),
    PlayerModel(
      id: '4',
      name: 'Lisa Anderson',
      email: 'lisa.a@pffl.com',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Lisa',
    ),
    PlayerModel(
      id: '5',
      name: 'Robert Wilson',
      email: 'robert.w@pffl.com',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Robert',
    ),
    PlayerModel(
      id: '6',
      name: 'Amanda Torres',
      email: 'amanda.t@pffl.com',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Amanda',
    ),
    PlayerModel(
      id: '7',
      name: 'James Richardson',
      email: 'james.r@pffl.com',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=James',
    ),
    PlayerModel(
      id: '8',
      name: 'Emily Chen',
      email: 'emily.c@pffl.com',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Emily',
    ),
  ];

  // Available referees (for now using the same players, but in a real app these would be different)
  List<PlayerModel> get availableReferees => [
    PlayerModel(
      id: '1',
      name: 'John Carter',
      email: 'john.c@pffl.com',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=John',
    ),
    PlayerModel(
      id: '2',
      name: 'Michael Lee',
      email: 'michael.l@pffl.com',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Michael',
    ),
    PlayerModel(
      id: '3',
      name: 'Anthony Brooks',
      email: 'anthony.b@pffl.com',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Anthony',
    ),
    PlayerModel(
      id: '4',
      name: 'Sarah Wilson',
      email: 'sarah.w@pffl.com',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=SarahW',
    ),
    PlayerModel(
      id: '5',
      name: 'David Martinez',
      email: 'david.m@pffl.com',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=DavidM',
    ),
  ];

  // Available stat keepers
  List<PlayerModel> get availableStatKeepers => [
    PlayerModel(
      id: '1',
      name: 'Alex Morgan',
      email: 'alex.m@pffl.com',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Alex',
    ),
    PlayerModel(
      id: '2',
      name: 'Rebecca Torres',
      email: 'rebecca.t@pffl.com',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Rebecca',
    ),
    PlayerModel(
      id: '3',
      name: 'David Brooks',
      email: 'david.b@pffl.com',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=David',
    ),
    PlayerModel(
      id: '4',
      name: 'Sarah Wilson',
      email: 'sarah.w@pffl.com',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Sarah',
    ),
    PlayerModel(
      id: '5',
      name: 'Michael Chen',
      email: 'michael.c@pffl.com',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Michael',
    ),
  ];

  List<PaymentStatusModel> getPaymentStatuses() {
    return _selectedPlayerIds.map((playerId) {
      final player = availablePlayers.firstWhere((p) => p.id == playerId);
      final statusIndex = int.parse(playerId) % 3;
      PaymentStatus status;
      DateTime? paidAt;

      if (statusIndex == 0) {
        status = PaymentStatus.paid;
        paidAt = DateTime.now().subtract(const Duration(days: 2));
      } else if (statusIndex == 1) {
        status = PaymentStatus.pending;
      } else {
        status = PaymentStatus.overdue;
      }

      return PaymentStatusModel(
        playerId: player.id,
        playerName: player.name,
        amount: _registrationFee,
        status: status,
        paidAt: paidAt,
      );
    }).toList();
  }

  void setLeagueName(String name) {
    _leagueName = name;
    // Validate the league name
    _leagueNameError = Validators.validateLeagueName(name);
    notifyListeners();
  }

  void setUploadedLogo(String path) {
    _uploadedLogoPath = path;
    notifyListeners();
  }

  void setFormatPlayers(int players) {
    _formatPlayers = players;
    notifyListeners();
  }

  void selectLogo(String logoId) {
    _selectedLogoId = logoId;
    notifyListeners();
  }

  void setStartDate(DateTime date) {
    _startDate = date;
    // Validate date range
    if (_startDate != null && _endDate != null) {
      if (!_startDate!.isBefore(_endDate!)) {
        _dateRangeError = 'Start date must be before end date';
      } else {
        _dateRangeError = null;
      }
    }
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    _endDate = date;
    // Validate date range
    if (_startDate != null && _endDate != null) {
      if (!_startDate!.isBefore(_endDate!)) {
        _dateRangeError = 'Start date must be before end date';
      } else {
        _dateRangeError = null;
      }
    }
    notifyListeners();
  }

  void setMinPlayers(int value) {
    _minPlayers = value;
    // Validate minimum players
    if (_minPlayers <= 0) {
      _minPlayersError = 'Minimum players must be greater than 0';
    } else {
      _minPlayersError = null;
    }
    notifyListeners();
  }

  void setEntryFeeType(EntryFeeType type) {
    _entryFeeType = type;
    // Re-validate the fee when entry fee type changes
    if (type == EntryFeeType.perPlayer && _perPlayerFeeText.isNotEmpty) {
      _perPlayerFeeError = Validators.validateNumeric(
        _perPlayerFeeText,
        'Per player fee',
      );
    } else {
      _perPlayerFeeError = null;
    }
    notifyListeners();
  }

  void setPerPlayerFee(double fee) {
    _perPlayerFee = fee;
    notifyListeners();
  }

  void togglePlayerSelection(String playerId) {
    if (_selectedPlayerIds.contains(playerId)) {
      _selectedPlayerIds.remove(playerId);
      // If the removed player was the captain, clear captain selection
      if (_captainId == playerId) {
        _captainId = '';
      }
    } else {
      _selectedPlayerIds.add(playerId);
    }
    notifyListeners();
  }

  // New method for toggling referee selection
  void toggleRefereeSelection(String refereeId) {
    if (_selectedRefereeIds.contains(refereeId)) {
      _selectedRefereeIds.remove(refereeId);
    } else {
      _selectedRefereeIds.add(refereeId);
    }
    notifyListeners();
  }

  // New method for toggling stat keeper selection
  void toggleStatKeeperSelection(String statKeeperId) {
    if (_selectedStatKeeperIds.contains(statKeeperId)) {
      _selectedStatKeeperIds.remove(statKeeperId);
    } else {
      _selectedStatKeeperIds.add(statKeeperId);
    }
    notifyListeners();
  }

  // Method to start sending email to a referee
  void startSendingEmail(String refereeId) {
    _emailSendingStatus[refereeId] = true;
    notifyListeners();
  }

  // Method to finish sending email to a referee
  void finishSendingEmail(String refereeId) {
    _emailSendingStatus[refereeId] = false;
    notifyListeners();
  }

  // Method to send email to a stat keeper
  void sendEmailToStatKeeper(String statKeeperId) {
    _statKeeperEmailStatus[statKeeperId] = true;
    notifyListeners();

    // In a real implementation, you would make an API call here
    // For now, we're just updating the state to show the email was sent
  }

  // Text editing methods
  void setLeagueNameText(String text) {
    _leagueNameText = text;
    notifyListeners();
  }

  void setPerPlayerFeeText(String text) {
    _perPlayerFeeText = text;
    // Validate the fee only if it's not empty and we're using per player fee type
    if (_entryFeeType == EntryFeeType.perPlayer && text.isNotEmpty) {
      _perPlayerFeeError = Validators.validateNumeric(text, 'Per player fee');
    } else {
      _perPlayerFeeError = null;
    }
    final fee = double.tryParse(text) ?? 0.0;
    setPerPlayerFee(fee);
    notifyListeners();
  }

  void setRefereeSearchQuery(String query) {
    _refereeSearchQuery = query.toLowerCase();
    notifyListeners();
  }

  void setStatKeeperSearchQuery(String query) {
    _statKeeperSearchQuery = query.toLowerCase();
    notifyListeners();
  }

  bool isTeamExpanded(String teamId) {
    return _teamExpansionState[teamId] ?? false;
  }

  void toggleTeamExpansion(String teamId) {
    _teamExpansionState[teamId] = !(_teamExpansionState[teamId] ?? false);
    notifyListeners();
  }

  void setRegistrationFee(double fee) {
    _registrationFee = fee;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 4) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 4) {
      _currentStep = step;
      notifyListeners();
    }
  }

  Future<void> createLeague(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final league = LeagueCreationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      leagueName: _leagueName,
      teamLogo: _uploadedLogoPath.isNotEmpty
          ? _uploadedLogoPath
          : _selectedLogoId,
      selectedPlayerIds: _selectedPlayerIds,
      captainId: _captainId,
      registrationFee: _registrationFee,
      createdAt: DateTime.now(),
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now().add(const Duration(days: 90)),
    );

    debugPrint('League created: ${league.leagueName}');
    debugPrint('Players: ${league.selectedPlayerIds.length}');
    debugPrint('Captain: ${league.captainId}');
    debugPrint('Fee: \$${league.registrationFee}');

    // Add the created league to the enhanced leagues provider
    final leaguesProvider = Provider.of<EnhancedLeaguesProvider>(context, listen: false);
    leaguesProvider.addLeague(league);

    _isLoading = false;
    notifyListeners();

    // Send notifications to selected players
    await _sendNotifications();
  }

  Future<void> _sendNotifications() async {
    // Simulate sending notifications
    debugPrint(
      'Sending payment notifications to ${_selectedPlayerIds.length} players',
    );
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void reset() {
    _currentStep = 0;
    _leagueName = '';
    _selectedLogoId = '1';
    _selectedPlayerIds = [];
    _selectedRefereeIds = []; // Reset referees as well
    _selectedStatKeeperIds = []; // Reset stat keepers as well
    _captainId = '';
    _registrationFee = 50.0;
    _isLoading = false;
    _emailSendingStatus.clear(); // Clear email sending status
    _statKeeperEmailStatus.clear(); // Clear stat keeper email status
    _leagueNameText = '';
    _perPlayerFeeText = '250';
    notifyListeners();
  }

  int get totalPaid =>
      getPaymentStatuses().where((p) => p.status == PaymentStatus.paid).length;
  int get totalPending => getPaymentStatuses()
      .where((p) => p.status == PaymentStatus.pending)
      .length;
  int get totalOverdue => getPaymentStatuses()
      .where((p) => p.status == PaymentStatus.overdue)
      .length;
  double get totalCollected => getPaymentStatuses()
      .where((p) => p.status == PaymentStatus.paid)
      .fold(0.0, (sum, p) => sum + p.amount);
}
