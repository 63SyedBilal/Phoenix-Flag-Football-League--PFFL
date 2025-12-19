import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/utils/validators.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/core/services/user_service.dart';
import 'package:pffl_managment/core/services/league_service.dart';
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
  // Map to track email sending status for free agents
  final Map<String, bool> _freeAgentEmailStatus = {};
  
  // Referees list from API
  List<UserModel> _referees = [];
  bool _isLoadingReferees = false;
  
  // Free agents list from API
  List<UserModel> _freeAgents = [];
  bool _isLoadingFreeAgents = false;
  
  // Stat keepers list from API
  List<UserModel> _statKeepers = [];
  bool _isLoadingStatKeepers = false;
  
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
  final Map<String, bool> _teamEmailStatus = {}; // Tracks if email is currently being sent
  final Map<String, bool> _teamEmailSent = {}; // Tracks if email was successfully sent
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
  double _perPlayerFee = 250.0;
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
      return name.contains(_refereeSearchQuery) || email.contains(_refereeSearchQuery);
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
      return name.contains(_statKeeperSearchQuery) || email.contains(_statKeeperSearchQuery);
    }).toList();
  }
  
  String get freeAgentSearchQuery => _freeAgentSearchQuery;
  List<UserModel> get statKeepers => _statKeepers;
  bool get isLoadingStatKeepers => _isLoadingStatKeepers;
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
      (_entryFeeType != EntryFeeType.perPlayer || 
       (_perPlayerFee > 0 && _perPlayerFeeError == null)) &&
      (_selectedLogoId.isNotEmpty || _uploadedLogoPath.isNotEmpty) &&
      _startDate != null &&
      _endDate != null &&
      _startDate!.isBefore(_endDate!) &&
      _dateRangeError == null &&
      _minPlayers > 0 &&
      _minPlayersError == null;
  bool get isStep2Valid => true; // No selection required - invitations sent via icon only
  bool get isStep3Valid => true; // No selection required - invitations sent via icon only
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

  // Fetch referees from API
  Future<void> fetchReferees() async {
    if (_isLoadingReferees) return;
    
    _isLoadingReferees = true;
    notifyListeners();

    try {
      debugPrint('🔄 Fetching referees...');
      _referees = await UserService.getReferees();
      debugPrint('✅ Fetched ${_referees.length} referees');
    } catch (e) {
      debugPrint('❌ Error fetching referees: $e');
      _referees = [];
    } finally {
      _isLoadingReferees = false;
      notifyListeners();
    }
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
  Future<bool> sendInvitationToReferee(String refereeId) async {
    // Need leagueId to send invitation
    if (_leagueId.isEmpty) {
      debugPrint('⚠️ Cannot send referee invitation: League not created yet');
      return false;
    }

    _refereeInviteSending[refereeId] = true;
    notifyListeners();

    try {
      debugPrint('📤 Sending invitation to referee: $refereeId for league: $_leagueId');
      final success = await LeagueService.inviteRefereeToLeague(_leagueId, refereeId);
      
      _refereeInviteSending[refereeId] = false;
      
      if (success) {
        _refereeInviteSent[refereeId] = true;
        debugPrint('✅ Referee invitation sent successfully');
        notifyListeners();
        return true;
      } else {
        debugPrint('❌ Referee invitation failed');
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending invitation to referee: $e');
      _refereeInviteSending[refereeId] = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch stat keepers from API
  Future<void> fetchStatKeepers() async {
    if (_isLoadingStatKeepers) return;
    
    _isLoadingStatKeepers = true;
    notifyListeners();

    try {
      _statKeepers = await UserService.getStatKeepers();
    } catch (e) {
      debugPrint('Error fetching stat keepers: $e');
      _statKeepers = [];
    } finally {
      _isLoadingStatKeepers = false;
      notifyListeners();
    }
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
  Future<bool> sendInvitationToStatKeeperIcon(String statKeeperId) async {
    // Need leagueId to send invitation
    if (_leagueId.isEmpty) {
      debugPrint('⚠️ Cannot send stat keeper invitation: League not created yet');
      return false;
    }

    _statKeeperInviteSending[statKeeperId] = true;
    notifyListeners();

    try {
      debugPrint('📤 Sending invitation to stat keeper: $statKeeperId for league: $_leagueId');
      final success = await LeagueService.inviteStatKeeperToLeague(_leagueId, statKeeperId);
      
      _statKeeperInviteSending[statKeeperId] = false;
      
      if (success) {
        _statKeeperInviteSent[statKeeperId] = true;
        debugPrint('✅ Stat keeper invitation sent successfully');
        notifyListeners();
        return true;
      } else {
        debugPrint('❌ Stat keeper invitation failed');
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending invitation to stat keeper: $e');
      _statKeeperInviteSending[statKeeperId] = false;
      notifyListeners();
      return false;
    }
  }

  // Legacy method - kept for backward compatibility with createLeague flow
  bool isStatKeeperEmailSending(String statKeeperId) {
    return _statKeeperEmailStatus[statKeeperId] ?? false;
  }

  // Legacy: Send invitation to stat keeper (called during league creation)
  Future<bool> sendInvitationToStatKeeper(String leagueId, String statKeeperId) async {
    _statKeeperEmailStatus[statKeeperId] = true;
    notifyListeners();

    try {
      final success = await LeagueService.inviteStatKeeperToLeague(leagueId, statKeeperId);
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
  Future<bool> sendInvitationToFreeAgent(String leagueId, String freeAgentId) async {
    _freeAgentEmailStatus[freeAgentId] = true;
    notifyListeners();

    try {
      final success = await LeagueService.inviteFreeAgentToLeague(leagueId, freeAgentId);
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
        debugPrint('📋 Team names: ${_teams.map((t) => t.teamName).join(", ")}');
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
  Future<bool> sendInvitationToTeam(String leagueId, String teamId) async {
    _teamEmailStatus[teamId] = true;
    notifyListeners();

    try {
      debugPrint('📤 Sending invitation to team: leagueId=$leagueId, teamId=$teamId');
      final success = await LeagueService.inviteTeamToLeague(leagueId, teamId);
      _teamEmailStatus[teamId] = false;
      if (success) {
        _teamEmailSent[teamId] = true;
        debugPrint('✅ Team invitation sent successfully. Team automatically assigned to league.');
        notifyListeners();
        return true;
      } else {
        debugPrint('❌ Team invitation failed: success=false');
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending invitation to team: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      _teamEmailStatus[teamId] = false;
      notifyListeners();
      return false;
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

  void nextStep() {
    if (_currentStep < 3) {  // Step 4 is at index 3 (0-indexed: 0,1,2,3)
      _currentStep++;
      
      // When reaching Step 2 (Referee Invitation), fetch referees and create league
      if (_currentStep == 1) {
        // Create league if not already created (allows invitation icon to work immediately)
        if (_leagueId.isEmpty && !_isLoading) {
          _createLeagueInBackground();
        }
        // Fetch referees for invitation
        if (_referees.isEmpty && !_isLoadingReferees) {
          fetchReferees();
        }
      }
      
      // When reaching Step 3 (Stat Keeper Invitation), fetch stat keepers
      if (_currentStep == 2) {
        // Create league if not already created (allows invitation icon to work immediately)
        if (_leagueId.isEmpty && !_isLoading) {
          _createLeagueInBackground();
        }
        // Fetch stat keepers for invitation
        if (_statKeepers.isEmpty && !_isLoadingStatKeepers) {
          fetchStatKeepers();
        }
      }
      
      // When reaching Step 4, create league in background so email icon works immediately
      if (_currentStep == 3) {
        // Create league if not already created (allows email icon to work immediately)
        if (_leagueId.isEmpty && !_isLoading) {
          _createLeagueInBackground();
        }
        // Fetch teams when reaching step 4
        if (_teams.isEmpty && !_isLoadingTeams) {
          fetchTeams();
        }
      }
      notifyListeners();
    }
  }

  /// Create league in background so invitation icons can work immediately
  /// This is called when entering Step 2 (Referee) or Step 4 (Teams)
  Future<void> _createLeagueInBackground() async {
    if (_leagueId.isNotEmpty) {
      // League already created
      return;
    }

    // Validate required fields
    if (_leagueName.isEmpty || _startDate == null || _endDate == null) {
      debugPrint('⚠️ Cannot create league: Missing required fields');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Upload logo if provided
      String? logoUrl;
      if (_uploadedLogoPath.isNotEmpty) {
        try {
          final logoFile = File(_uploadedLogoPath);
          if (await logoFile.exists()) {
            logoUrl = await LeagueService.uploadLogo(logoFile);
          }
        } catch (e) {
          debugPrint('⚠️ Logo upload failed: $e');
          // Continue without logo
        }
      } else if (_selectedLogoId.isNotEmpty) {
        final selectedLogo = teamLogos.firstWhere(
          (logo) => logo.id == _selectedLogoId,
          orElse: () => teamLogos.first,
        );
        logoUrl = selectedLogo.url;
      }

      // Create league
      final leagueData = {
        'leagueName': _leagueName,
        'format': formatString,
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
        'minimumPlayers': _minPlayers,
        'entryFeeType': 'stripe',
        'perPlayerLeagueFee': _perPlayerFee,
        'logo': logoUrl ?? '',
        'status': 'pending',
      };

      final leagueResponse = await LeagueService.createLeague(leagueData);
      
      if (leagueResponse != null && leagueResponse.data.id.isNotEmpty) {
        _leagueId = leagueResponse.data.id;
        debugPrint('✅ League created in background. ID: $_leagueId');
        debugPrint('✅ Invitation icons are now enabled');
      } else {
        debugPrint('❌ Failed to create league in background');
      }
    } catch (e) {
      debugPrint('❌ Error creating league: $e');
    } finally {
      _isLoading = false;
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

    try {
      // Step 1: Upload logo if provided (REQUIRED)
      String? logoUrl;
      if (_uploadedLogoPath.isNotEmpty) {
        try {
          final logoFile = File(_uploadedLogoPath);
          if (!await logoFile.exists()) {
            throw Exception('Logo file does not exist. Please select a valid image file.');
          }
          
          logoUrl = await LeagueService.uploadLogo(logoFile);
          if (logoUrl == null || logoUrl.isEmpty) {
            throw Exception('Logo upload failed: Server returned empty URL');
          }
        } catch (e) {
          // Logo is required, so stop league creation
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Logo upload failed: ${e.toString()}'),
                duration: Duration(seconds: 5),
                backgroundColor: Colors.red,
              ),
            );
          }
          _isLoading = false;
          notifyListeners();
          return; // Stop league creation
        }
      } else if (_selectedLogoId.isNotEmpty) {
        // Use selected logo URL from team logos
        final selectedLogo = teamLogos.firstWhere(
          (logo) => logo.id == _selectedLogoId,
          orElse: () => teamLogos.first,
        );
        logoUrl = selectedLogo.url;
      } else {
        // No logo selected or uploaded - show error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please upload a logo or select a default logo'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Step 2: Create league via API (only if not already created in Step 4)
      // If league was already created when entering Step 4, use existing leagueId
      String leagueId = _leagueId;
      
      if (leagueId.isEmpty) {
        // League not created yet, create it now
        final leagueData = {
          'leagueName': _leagueName,
          'format': formatString, // "5v5" or "7v7"
          'startDate': _startDate!.toIso8601String(),
          'endDate': _endDate!.toIso8601String(),
          'minimumPlayers': _minPlayers,
          'entryFeeType': 'stripe', // Backend expects this
          'perPlayerLeagueFee': _perPlayerFee,
          'logo': logoUrl, // logoUrl is guaranteed to be set at this point
          'status': 'pending',
        };

        final leagueResponse = await LeagueService.createLeague(leagueData);
        
        if (leagueResponse == null || leagueResponse.data.id.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to create league')),
            );
          }
          _isLoading = false;
          notifyListeners();
          return;
        }

        leagueId = leagueResponse.data.id;
        _leagueId = leagueId; // Store leagueId
        debugPrint('✅ League created successfully with ID: $leagueId');
      } else {
        debugPrint('✅ League already created with ID: $leagueId. Using existing league.');
      }

      // Step 3: Send invitations to free agents
      for (final freeAgentId in _selectedFreeAgentIds) {
        await sendInvitationToFreeAgent(leagueId, freeAgentId);
      }

      // Step 4: Send invitations to stat keepers
      for (final statKeeperId in _selectedStatKeeperIds) {
        await sendInvitationToStatKeeper(leagueId, statKeeperId);
      }

      // Step 5: Send invitations to teams
      for (final teamId in _selectedTeamIds) {
        await sendInvitationToTeam(leagueId, teamId);
      }

      // Step 6: Refresh leagues list
      if (context.mounted) {
        try {
          final leaguesProvider = Provider.of<EnhancedLeaguesProvider>(context, listen: false);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
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
    _perPlayerFeeText = '250';
    _referees = [];
    _refereeSearchQuery = '';
    _freeAgents = [];
    _freeAgentSearchQuery = '';
    _statKeepers = [];
    _statKeeperSearchQuery = '';
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
