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
  
  // Free agents list from API
  List<UserModel> _freeAgents = [];
  bool _isLoadingFreeAgents = false;
  
  // Stat keepers list from API
  List<UserModel> _statKeepers = [];
  bool _isLoadingStatKeepers = false;
  
  // Teams list from API
  List<TeamModel> _teams = [];
  bool _isLoadingTeams = false;
  List<String> _selectedTeamIds = [];
  final Map<String, bool> _teamEmailStatus = {};
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
  List<String> get selectedPlayerIds => _selectedPlayerIds;
  List<String> get selectedRefereeIds => _selectedRefereeIds; // New getter
  List<String> get selectedStatKeeperIds =>
      _selectedStatKeeperIds; // New getter
  List<String> get selectedFreeAgentIds => _selectedFreeAgentIds; // New getter
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
  String get statKeeperSearchQuery => _statKeeperSearchQuery;
  String get freeAgentSearchQuery => _freeAgentSearchQuery;
  List<UserModel> get statKeepers => _statKeepers;
  bool get isLoadingStatKeepers => _isLoadingStatKeepers;
  List<TeamModel> get teams => _teams;
  bool get isLoadingTeams => _isLoadingTeams;
  List<String> get selectedTeamIds => _selectedTeamIds;
  String get teamSearchQuery => _teamSearchQuery;

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
  bool get isStep2Valid =>
      _selectedFreeAgentIds.isNotEmpty; // At least one free agent must be selected
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

  // Check if email is being sent to a stat keeper
  bool isStatKeeperEmailSending(String statKeeperId) {
    return _statKeeperEmailStatus[statKeeperId] ?? false;
  }

  // Send invitation to stat keeper
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
      _freeAgents = await UserService.getFreeAgents();
    } catch (e) {
      debugPrint('Error fetching free agents: $e');
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
      _teams = await LeagueService.getAllTeams();
    } catch (e) {
      debugPrint('Error fetching teams: $e');
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

  // Send invitation to team
  Future<bool> sendInvitationToTeam(String leagueId, String teamId) async {
    _teamEmailStatus[teamId] = true;
    notifyListeners();

    try {
      final success = await LeagueService.inviteTeamToLeague(leagueId, teamId);
      if (success) {
        _teamEmailStatus[teamId] = false;
        notifyListeners();
        return true;
      } else {
        _teamEmailStatus[teamId] = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error sending invitation to team: $e');
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

      // Step 2: Create league via API
      // logoUrl is guaranteed to be non-null at this point
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

      final leagueId = leagueResponse.data.id;
      debugPrint('League created successfully with ID: $leagueId');

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
    _leagueNameText = '';
    _perPlayerFeeText = '250';
    _freeAgents = [];
    _freeAgentSearchQuery = '';
    _statKeepers = [];
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
