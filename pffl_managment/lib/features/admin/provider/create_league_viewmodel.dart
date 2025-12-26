import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/core/services/user_service.dart';
import 'package:pffl_managment/core/services/league_service.dart';
import 'package:pffl_managment/core/services/profile_service.dart';
import 'package:pffl_managment/features/admin/leagues/providers/enhanced_leagues_provider.dart';
import 'dart:io';

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
  List<String> _selectedFreeAgentIds = []; // New property for free agents
  String _captainId =
      ''; // Keep for now to avoid breaking changes, but not used
  String _leagueId = ''; // Store leagueId after league is created
  double _registrationFee = 50.0;
  DateTime? _startDate; // User must select start date
  DateTime? _endDate; // User must select end date
  int _minPlayers = 0; // User must select minimum players
  int _formatPlayers = 5;

  // Text editing controllers state
  String _leagueNameText = '';
  String _perPlayerFeeText = ''; // User must enter fee

  // Map to track email sending status for each referee
  final Map<String, bool> _emailSendingStatus = {};
  // Map to track email sending status for stat keepers
  final Map<String, bool> _statKeeperEmailStatus = {};
  // Map to track email sending status for free agents
  final Map<String, bool> _freeAgentEmailStatus = {};

  // Referees list from API
  List<UserModel> _referees = [];
  bool _isLoadingReferees = false;
  bool _hasAttemptedRefereesFetch =
      false; // Track if we've attempted to fetch referees
  // Map to store profile image URLs for referees (userId -> imageUrl)
  final Map<String, String?> _refereeProfileImages = {};

  // Free agents list from API
  List<UserModel> _freeAgents = [];
  bool _isLoadingFreeAgents = false;

  // Stat keepers list from API
  List<UserModel> _statKeepers = [];
  bool _isLoadingStatKeepers = false;
  bool _hasAttemptedStatKeepersFetch =
      false; // Track if we've attempted to fetch stat keepers
  // Map to store profile image URLs for stat keepers (userId -> imageUrl)
  final Map<String, String?> _statKeeperProfileImages = {};

  // Player profile data cache (playerId -> profile data)
  final Map<String, Map<String, dynamic>?> _playerProfilesCache = {};
  bool _isLoadingPlayerProfile = false;

  // Referee invitation tracking (sent invites, not selection)
  final Map<String, bool> _refereeInviteSending = {}; // Currently sending
  final Map<String, bool> _refereeInviteSent = {}; // Successfully sent

  // Stat keeper invitation tracking (sent invites, not selection)
  final Map<String, bool> _statKeeperInviteSending = {}; // Currently sending
  final Map<String, bool> _statKeeperInviteSent = {}; // Successfully sent

  // Teams list from API
  List<TeamModel> _teams = [];
  bool _isLoadingTeams = false;
  List<String> _selectedTeamIds = [];
  final Map<String, bool> _teamEmailStatus =
      {}; // Tracks if email is currently being sent
  final Map<String, bool> _teamEmailSent =
      {}; // Tracks if email was successfully sent
  String _teamSearchQuery = '';

  // Search query for referees
  String _refereeSearchQuery = '';
  // Search query for stat keepers
  String _statKeeperSearchQuery = '';
  // Search query for free agents
  String _freeAgentSearchQuery = '';

  // Team expansion state
  final Map<String, bool> _teamExpansionState = {};

  EntryFeeType _entryFeeType = EntryFeeType.captain;
  double _perPlayerFee = 0.0; // User must enter fee
  bool _isLoading = false;

  int get currentStep => _currentStep;
  String get leagueName => _leagueName;
  String get selectedLogoId => _selectedLogoId;
  String get uploadedLogoPath => _uploadedLogoPath;
  String get leagueId => _leagueId;
  List<String> get selectedPlayerIds => _selectedPlayerIds;
  List<String> get selectedRefereeIds => _selectedRefereeIds; // New getter
  List<String> get selectedStatKeeperIds =>
      _selectedStatKeeperIds; // New getter
  List<String> get selectedFreeAgentIds => _selectedFreeAgentIds; // New getter
  List<UserModel> get referees => _referees;
  bool get isLoadingReferees => _isLoadingReferees;
  bool get hasAttemptedRefereesFetch => _hasAttemptedRefereesFetch;
  List<UserModel> get freeAgents => _freeAgents;
  bool get isLoadingFreeAgents => _isLoadingFreeAgents;
  String get captainId =>
      _captainId; // Keep for now to avoid breaking changes, but not used
  double get registrationFee => _registrationFee;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  int get minPlayers => _minPlayers;
  int get formatPlayers => _formatPlayers;
  // Get format as "5v5" or "7v7" string for API
  String get formatString => '${_formatPlayers}v$_formatPlayers';
  EntryFeeType get entryFeeType => _entryFeeType;
  double get perPlayerFee => _perPlayerFee;
  bool get isLoading => _isLoading;

  // Text editing getters
  String get leagueNameText => _leagueNameText;
  String get perPlayerFeeText => _perPlayerFeeText;
  String get refereeSearchQuery => _refereeSearchQuery;

  // Get filtered referees based on search query
  List<UserModel> get filteredReferees {
    if (_refereeSearchQuery.isEmpty) {
      return _referees;
    }
    return _referees.where((referee) {
      final name = referee.displayName.toLowerCase();
      final email = referee.email.toLowerCase();
      return name.contains(_refereeSearchQuery) ||
          email.contains(_refereeSearchQuery);
    }).toList();
  }

  String get statKeeperSearchQuery => _statKeeperSearchQuery;

  // Get filtered stat keepers based on search query
  List<UserModel> get filteredStatKeepers {
    if (_statKeeperSearchQuery.isEmpty) {
      return _statKeepers;
    }
    return _statKeepers.where((statKeeper) {
      final name = statKeeper.displayName.toLowerCase();
      final email = statKeeper.email.toLowerCase();
      return name.contains(_statKeeperSearchQuery) ||
          email.contains(_statKeeperSearchQuery);
    }).toList();
  }

  String get freeAgentSearchQuery => _freeAgentSearchQuery;
  List<UserModel> get statKeepers => _statKeepers;
  bool get isLoadingStatKeepers => _isLoadingStatKeepers;
  bool get hasAttemptedStatKeepersFetch => _hasAttemptedStatKeepersFetch;
  bool get isLoadingPlayerProfile => _isLoadingPlayerProfile;
  List<TeamModel> get teams => _teams;
  bool get isLoadingTeams => _isLoadingTeams;
  List<String> get selectedTeamIds => _selectedTeamIds;
  String get teamSearchQuery => _teamSearchQuery;

  // Get filtered teams based on search query
  List<TeamModel> get filteredTeams {
    if (_teamSearchQuery.isEmpty) {
      return _teams;
    }
    return _teams.where((team) {
      final teamName = team.teamName.toLowerCase();
      return teamName.contains(_teamSearchQuery);
    }).toList();
  }

  // Method to check if an email is being sent to a referee
  bool isEmailSending(String refereeId) =>
      _emailSendingStatus[refereeId] ?? false;

  // Method to check if an email has been sent to a stat keeper
  bool isEmailSent(String statKeeperId) =>
      _statKeeperEmailStatus[statKeeperId] ?? false;

  // Validation errors
  String? _leagueNameError;
  String? _perPlayerFeeError;
  String? _startDateError;
  String? _endDateError;
  String? _minPlayersError;
  String? _logoError;

  String? get leagueNameError => _leagueNameError;
  String? get perPlayerFeeError => _perPlayerFeeError;
  String? get startDateError => _startDateError;
  String? get endDateError => _endDateError;

  int? get durationDays {
    if (_startDate == null || _endDate == null) return null;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  String? get minPlayersError => _minPlayersError;
  String? get logoError => _logoError;

  // Validation flags
  bool get isStep1Valid =>
      _leagueName.trim().isNotEmpty &&
      _leagueNameError == null &&
      _perPlayerFeeText.isNotEmpty &&
      _perPlayerFee > 0 &&
      _perPlayerFeeError == null &&
      // Logo is optional - no validation required
      _startDate != null &&
      _startDateError == null &&
      _endDate != null &&
      _endDateError == null &&
      _minPlayers > 0 &&
      _minPlayers <= 15 &&
      _minPlayersError == null;

  // Enhanced validation methods for form validation
  String? validateLeagueName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'League name is required';
    }
    if (value.trim().length < 3) {
      return 'League name must be at least 3 characters';
    }
    if (value.trim().length > 50) {
      return 'League name must be less than 50 characters';
    }
    return null;
  }

  String? validatePerPlayerFee(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Per player fee is required';
    }
    final fee = double.tryParse(value.trim());
    if (fee == null) {
      return 'Please enter a valid number';
    }
    if (fee <= 0) {
      return 'Fee must be greater than 0';
    }
    if (fee > 10000) {
      return 'Fee must be less than \$10,000';
    }
    return null;
  }

  // Clear validation errors
  void clearValidationErrors() {
    _leagueNameError = null;
    _perPlayerFeeError = null;
    _logoError = null;
    _startDateError = null;
    _endDateError = null;
    _minPlayersError = null;
    notifyListeners();
  }

  bool get isStep2Valid =>
      true; // No selection required - invitations sent via icon only
  bool get isStep3Valid =>
      true; // No selection required - invitations sent via icon only

  // Step 4 validation: User must be on Step 4 (currentStep == 3) to complete
  // This ensures league is only created after Step 4 is reached
  bool get isStep4Valid {
    // User must be on Step 4 (0-indexed: step 3)
    if (_currentStep != 3) {
      return false;
    }

    // Fee validation (if per player fee is selected)
    if (_entryFeeType == EntryFeeType.perPlayer) {
      if (_perPlayerFee <= 0 || _perPlayerFeeError != null) {
        return false;
      }
    }

    // Step 4 is valid when user is on this step
    return true;
  }

  // Check if Step 4 has been completed (user has reached Step 4)
  bool get isStep4Completed => _currentStep == 3;

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
  // This is kept for backward compatibility but Step 2 now uses free agents
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
    // Clear error when user types
    if (name.trim().isNotEmpty) {
      _leagueNameError = null;
    }
    notifyListeners();
  }

  void setUploadedLogo(String path) {
    _uploadedLogoPath = path;
    // Clear error when user uploads logo
    if (path.isNotEmpty) {
      _logoError = null;
    }
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
    // Clear error when date is selected
    _startDateError = null;
    // Validate: Start date must be today or in the future
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selectedDate = DateTime(date.year, date.month, date.day);
    if (selectedDate.isBefore(todayDate)) {
      _startDateError = 'Start date must be today or a future date';
    }
    // Validate: End date must be after start date
    if (_endDate != null) {
      final endDateOnly = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
      );
      if (!selectedDate.isBefore(endDateOnly)) {
        _endDateError = 'End date must be after start date';
      } else {
        _endDateError = null;
      }
    }
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    _endDate = date;
    // Clear error when date is selected
    _endDateError = null;
    // Validate: End date must be after start date
    if (_startDate != null) {
      final startDateOnly = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
      );
      final endDateOnly = DateTime(date.year, date.month, date.day);
      if (!startDateOnly.isBefore(endDateOnly)) {
        _endDateError = 'End date must be after start date';
      }
    }
    notifyListeners();
  }

  void setMinPlayers(int value) {
    _minPlayers = value;
    // Clear error when value is valid (1-15)
    if (value >= 1 && value <= 15) {
      _minPlayersError = null;
    }
    notifyListeners();
  }

  void setEntryFeeType(EntryFeeType type) {
    _entryFeeType = type;
    notifyListeners();
  }

  void setPerPlayerFee(double fee) {
    _perPlayerFee = fee;
    // Clear error when fee is valid
    if (fee > 0) {
      _perPlayerFeeError = null;
    }
    notifyListeners();
  }

  /// Validate all Step 1 fields and show errors
  /// Returns true if all fields are valid
  bool validateStep1() {
    bool isValid = true;

    // Validate League Name
    if (_leagueName.trim().isEmpty) {
      _leagueNameError = 'League name is required';
      isValid = false;
    } else {
      _leagueNameError = null;
    }

    // Validate Logo
    // TODO: Uncomment this validation in the future when logo upload is required
    // if (_uploadedLogoPath.isEmpty) {
    //   _logoError = 'Please upload a league logo';
    //   isValid = false;
    // } else {
    //   _logoError = null;
    // }

    // For now, clear any existing logo error
    _logoError = null;

    // Validate Start Date
    if (_startDate == null) {
      _startDateError = 'Start date is required';
      isValid = false;
    } else {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final selectedDate = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
      );
      if (selectedDate.isBefore(todayDate)) {
        _startDateError = 'Start date must be today or a future date';
        isValid = false;
      } else {
        _startDateError = null;
      }
    }

    // Validate End Date
    if (_endDate == null) {
      _endDateError = 'End date is required';
      isValid = false;
    } else if (_startDate != null) {
      final startDateOnly = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
      );
      final endDateOnly = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
      );
      if (!startDateOnly.isBefore(endDateOnly)) {
        _endDateError = 'End date must be after start date';
        isValid = false;
      } else {
        _endDateError = null;
      }
    }

    // Validate Minimum Players (1-15)
    if (_minPlayers == 0) {
      _minPlayersError = 'Please select minimum players';
      isValid = false;
    } else if (_minPlayers < 1 || _minPlayers > 15) {
      _minPlayersError = 'Minimum players must be between 1 and 15';
      isValid = false;
    } else {
      _minPlayersError = null;
    }

    // Validate Per Player Fee (must be > 0)
    if (_perPlayerFeeText.isEmpty) {
      _perPlayerFeeError = 'League fee is required';
      isValid = false;
    } else if (_perPlayerFee <= 0) {
      _perPlayerFeeError = 'League fee must be greater than 0';
      isValid = false;
    } else {
      _perPlayerFeeError = null;
    }

    notifyListeners();
    return isValid;
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

  // Fetch referees from API
  Future<void> fetchReferees() async {
    if (_isLoadingReferees || _hasAttemptedRefereesFetch) return;

    _isLoadingReferees = true;
    _hasAttemptedRefereesFetch = true; // Mark that we've attempted to fetch
    notifyListeners();

    try {
      debugPrint('🔄 Fetching referees...');
      _referees = await UserService.getReferees();
      debugPrint('✅ Fetched ${_referees.length} referees');

      // Fetch profile images for referees
      await _fetchRefereeProfileImages();
    } catch (e) {
      debugPrint('❌ Error fetching referees: $e');
      _referees = [];
    } finally {
      _isLoadingReferees = false;
      notifyListeners();
    }
  }

  // Retry fetching referees (resets the attempt flag)
  void retryFetchReferees() {
    _hasAttemptedRefereesFetch = false;
    fetchReferees();
  }

  // Fetch profile images for referees
  Future<void> _fetchRefereeProfileImages() async {
    _refereeProfileImages.clear();

    // Fetch profiles for all referees in parallel
    final futures = _referees.map((referee) async {
      try {
        final profile = await ProfileService.getProfile(referee.id);
        if (profile != null &&
            profile['image'] != null &&
            profile['image'].toString().isNotEmpty) {
          final img = profile['image'].toString();
          // Only use valid http URLs
          if (img.startsWith('http')) {
            _refereeProfileImages[referee.id] = img;
            return;
          }
        }
        _refereeProfileImages[referee.id] = null;
      } catch (e) {
        debugPrint('⚠️ Error fetching profile for referee ${referee.id}: $e');
        _refereeProfileImages[referee.id] = null;
      }
    });

    await Future.wait(futures);
    notifyListeners();
  }

  // Get profile image URL for a referee
  String? getRefereeProfileImageUrl(String refereeId) {
    return _refereeProfileImages[refereeId];
  }

  // Check if invitation is being sent to a referee
  bool isRefereeInviteSending(String refereeId) {
    return _refereeInviteSending[refereeId] ?? false;
  }

  // Check if invitation was successfully sent to a referee
  bool isRefereeInviteSent(String refereeId) {
    return _refereeInviteSent[refereeId] ?? false;
  }

  // Send invitation to referee (triggered by icon tap)
  // Referee will receive notification on their dashboard
  // When referee accepts, league is assigned to them
  // No loading state - immediate response, background processing
  Future<bool> sendInvitationToReferee(String refereeId) async {
    debugPrint(
      '📧 [sendInvitationToReferee] Called with refereeId="$refereeId", _leagueId="$_leagueId"',
    );

    // Prevent duplicate invitations
    if (_refereeInviteSent[refereeId] == true) {
      debugPrint(
        '⚠️ [sendInvitationToReferee] Invitation already sent for referee: $refereeId',
      );
      return false;
    }

    // Check if leagueId is available
    String effectiveLeagueId = _leagueId;

    // If league doesn't exist yet, create it silently first (no loading state)
    if (effectiveLeagueId.isEmpty) {
      if (!isStep1Valid) {
        debugPrint('❌ Cannot send invitation: Step 1 validation failed');
        return false;
      }

      // Create league silently (no loading state, no UI blocking)
      try {
        effectiveLeagueId = await _createLeagueSilently();
        if (effectiveLeagueId.isEmpty) {
          debugPrint('❌ Failed to create league silently');
          return false;
        }
        _leagueId = effectiveLeagueId; // Store for future use
        debugPrint('✅ League created silently: $effectiveLeagueId');
      } catch (e) {
        debugPrint('❌ Error creating league silently: $e');
        return false;
      }
    }

    // Immediately update UI - change color instantly (optimistic update)
    _refereeInviteSent[refereeId] = true;
    notifyListeners();
    debugPrint('✅ [sendInvitationToReferee] UI updated - icon color changed');
    // Send invitation in background (fire-and-forget) - no loading state
    LeagueService.inviteRefereeToLeague(effectiveLeagueId, refereeId)
        .then((success) {
          if (success) {
            debugPrint(
              '✅ Referee invitation sent successfully. Notification will appear in referee dashboard.',
            );
            debugPrint(
              '✅ League ID: $effectiveLeagueId, Referee ID: $refereeId',
            );
            // Keep icon color changed (success)
          } else {
            debugPrint('❌ Referee invitation failed: success=false');
            // Revert UI state on failure - icon color goes back to original
            _refereeInviteSent[refereeId] = false;
            notifyListeners();
          }
        })
        .catchError((e) {
          debugPrint(
            '❌ [sendInvitationToReferee] Error sending invitation: $e',
          );
          debugPrint(
            '❌ [sendInvitationToReferee] Error type: ${e.runtimeType}',
          );
          debugPrint('❌ League ID: $effectiveLeagueId, Referee ID: $refereeId');
          if (e is Error) {
            debugPrint(
              '❌ [sendInvitationToReferee] Stack trace: ${e.stackTrace}',
            );
          }
          // Revert UI state on error - icon color goes back to original
          _refereeInviteSent[refereeId] = false;
          notifyListeners();
        });

    return true;
  }

  // Fetch stat keepers from API
  Future<void> fetchStatKeepers() async {
    if (_isLoadingStatKeepers || _hasAttemptedStatKeepersFetch) return;

    _isLoadingStatKeepers = true;
    _hasAttemptedStatKeepersFetch = true; // Mark that we've attempted to fetch
    notifyListeners();

    try {
      debugPrint('🔄 Fetching stat keepers...');
      _statKeepers = await UserService.getStatKeepers();
      debugPrint('✅ Fetched ${_statKeepers.length} stat keepers');

      // Fetch profile images for stat keepers
      await _fetchStatKeeperProfileImages();
    } catch (e) {
      debugPrint('❌ Error fetching stat keepers: $e');
      _statKeepers = [];
    } finally {
      _isLoadingStatKeepers = false;
      notifyListeners();
    }
  }

  // Retry fetching stat keepers (resets the attempt flag)
  void retryFetchStatKeepers() {
    _hasAttemptedStatKeepersFetch = false;
    fetchStatKeepers();
  }

  // Fetch profile images for stat keepers
  Future<void> _fetchStatKeeperProfileImages() async {
    _statKeeperProfileImages.clear();

    // Fetch profiles for all stat keepers in parallel
    final futures = _statKeepers.map((statKeeper) async {
      try {
        final profile = await ProfileService.getProfile(statKeeper.id);
        if (profile != null &&
            profile['image'] != null &&
            profile['image'].toString().isNotEmpty) {
          final img = profile['image'].toString();
          // Only use valid http URLs
          if (img.startsWith('http')) {
            _statKeeperProfileImages[statKeeper.id] = img;
            return;
          }
        }
        _statKeeperProfileImages[statKeeper.id] = null;
      } catch (e) {
        debugPrint(
          '⚠️ Error fetching profile for stat keeper ${statKeeper.id}: $e',
        );
        _statKeeperProfileImages[statKeeper.id] = null;
      }
    });

    await Future.wait(futures);
    notifyListeners();
  }

  // Get profile image URL for a stat keeper
  String? getStatKeeperProfileImageUrl(String statKeeperId) {
    return _statKeeperProfileImages[statKeeperId];
  }

  // Check if invitation is being sent to a stat keeper
  bool isStatKeeperInviteSending(String statKeeperId) {
    return _statKeeperInviteSending[statKeeperId] ?? false;
  }

  // Check if invitation was successfully sent to a stat keeper
  bool isStatKeeperInviteSent(String statKeeperId) {
    return _statKeeperInviteSent[statKeeperId] ?? false;
  }

  // Send invitation to stat keeper (triggered by icon tap)
  // Stat keeper will receive notification on their dashboard
  // When stat keeper accepts, league is assigned to them
  // No loading state - immediate response, background processing
  Future<bool> sendInvitationToStatKeeperIcon(String statKeeperId) async {
    debugPrint(
      '📧 [sendInvitationToStatKeeperIcon] Called with statKeeperId="$statKeeperId", _leagueId="$_leagueId"',
    );

    // Prevent duplicate invitations
    if (_statKeeperInviteSent[statKeeperId] == true) {
      debugPrint(
        '⚠️ [sendInvitationToStatKeeperIcon] Invitation already sent for stat keeper: $statKeeperId',
      );
      return false;
    }

    // Check if leagueId is available
    String effectiveLeagueId = _leagueId;

    // If league doesn't exist yet, create it silently first (no loading state)
    if (effectiveLeagueId.isEmpty) {
      if (!isStep1Valid) {
        debugPrint('❌ Cannot send invitation: Step 1 validation failed');
        return false;
      }

      // Create league silently (no loading state, no UI blocking)
      try {
        effectiveLeagueId = await _createLeagueSilently();
        if (effectiveLeagueId.isEmpty) {
          debugPrint('❌ Failed to create league silently');
          return false;
        }
        _leagueId = effectiveLeagueId; // Store for future use
        debugPrint('✅ League created silently: $effectiveLeagueId');
      } catch (e) {
        debugPrint('❌ Error creating league silently: $e');
        return false;
      }
    }

    // Immediately update UI - change color instantly (optimistic update)
    _statKeeperInviteSent[statKeeperId] = true;
    notifyListeners();
    debugPrint(
      '✅ [sendInvitationToStatKeeperIcon] UI updated - icon color changed',
    );

    // Send invitation in background (fire-and-forget) - no loading state
    debugPrint(
      '📤 [sendInvitationToStatKeeperIcon] Calling LeagueService.inviteStatKeeperToLeague...',
    );
    LeagueService.inviteStatKeeperToLeague(effectiveLeagueId, statKeeperId)
        .then((success) {
          debugPrint(
            '📥 [sendInvitationToStatKeeperIcon] Response received: success=$success',
          );
          if (success) {
            debugPrint(
              '✅ Stat keeper invitation sent successfully. Notification will appear in stat keeper dashboard.',
            );
            debugPrint(
              '✅ League ID: $effectiveLeagueId, Stat Keeper ID: $statKeeperId',
            );
            // Keep icon color changed (success)
          } else {
            debugPrint(
              '❌ [sendInvitationToStatKeeperIcon] Stat keeper invitation failed: success=false',
            );
            // Revert UI state on failure - icon color goes back to original
            _statKeeperInviteSent[statKeeperId] = false;
            notifyListeners();
          }
        })
        .catchError((e) {
          debugPrint(
            '❌ [sendInvitationToStatKeeperIcon] Error sending invitation: $e',
          );
          debugPrint(
            '❌ [sendInvitationToStatKeeperIcon] Error type: ${e.runtimeType}',
          );
          debugPrint(
            '❌ League ID: $effectiveLeagueId, Stat Keeper ID: $statKeeperId',
          );
          if (e is Error) {
            debugPrint(
              '❌ [sendInvitationToStatKeeperIcon] Stack trace: ${e.stackTrace}',
            );
          }
          // Revert UI state on error - icon color goes back to original
          _statKeeperInviteSent[statKeeperId] = false;
          notifyListeners();
        });

    return true;
  }

  // Legacy method - kept for backward compatibility with createLeague flow
  bool isStatKeeperEmailSending(String statKeeperId) {
    return _statKeeperEmailStatus[statKeeperId] ?? false;
  }

  // Legacy: Send invitation to stat keeper (called during league creation)
  Future<bool> sendInvitationToStatKeeper(
    String leagueId,
    String statKeeperId,
  ) async {
    _statKeeperEmailStatus[statKeeperId] = true;
    notifyListeners();

    try {
      final success = await LeagueService.inviteStatKeeperToLeague(
        leagueId,
        statKeeperId,
      );
      if (success) {
        _statKeeperEmailStatus[statKeeperId] = false;
        notifyListeners();
        return true;
      } else {
        _statKeeperEmailStatus[statKeeperId] = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error sending invitation to stat keeper: $e');
      _statKeeperEmailStatus[statKeeperId] = false;
      notifyListeners();
      return false;
    }
  }

  // Method to send email to a stat keeper (kept for backward compatibility)
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
    final fee = double.tryParse(text) ?? 0.0;
    _perPlayerFee = fee;
    // Clear error if fee is valid
    if (fee > 0) {
      _perPlayerFeeError = null;
    }
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

  void setFreeAgentSearchQuery(String query) {
    _freeAgentSearchQuery = query.toLowerCase();
    notifyListeners();
  }

  // Fetch free agents from API
  Future<void> fetchFreeAgents() async {
    if (_isLoadingFreeAgents) return;

    _isLoadingFreeAgents = true;
    notifyListeners();

    try {
      debugPrint('🔄 Fetching free agents...');
      _freeAgents = await UserService.getFreeAgents();
      debugPrint('✅ Fetched ${_freeAgents.length} free agents');
      if (_freeAgents.isEmpty) {
        debugPrint('⚠️ No free agents found in database');
      }
    } catch (e) {
      debugPrint('❌ Error fetching free agents: $e');
      _freeAgents = [];
    } finally {
      _isLoadingFreeAgents = false;
      notifyListeners();
    }
  }

  // Toggle free agent selection
  void toggleFreeAgentSelection(String freeAgentId) {
    if (_selectedFreeAgentIds.contains(freeAgentId)) {
      _selectedFreeAgentIds.remove(freeAgentId);
    } else {
      _selectedFreeAgentIds.add(freeAgentId);
    }
    notifyListeners();
  }

  // Check if email is being sent to a free agent
  bool isFreeAgentEmailSending(String freeAgentId) {
    return _freeAgentEmailStatus[freeAgentId] ?? false;
  }

  // Send invitation to free agent
  Future<bool> sendInvitationToFreeAgent(
    String leagueId,
    String freeAgentId,
  ) async {
    _freeAgentEmailStatus[freeAgentId] = true;
    notifyListeners();

    try {
      final success = await LeagueService.inviteFreeAgentToLeague(
        leagueId,
        freeAgentId,
      );
      if (success) {
        _freeAgentEmailStatus[freeAgentId] = false;
        notifyListeners();
        return true;
      } else {
        _freeAgentEmailStatus[freeAgentId] = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error sending invitation to free agent: $e');
      _freeAgentEmailStatus[freeAgentId] = false;
      notifyListeners();
      return false;
    }
  }

  bool isTeamExpanded(String teamId) {
    return _teamExpansionState[teamId] ?? false;
  }

  void toggleTeamExpansion(String teamId) {
    _teamExpansionState[teamId] = !(_teamExpansionState[teamId] ?? false);
    notifyListeners();
  }

  // Fetch teams from API
  Future<void> fetchTeams() async {
    if (_isLoadingTeams) return;

    _isLoadingTeams = true;
    notifyListeners();

    try {
      debugPrint('🔄 Fetching teams from API...');
      _teams = await LeagueService.getAllTeams();
      debugPrint('✅ Teams fetched successfully: ${_teams.length} teams');
      if (_teams.isEmpty) {
        debugPrint('⚠️ No teams found in database');
      } else {
        debugPrint(
          '📋 Team names: ${_teams.map((t) => t.teamName).join(", ")}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching teams: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      if (e is Error) {
        debugPrint('❌ Error stack: ${e.stackTrace}');
      }
      _teams = [];
    } finally {
      _isLoadingTeams = false;
      notifyListeners();
    }
  }

  // Toggle team selection
  void toggleTeamSelection(String teamId) {
    if (_selectedTeamIds.contains(teamId)) {
      _selectedTeamIds.remove(teamId);
    } else {
      _selectedTeamIds.add(teamId);
    }
    notifyListeners();
  }

  // Check if email is being sent to a team
  bool isTeamEmailSending(String teamId) {
    return _teamEmailStatus[teamId] ?? false;
  }

  // Check if email was successfully sent to a team
  bool isTeamEmailSent(String teamId) {
    return _teamEmailSent[teamId] ?? false;
  }

  // Send invitation to team
  // Teams are automatically assigned to the league when invited (Step 4 of league creation)
  // No loading state - immediate response, background processing
  Future<bool> sendInvitationToTeam(String leagueId, String teamId) async {
    debugPrint(
      '📧 [sendInvitationToTeam] Called with leagueId="$leagueId", teamId="$teamId"',
    );

    // Prevent duplicate invitations
    if (_teamEmailSent[teamId] == true) {
      debugPrint(
        '⚠️ [sendInvitationToTeam] Invitation already sent for team: $teamId',
      );
      return false;
    }

    // Check if leagueId is available
    String effectiveLeagueId = leagueId;
    if (effectiveLeagueId.isEmpty) {
      effectiveLeagueId = _leagueId;
    }

    // If league doesn't exist yet, create it silently first (no loading state)
    if (effectiveLeagueId.isEmpty) {
      if (!isStep1Valid) {
        debugPrint('❌ Cannot send invitation: Step 1 validation failed');
        return false;
      }

      // Create league silently (no loading state, no UI blocking)
      try {
        effectiveLeagueId = await _createLeagueSilently();
        if (effectiveLeagueId.isEmpty) {
          debugPrint('❌ Failed to create league silently');
          return false;
        }
        _leagueId = effectiveLeagueId; // Store for future use
        debugPrint('✅ League created silently: $effectiveLeagueId');
      } catch (e) {
        debugPrint('❌ Error creating league silently: $e');
        return false;
      }
    }

    // Immediately update UI - change color instantly (optimistic update)
    _teamEmailSent[teamId] = true;
    notifyListeners();
    debugPrint('✅ [sendInvitationToTeam] UI updated - icon color changed');
    // Send invitation in background (fire-and-forget) - no loading state
    LeagueService.inviteTeamToLeague(effectiveLeagueId, teamId)
        .then((success) {
          if (success) {
            debugPrint(
              '✅ Team invitation sent successfully. Team will be assigned when captain accepts.',
            );
            debugPrint('✅ League ID: $effectiveLeagueId, Team ID: $teamId');
            // Keep icon color changed (success)
          } else {
            debugPrint('❌ Team invitation failed: success=false');
            // Revert UI state on failure - icon color goes back to original
            _teamEmailSent[teamId] = false;
            notifyListeners();
          }
        })
        .catchError((e) {
          debugPrint('❌ Error sending invitation to team: $e');
          debugPrint('❌ Error type: ${e.runtimeType}');
          debugPrint('❌ League ID: $effectiveLeagueId, Team ID: $teamId');
          // Revert UI state on error - icon color goes back to original
          _teamEmailSent[teamId] = false;
          notifyListeners();
        });
    debugPrint(
      '📤 [sendInvitationToTeam] Calling LeagueService.inviteTeamToLeague...',
    );
    LeagueService.inviteTeamToLeague(leagueId, teamId)
        .then((success) {
          debugPrint(
            '📥 [sendInvitationToTeam] Response received: success=$success',
          );
          if (success) {
            debugPrint(
              '✅ [sendInvitationToTeam] Team invitation sent successfully. Team will be assigned when captain accepts.',
            );
          } else {
            debugPrint(
              '❌ [sendInvitationToTeam] Team invitation failed: success=false',
            );
          }
        })
        .catchError((e) {
          debugPrint('❌ [sendInvitationToTeam] Error sending invitation: $e');
          debugPrint('❌ [sendInvitationToTeam] Error type: ${e.runtimeType}');
          if (e is Error) {
            debugPrint('❌ [sendInvitationToTeam] Stack trace: ${e.stackTrace}');
          }
          // Revert UI state on error - icon color goes back to original
          _teamEmailSent[teamId] = false;
          notifyListeners();
        });

    return true;
  }

  // Create league silently (no loading state, no UI blocking)
  // Returns leagueId if successful, empty string if failed
  Future<String> _createLeagueSilently() async {
    try {
      // Upload logo if provided (OPTIONAL)
      String? logoUrl;
      if (_uploadedLogoPath.isNotEmpty) {
        try {
          final logoFile = File(_uploadedLogoPath);
          if (await logoFile.exists()) {
            logoUrl = await LeagueService.uploadLogo(logoFile);
            debugPrint('✅ Logo uploaded successfully: $logoUrl');
          }
        } catch (e) {
          debugPrint('⚠️ Logo upload failed during silent league creation: $e');
          // Continue without logo - it's optional
          logoUrl = null;
        }
      } else if (_selectedLogoId.isNotEmpty) {
        final selectedLogo = teamLogos.firstWhere(
          (logo) => logo.id == _selectedLogoId,
          orElse: () => teamLogos.first,
        );
        logoUrl = selectedLogo.url;
        debugPrint('✅ Using selected logo: $logoUrl');
      }

      // Create league data - logo is optional
      final leagueData = <String, dynamic>{
        'leagueName': _leagueName,
        'format': formatString,
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
        'minimumPlayers': _minPlayers,
        'entryFeeType': 'stripe',
        'perPlayerLeagueFee': _perPlayerFee,
        'status': 'pending',
      };

      // Only include logo if we have one
      if (logoUrl != null && logoUrl.isNotEmpty) {
        leagueData['logo'] = logoUrl;
        debugPrint('✅ Including logo in league data: $logoUrl');
      } else {
        debugPrint('ℹ️ Creating league without logo (optional)');
      }

      final leagueResponse = await LeagueService.createLeague(leagueData);

      if (leagueResponse != null && leagueResponse.data.id.isNotEmpty) {
        debugPrint('✅ League created successfully: ${leagueResponse.data.id}');
        return leagueResponse.data.id;
      } else {
        debugPrint('❌ Failed to create league silently: empty response');
        return '';
      }
    } catch (e) {
      debugPrint('❌ Error creating league silently: $e');
      return '';
    }
  }

  void setTeamSearchQuery(String query) {
    _teamSearchQuery = query.toLowerCase();
    notifyListeners();
  }

  void setRegistrationFee(double fee) {
    _registrationFee = fee;
    notifyListeners();
  }

  Future<void> nextStep() async {
    if (_currentStep < 3) {
      // Step 4 is at index 3 (0-indexed: 0,1,2,3)
      // If moving from Step 1 to Step 2, create league first (so leagueId is available for invites)
      if (_currentStep == 0 && _leagueId.isEmpty) {
        debugPrint(
          '📋 [nextStep] Moving from Step 1 to Step 2 - Creating league first...',
        );
        // Create league automatically before moving to step 2
        final leagueCreated = await _createLeagueSilently();
        if (leagueCreated.isEmpty) {
          debugPrint(
            '❌ [nextStep] League creation failed - cannot proceed to Step 2',
          );
          return; // Don't move to next step if league creation failed
        }
        _leagueId = leagueCreated;
        debugPrint(
          '✅ [nextStep] League created successfully, leagueId: $_leagueId',
        );
      }

      _currentStep++;

      // When reaching Step 2 (Referee Invitation), create league and fetch referees
      if (_currentStep == 1) {
        // Create league silently if not already created (needed for referee invites)
        // This happens in background - no loading state
        if (_leagueId.isEmpty && isStep1Valid) {
          _createLeagueSilently()
              .then((leagueId) {
                if (leagueId.isNotEmpty) {
                  _leagueId = leagueId;
                  debugPrint('✅ League created when Step 2 reached: $leagueId');
                  notifyListeners();
                }
              })
              .catchError((e) {
                debugPrint('⚠️ League creation failed when Step 2 reached: $e');
                // Don't block - will be created when email icon is clicked
              });
        }
        // Fetch referees for invitation
        if (_referees.isEmpty && !_isLoadingReferees) {
          fetchReferees();
        }
      }

      // When reaching Step 3 (Stat Keeper Invitation), create league and fetch stat keepers
      if (_currentStep == 2) {
        // Create league silently if not already created (needed for stat keeper invites)
        // This happens in background - no loading state
        if (_leagueId.isEmpty && isStep1Valid) {
          _createLeagueSilently()
              .then((leagueId) {
                if (leagueId.isNotEmpty) {
                  _leagueId = leagueId;
                  debugPrint('✅ League created when Step 3 reached: $leagueId');
                  notifyListeners();
                }
              })
              .catchError((e) {
                debugPrint('⚠️ League creation failed when Step 3 reached: $e');
                // Don't block - will be created when email icon is clicked
              });
        }
        // Fetch stat keepers for invitation
        if (_statKeepers.isEmpty && !_isLoadingStatKeepers) {
          fetchStatKeepers();
        }
      }

      // When reaching Step 4, create league first (if not already created) and fetch teams
      if (_currentStep == 3) {
        // Create league silently if not already created (needed for team invites)
        // This happens in background - no loading state
        if (_leagueId.isEmpty && isStep1Valid) {
          _createLeagueSilently()
              .then((leagueId) {
                if (leagueId.isNotEmpty) {
                  _leagueId = leagueId;
                  debugPrint('✅ League created when Step 4 reached: $leagueId');
                  notifyListeners();
                }
              })
              .catchError((e) {
                debugPrint('⚠️ League creation failed when Step 4 reached: $e');
                // Don't block - will be created when email icon is clicked
              });
        }
        // Fetch teams when reaching step 4
        if (_teams.isEmpty && !_isLoadingTeams) {
          fetchTeams();
        }
      }
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
    // League is already created when moving from Step 1 to Step 2
    // This function now just finalizes and shows success message
    if (_currentStep != 3) {
      debugPrint(
        '❌ Cannot finalize league: User must complete Step 4 first (current step: $_currentStep)',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please complete Step 4 before finalizing the league',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Check if league was already created
    if (_leagueId.isEmpty) {
      debugPrint(
        '❌ Cannot finalize league: League ID is missing. Creating league now...',
      );
      final leagueIdResult = await _createLeagueSilently();
      if (leagueIdResult.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create league. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
        _isLoading = false;
        notifyListeners();
        return;
      }
      _leagueId = leagueIdResult;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // League is already created when moving from Step 1 to Step 2
      final leagueId = _leagueId;
      debugPrint(
        '✅ [createLeague] Using existing league ID: $leagueId (Step 4 completed)',
      );

      // Invitations are sent via email icons in steps 2, 3, 4
      // No need to send bulk invitations here - they're sent individually when icons are pressed
      debugPrint(
        '✅ [createLeague] All invitations should have been sent via email icons in steps 2, 3, 4',
      );

      // Step 6: Refresh leagues list
      if (context.mounted) {
        try {
          final leaguesProvider = Provider.of<EnhancedLeaguesProvider>(
            context,
            listen: false,
          );
          await leaguesProvider.refreshLeagues();
        } catch (e) {
          debugPrint('Error refreshing leagues list: $e');
          // Continue even if refresh fails
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('League created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating league: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _currentStep = 0;
    _leagueName = '';
    _selectedLogoId = '1';
    _selectedPlayerIds = [];
    _selectedRefereeIds = []; // Reset referees as well
    _selectedStatKeeperIds = []; // Reset stat keepers as well
    _selectedFreeAgentIds = []; // Reset free agents as well
    _captainId = '';
    _registrationFee = 50.0;
    _isLoading = false;
    _emailSendingStatus.clear(); // Clear email sending status
    _statKeeperEmailStatus.clear(); // Clear stat keeper email status
    _freeAgentEmailStatus.clear(); // Clear free agent email status
    _refereeInviteSending.clear(); // Clear referee invite sending status
    _refereeInviteSent.clear(); // Clear referee invite sent status
    _statKeeperInviteSending.clear(); // Clear stat keeper invite sending status
    _statKeeperInviteSent.clear(); // Clear stat keeper invite sent status
    _leagueNameText = '';
    _perPlayerFeeText = '';
    _referees = [];
    _refereeSearchQuery = '';
    _hasAttemptedRefereesFetch = false; // Reset referee fetch attempt flag
    _refereeProfileImages.clear(); // Clear referee profile images
    _freeAgents = [];
    _freeAgentSearchQuery = '';
    _statKeepers = [];
    _statKeeperSearchQuery = '';
    _hasAttemptedStatKeepersFetch =
        false; // Reset stat keeper fetch attempt flag
    _statKeeperProfileImages.clear(); // Clear stat keeper profile images
    _teams = [];
    _selectedTeamIds = [];
    _teamSearchQuery = '';
    _teamEmailStatus.clear();
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
