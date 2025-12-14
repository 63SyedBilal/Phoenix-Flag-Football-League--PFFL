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
  String? _errorMessage;
  String _manualEmail = '';
  String? _manualSelectedRole;
  Map<String, String?> _agentSelectedRoles = {}; // agentId -> selectedRole
  Map<String, bool> _agentExpanded = {}; // agentId -> isExpanded

  // Getters
  List<FreeAgentModel> get freeAgents => _freeAgents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get manualEmail => _manualEmail;
  String? get manualSelectedRole => _manualSelectedRole;
  
  String? getAgentSelectedRole(String agentId) => _agentSelectedRoles[agentId];
  bool isAgentExpanded(String agentId) => _agentExpanded[agentId] ?? false;

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

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('📧 Sending invite to: $_manualEmail with role: $_manualSelectedRole');
      
      // Map role to backend format
      final backendRole = _mapRoleToBackend(_manualSelectedRole!);
      final success = await user_service.InviteService.sendInvite(_manualEmail, backendRole);

      if (success) {
        debugPrint('✅ Invite sent successfully (new user created or role invitation sent)');
        // Clear form
        _manualEmail = '';
        _manualSelectedRole = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to send invitation';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending invite: $e');
      _errorMessage = 'Failed to send invitation: ${e.toString()}';
      _isLoading = false;
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
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('📧 Sending invite to agent: ${agent.email} with role: $selectedRole');
      
      // Map role to backend format
      final backendRole = _mapRoleToBackend(selectedRole);
      final success = await user_service.InviteService.sendInvite(agent.email, backendRole);

      if (success) {
        debugPrint('✅ Invite sent successfully (new user created or role invitation sent)');
        // Clear agent role selection
        _agentSelectedRoles[agentId] = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to send invitation';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending invite: $e');
      _errorMessage = 'Failed to send invitation: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
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
