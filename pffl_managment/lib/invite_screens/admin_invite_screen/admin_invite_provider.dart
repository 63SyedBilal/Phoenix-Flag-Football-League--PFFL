import 'package:flutter/foundation.dart';
import 'package:pffl_managment/core/services/user_service.dart' as user_service;

/// Free Agent model for the invite screen
class FreeAgentModel {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;

  FreeAgentModel({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
  });
}

/// Provider for Admin Invite Screen
class AdminInviteProvider extends ChangeNotifier {
  // State variables
  List<FreeAgentModel> _freeAgents = [];
  bool _isLoading = false;
  bool _isSendingInvite = false; // Separate loading state for sending invites
  String? _errorMessage;
  String _manualEmail = '';
  String? _manualSelectedRole;
  Map<String, String?> _agentSelectedRoles = {}; // agentId -> selectedRole
  Map<String, bool> _agentExpanded = {}; // agentId -> isExpanded
  Map<String, bool> _agentInviteSending = {}; // agentId -> isSendingInvite

  // Available roles
  static const List<String> availableRoles = [
    'Player',
    'Captain',
    'Referee',
    'Stat Keeper',
  ];

  // Getters
  List<FreeAgentModel> get freeAgents => _freeAgents;
  bool get isLoading => _isLoading;
  bool get isSendingInvite => _isSendingInvite;
  String? get errorMessage => _errorMessage;
  String get manualEmail => _manualEmail;
  String? get manualSelectedRole => _manualSelectedRole;
  List<String> get roles => availableRoles;
  
  String? getAgentSelectedRole(String agentId) => _agentSelectedRoles[agentId];
  bool isAgentExpanded(String agentId) => _agentExpanded[agentId] ?? false;
  bool isAgentInviteSending(String agentId) => _agentInviteSending[agentId] ?? false;

  /// Initialize and fetch free agents
  Future<void> initialize() async {
    if (_isLoading) return;
    await fetchFreeAgents();
  }

  /// Fetch all free agents from backend
  Future<void> fetchFreeAgents() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('🔄 Fetching free agents...');
      final backendUsers = await user_service.UserService.getFreeAgents();
      
      _freeAgents = backendUsers.map((user) {
        final name = user.fullName;
        final imageUrl = 'https://api.dicebear.com/7.x/avataaars/png?seed=${Uri.encodeComponent(name)}&backgroundColor=b6e3f4';
        
        return FreeAgentModel(
          id: user.id,
          name: name,
          email: user.email,
          imageUrl: imageUrl,
        );
      }).toList();

      debugPrint('✅ Fetched ${_freeAgents.length} free agents');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error fetching free agents: $e');
      _errorMessage = 'Failed to load free agents';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update manual email input
  void updateManualEmail(String email) {
    _manualEmail = email;
    notifyListeners();
  }

  /// Update manual role selection
  void updateManualRole(String? role) {
    _manualSelectedRole = role;
    notifyListeners();
  }

  /// Update agent role selection
  void updateAgentRole(String agentId, String? role) {
    _agentSelectedRoles[agentId] = role;
    notifyListeners();
  }

  /// Toggle agent card expansion
  void toggleAgentExpansion(String agentId) {
    _agentExpanded[agentId] = !(_agentExpanded[agentId] ?? false);
    notifyListeners();
  }

  /// Send invitation by manual email
  Future<bool> sendManualInvite() async {
    if (_manualEmail.isEmpty || _manualSelectedRole == null) {
      _errorMessage = 'Please enter email and select a role';
      notifyListeners();
      return false;
    }

    // Validate email format
    if (!_isValidEmail(_manualEmail)) {
      _errorMessage = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }

    try {
      _isSendingInvite = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('📧 Sending invite to: $_manualEmail with role: $_manualSelectedRole');
      
      // Map role to backend format
      final backendRole = _mapRoleToBackend(_manualSelectedRole!);
      final success = await user_service.InviteService.sendInvite(_manualEmail.trim(), backendRole);

      if (success) {
        debugPrint('✅ Invite sent successfully (new user created or role invitation sent)');
        // Clear form
        _manualEmail = '';
        _manualSelectedRole = null;
        _isSendingInvite = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to send invitation';
        _isSendingInvite = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending invite: $e');
      _errorMessage = 'Failed to send invitation: ${e.toString()}';
      _isSendingInvite = false;
      notifyListeners();
      return false;
    }
  }

  /// Send invitation to agent from list
  Future<bool> sendAgentInvite(String agentId) async {
    final selectedRole = _agentSelectedRoles[agentId];
    if (selectedRole == null) {
      _errorMessage = 'Please select a role';
      notifyListeners();
      return false;
    }

    final agent = _freeAgents.firstWhere((a) => a.id == agentId);
    
    try {
      _agentInviteSending[agentId] = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('📧 Sending invite to agent: ${agent.email} with role: $selectedRole');
      
      // Map role to backend format
      final backendRole = _mapRoleToBackend(selectedRole);
      final success = await user_service.InviteService.sendInvite(agent.email, backendRole);

      if (success) {
        debugPrint('✅ Invite sent successfully (new user created or role invitation sent)');
        // Clear agent role selection and collapse card
        _agentSelectedRoles[agentId] = null;
        _agentExpanded[agentId] = false;
        _agentInviteSending[agentId] = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to send invitation';
        _agentInviteSending[agentId] = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending invite: $e');
      _errorMessage = 'Failed to send invitation: ${e.toString()}';
      _agentInviteSending[agentId] = false;
      notifyListeners();
      return false;
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Map UI role to backend role format
  String _mapRoleToBackend(String role) {
    switch (role.toLowerCase()) {
      case 'player':
        return 'player';
      case 'captain':
        return 'captain';
      case 'referee':
        return 'referee';
      case 'stat keeper':
      case 'statkeeper':
      case 'stat-keeper':
        return 'stat-keeper';
      default:
        return role.toLowerCase();
    }
  }

  /// Refresh free agents list
  Future<void> refresh() async {
    await fetchFreeAgents();
  }
}
