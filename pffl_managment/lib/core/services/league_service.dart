import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/core/services/user_service.dart' show UserModel;

/// Service for league-related API calls
class LeagueService {
  /// Get Dio instance with authentication token and working URL
  static Future<Dio> _getAuthenticatedDio() async {
    // Use AuthService's working Dio instance which has the correct URL
    return await AuthService.getWorkingDio();
  }

  /// Upload logo to Cloudinary
  /// POST /api/upload
  static Future<String?> uploadLogo(
    File imageFile, {
    int retryCount = 1,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Validate file exists
      if (!await imageFile.exists()) {
        throw Exception('Logo file does not exist: ${imageFile.path}');
      }

      // Validate file size (max 10MB)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Logo file is too large. Maximum size is 10MB');
      }

      // Get file extension for validation
      final fileName = imageFile.path.split(Platform.pathSeparator).last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      if (!allowedExtensions.contains(fileExtension)) {
        throw Exception(
          'Invalid file format. Allowed formats: ${allowedExtensions.join(", ")}',
        );
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'folder': 'pffl/leagues',
      });

      final dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: Duration(seconds: 60), // Increase for file uploads
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      try {
        final response = await dio.post('/upload', data: formData);

        if (response.statusCode == 200) {
          final data = response.data;
          if (data['data'] != null && data['data']['url'] != null) {
            return data['data']['url'] as String;
          }
          throw Exception('Invalid response format from server');
        }
        throw Exception('Upload failed with status: ${response.statusCode}');
      } on DioException catch (e) {
        // Retry once on 500 error (might be transient)
        if (retryCount > 0 && e.response?.statusCode == 500) {
          await Future.delayed(Duration(seconds: 2));
          return uploadLogo(imageFile, retryCount: retryCount - 1);
        }
        rethrow;
      }
    } on DioException catch (e) {
      if (e.response != null) {

        // Provide specific error message based on status code
        if (e.response?.statusCode == 500) {
          throw Exception(
            'Server error during logo upload. Please check:\n'
            '1. Backend Cloudinary configuration (CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET)\n'
            '2. Backend server logs for detailed error\n'
            '3. File size and format are valid',
          );
        } else if (e.response?.statusCode == 401) {
          throw Exception('Authentication failed. Please login again.');
        } else if (e.response?.statusCode == 400) {
          throw Exception('Invalid file format or missing file data.');
        }
      }
      throw Exception('Failed to upload logo: ${e.message}');
    } catch (e) {
      throw Exception('Failed to upload logo: ${e.toString()}');
    }
  }

  /// Create a new league
  /// POST /api/league
  static Future<LeagueResponse?> createLeague(
    Map<String, dynamic> leagueData,
  ) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.post('/league', data: leagueData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return LeagueResponse.fromJson(data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Invite free agent to league (via referee invite endpoint)
  /// POST /api/league/:leagueId/invite/referee
  static Future<bool> inviteFreeAgentToLeague(
    String leagueId,
    String freeAgentId,
  ) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.post(
        '/league/$leagueId/invite/referee',
        data: {
          'refereeId': freeAgentId, // Backend expects refereeId
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response != null) {
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Invite referee to league
  /// POST /api/league/:leagueId/invite/referee
  /// Sends notification to referee - when referee accepts, league is assigned
  static Future<bool> inviteRefereeToLeague(
    String leagueId,
    String refereeId,
  ) async {
    try {
      print(
        '📤 [inviteRefereeToLeague] Starting - leagueId=$leagueId, refereeId=$refereeId',
      );
      final dio = await _getAuthenticatedDio();
      print(
        '📤 [inviteRefereeToLeague] Dio instance created, calling endpoint: /league/$leagueId/invite/referee',
      );

      final response = await dio.post(
        '/league/$leagueId/invite/referee',
        data: {'refereeId': refereeId},
      );

      print(
        '📤 [inviteRefereeToLeague] Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map && data.containsKey('success')) {
          final success = data['success'] == true;
          if (success) {
            print(
              '✅ [inviteRefereeToLeague] Referee invitation sent successfully',
            );
            return true;
          } else {
            final error = data['error'] ?? 'Unknown error';
            return false;
          }
        }
        print(
          '✅ [inviteRefereeToLeague] Referee invitation sent successfully (no success field)',
        );
        return true;
      }
      print(
        '❌ [inviteRefereeToLeague] Unexpected status code: ${response.statusCode}',
      );
      return false;
    } on DioException catch (e) {
      if (e.response != null) {
        print(
          '❌ [inviteRefereeToLeague] Response status: ${e.response?.statusCode}',
        );
        // Handle 409 - invite already sent (this is actually success)
        if (e.response?.statusCode == 409) {
          print(
            '⚠️ [inviteRefereeToLeague] Invite already sent to this referee (409) - treating as success',
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Invite stat keeper to league
  /// POST /api/league/:leagueId/invite/statkeeper
  static Future<bool> inviteStatKeeperToLeague(
    String leagueId,
    String statKeeperId,
  ) async {
    try {
      print(
        '📤 [inviteStatKeeperToLeague] Starting - leagueId=$leagueId, statKeeperId=$statKeeperId',
      );
      final dio = await _getAuthenticatedDio();
      print(
        '📤 [inviteStatKeeperToLeague] Dio instance created, calling endpoint: /league/$leagueId/invite/statkeeper',
      );

      final response = await dio.post(
        '/league/$leagueId/invite/statkeeper',
        data: {'statKeeperId': statKeeperId},
      );

      print(
        '📤 [inviteStatKeeperToLeague] Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map && data.containsKey('success')) {
          final success = data['success'] == true;
          if (success) {
            print(
              '✅ [inviteStatKeeperToLeague] Stat keeper invitation sent successfully',
            );
            return true;
          } else {
            final error = data['error'] ?? 'Unknown error';
            return false;
          }
        }
        print(
          '✅ [inviteStatKeeperToLeague] Stat keeper invitation sent successfully (no success field)',
        );
        return true;
      }
      print(
        '❌ [inviteStatKeeperToLeague] Unexpected status code: ${response.statusCode}',
      );
      return false;
    } on DioException catch (e) {
      if (e.response != null) {
        print(
          '❌ [inviteStatKeeperToLeague] Response status: ${e.response?.statusCode}',
        );
        print(
          '❌ [inviteStatKeeperToLeague] Response data: ${e.response?.data}',
        );
        // Handle 409 - invite already sent (this is actually success)
        if (e.response?.statusCode == 409) {
          print(
            '⚠️ [inviteStatKeeperToLeague] Invite already sent to this stat keeper (409) - treating as success',
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Invite team to league
  /// POST /api/league/:leagueId/invite/team
  static Future<bool> inviteTeamToLeague(String leagueId, String teamId) async {
    try {
      final dio = await _getAuthenticatedDio();

      final response = await dio.post(
        '/league/$leagueId/invite/team',
        data: {'teamId': teamId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        // Check if response has success field
        if (data is Map && data.containsKey('success')) {
          final success = data['success'] == true;
          if (success) {
            return true;
          } else {
            final error = data['error'] ?? 'Unknown error';
            throw Exception(error);
          }
        }
        // If no success field, assume success based on status code
        print(
          '✅ Team invitation sent successfully (no success field in response)',
        );
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle 409 - invite already sent (this is actually success)
        if (e.response?.statusCode == 409) {
          print(
            '⚠️ Invite already sent to this team (409) - treating as success',
          );
          return true;
        }
      }
      // Return false instead of throwing - silent failure for fire-and-forget
      return false;
    } catch (e) {
      // Return false instead of throwing - silent failure for fire-and-forget
      return false;
    }
  }

  /// Get all leagues
  /// GET /api/league
  static Future<List<LeagueModel>> getAllLeagues() async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/league');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          final leagues = (data['data'] as List)
              .map((json) => LeagueModel.fromJson(json))
              .toList();
          return leagues;
        }
        return [];
      } else {
        return [];
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get league by ID
  /// GET /api/league/:id
  /// Fetches league with teams that were assigned during league creation (Step 4)
  static Future<LeagueDetailModel?> getLeagueById(String leagueId) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/league/$leagueId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['data'] != null) {
          final leagueData = data['data'];

          if (leagueData['teams'] != null) {
            final teamsArray = leagueData['teams'];
            print(
              '   - Teams array length: ${teamsArray is List ? teamsArray.length : 'N/A'}',
            );
            if (teamsArray is List && teamsArray.isNotEmpty) {
            } else if (teamsArray is List && teamsArray.isEmpty) {
              print(
                '   - ⚠️ Teams array is EMPTY - no teams assigned to this league',
              );
            }
          } else {
          }

          final league = LeagueDetailModel.fromJson(leagueData);
          print(
            '✅ League parsed successfully. Teams count: ${league.teams.length}',
          );
          if (league.teams.isEmpty) {
            print(
              '   - ⚠️ WARNING: No teams found in league! Teams should be assigned when invited in Step 4.',
            );
          }
          return league;
        }
        return null;
      } else {
        return null;
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get all teams
  /// GET /api/team
  static Future<List<TeamModel>> getAllTeams() async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/team');

      if (response.statusCode == 200) {
        final data = response.data;
        final responseStr = data.toString();
        print(
          '✅ API Response received: ${responseStr.length > 200 ? '${responseStr.substring(0, 200)}...' : responseStr}',
        );

        if (data['data'] != null) {
          final teamsList = data['data'] as List;

          if (teamsList.isEmpty) {
            return [];
          }

          final teams = teamsList.map((json) {
            try {
              return TeamModel.fromJson(json);
            } catch (e) {
              rethrow;
            }
          }).toList();
          return teams;
        } else {
          return [];
        }
      } else {
        print(
          '❌ Failed to fetch teams: ${response.statusCode} - ${response.statusMessage}',
        );
        return [];
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Check league payment status for a user (captain or player)
  /// GET /api/league/:leagueId/payment-status/:userId
  static Future<Map<String, dynamic>> checkLeaguePaymentStatus(
    String leagueId,
    String userId,
  ) async {
    try {
      print(
        '💳 Checking league payment status: league=$leagueId, user=$userId',
      );
      final dio = await _getAuthenticatedDio();

      final response = await dio.get(
        '/league/$leagueId/payment-status/$userId',
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print(
          '❌ Failed to check league payment status: ${response.statusMessage}',
        );
        return {
          'success': false,
          'message':
              response.statusMessage ?? 'Failed to check league payment status',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      return {
        'success': false,
        'message':
            e.response?.data?['error'] ??
            'Failed to check league payment status: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error checking league payment status: $e',
      };
    }
  }

  /// Get league summary data
  /// GET /api/league/:leagueId/summary
  static Future<Map<String, dynamic>> getLeagueSummary(String leagueId) async {
    try {
      final dio = await _getAuthenticatedDio();

      final response = await dio.get('/league/$leagueId/summary');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          'success': false,
          'message': response.statusMessage ?? 'Failed to get league summary',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      return {
        'success': false,
        'message':
            e.response?.data?['error'] ??
            'Failed to get league summary: ${e.message}',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error getting league summary: $e'};
    }
  }
}

class TeamModel {
  final String id;
  final String teamName;
  final String? enterCode;
  final String? location;
  final String? skillLevel;
  final String? image; // Team logo/image URL
  final Map<String, dynamic>? captain;
  final List<dynamic>? squad5v5;
  final List<dynamic>? squad7v7;
  final List<dynamic>? players;

  TeamModel({
    required this.id,
    required this.teamName,
    this.enterCode,
    this.location,
    this.skillLevel,
    this.image,
    this.captain,
    this.squad5v5,
    this.squad7v7,
    this.players,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';

    return TeamModel(
      id: id,
      teamName: json['teamName'] ?? '',
      enterCode: json['enterCode'],
      location: json['location'],
      skillLevel: json['skillLevel'],
      image: json['image']?.toString(),
      captain: json['captain'] is Map ? json['captain'] : null,
      squad5v5: json['squad5v5'],
      squad7v7: json['squad7v7'],
      players: json['players'],
    );
  }

  String get captainName {
    if (captain != null) {
      final firstName = captain!['firstName'] ?? '';
      final lastName = captain!['lastName'] ?? '';
      return '${firstName} ${lastName}'.trim();
    }
    return 'Unknown';
  }

  String get captainId {
    if (captain != null && captain!['_id'] != null) {
      return captain!['_id'].toString();
    }
    return '';
  }

  int get playerCount {
    return _getUnifiedSquad().length;
  }

  // Helper to normalize the squad list
  List<Map<String, dynamic>> _getUnifiedSquad() {
    List<dynamic> sourceList = [];
    if (squad5v5 != null && squad5v5!.isNotEmpty) {
      sourceList = squad5v5!;
    } else if (squad7v7 != null && squad7v7!.isNotEmpty) {
      sourceList = squad7v7!;
    } else if (players != null) {
      sourceList = players!;
    }

    return sourceList
        .map((player) {
          if (player is Map<String, dynamic>) {
            return player;
          }
          return <String, dynamic>{};
        })
        .where((map) => map.isNotEmpty)
        .toList();
  }

  // Returns formatted list for UI
  List<Map<String, dynamic>> get formattedPlayers {
    final squad = _getUnifiedSquad();
    int index = 1;

    return squad.map((p) {
      final firstName = p['firstName'] ?? '';
      final lastName = p['lastName'] ?? '';
      final fullName = '$firstName $lastName'.trim().isNotEmpty
          ? '$firstName $lastName'.trim()
          : (p['email'] ?? 'Unknown Player');

      // Attempt to find payment status
      // If it's not directly on the player object (which it usually isn't in simple User objects),
      // we check for specific fields the backend might have enriched.
      // If not present, we default to false (Unpaid) as per standard safety.
      final isPaid = p['isPaid'] == true || p['paymentStatus'] == 'paid';

      final number =
          p['jerseyNumber']?.toString() ??
          p['number']?.toString() ??
          index.toString().padLeft(2, '0');
      index++;

      return {
        'id': p['_id']?.toString() ?? p['id']?.toString() ?? '',
        'name': fullName,
        'number': number,
        'paid': isPaid,
        'originalData': p, // Keep original for reference
      };
    }).toList();
  }
}

/// League response model

/// League response model
class LeagueResponse {
  final String message;
  final LeagueModel data;

  LeagueResponse({required this.message, required this.data});

  factory LeagueResponse.fromJson(Map<String, dynamic> json) {
    return LeagueResponse(
      message: json['message'] ?? '',
      data: LeagueModel.fromJson(json['data']),
    );
  }
}

/// League model
class LeagueModel {
  final String id;
  final String leagueName;
  final String format;
  final DateTime startDate;
  final DateTime endDate;
  final int minimumPlayers;
  final double perPlayerLeagueFee;
  final String? logo;
  final String status;
  final DateTime? createdAt;

  LeagueModel({
    required this.id,
    required this.leagueName,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.minimumPlayers,
    required this.perPlayerLeagueFee,
    this.logo,
    required this.status,
    this.createdAt,
  });

  factory LeagueModel.fromJson(Map<String, dynamic> json) {
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';

    // Parse dates - handle both ISO string and DateTime object
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        return dateValue;
      } else {
        throw FormatException('Invalid date format: $dateValue');
      }
    }

    double parseFee(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      if (v is String) {
        final cleaned = v.replaceAll(RegExp(r'[^0-9\.]'), '');
        return double.tryParse(cleaned) ?? 0;
      }
      return 0;
    }

    final feeValue =
        json['perPlayerLeagueFee'] ??
        json['perPlayerFee'] ??
        json['leagueFee'] ??
        json['fee'] ??
        json['amount'];

    return LeagueModel(
      id: id,
      leagueName: json['leagueName'] ?? '',
      format: json['format'] ?? '5v5',
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      minimumPlayers: json['minimumPlayers'] ?? 0,
      perPlayerLeagueFee: parseFee(feeValue),
      logo: json['logo'],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? parseDate(json['createdAt'])
          : null,
    );
  }
}

/// League detail model with teams, referees, and stat keepers
/// Referees and stat keepers are users assigned to the league when they accept invitation
class LeagueDetailModel {
  final String id;
  final String leagueName;
  final String format;
  final DateTime startDate;
  final DateTime endDate;
  final double perPlayerLeagueFee;
  final List<TeamModel> teams;
  final List<UserModel>
  referees; // Referees assigned to the league (when they accept invitation)
  final List<UserModel>
  statKeepers; // Stat keepers assigned to the league (when they accept invitation)

  LeagueDetailModel({
    required this.id,
    required this.leagueName,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.perPlayerLeagueFee,
    required this.teams,
    required this.referees,
    required this.statKeepers,
  });

  factory LeagueDetailModel.fromJson(Map<String, dynamic> json) {
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';

    // Parse dates
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        return dateValue;
      } else {
        throw FormatException('Invalid date format: $dateValue');
      }
    }

    // Parse teams array
    // Teams are assigned to league during Step 4 of league creation
    List<TeamModel> teams = [];
    if (json['teams'] != null && json['teams'] is List) {
      final teamsList = json['teams'] as List;

      if (teamsList.isEmpty) {
        print(
          '   - ⚠️ Teams array is EMPTY - no teams assigned to this league',
        );
        print(
          '   - Teams should be assigned when invited in Step 4 of league creation',
        );
      } else {
        teams = teamsList.map((teamJson) {
          try {
            print(
              '   - Parsing team: ${teamJson['teamName'] ?? teamJson['_id'] ?? 'Unknown'}',
            );
            return TeamModel.fromJson(teamJson);
          } catch (e) {
            rethrow;
          }
        }).toList();
      }
    } else {
      print(
        '⚠️ Teams field is null or not a List. Type: ${json['teams']?.runtimeType}',
      );
      if (json['teams'] != null) {
      }
    }

    // Parse referees array
    // Referees are assigned to league when they accept invitation during league creation (Step 2)
    List<UserModel> referees = [];
    if (json['referees'] != null && json['referees'] is List) {
      final refereesList = json['referees'] as List;

      if (refereesList.isEmpty) {
        print(
          '   - ℹ️ Referees array is EMPTY - no referees assigned to this league yet',
        );
        print(
          '   - Referees should be assigned when they accept invitation in Step 2 of league creation',
        );
      } else {
        referees = refereesList.map((refereeJson) {
          try {
            return UserModel.fromJson(refereeJson);
          } catch (e) {
            // Return a default user model to avoid breaking the list
            return UserModel(
              id:
                  refereeJson['_id']?.toString() ??
                  refereeJson['id']?.toString() ??
                  '',
              firstName: refereeJson['firstName'],
              lastName: refereeJson['lastName'],
              email: refereeJson['email'] ?? '',
              phone: refereeJson['phone'],
              role: refereeJson['role'] ?? 'referee',
            );
          }
        }).toList();
      }
    } else {
      print(
        '⚠️ Referees field is null or not a List. Type: ${json['referees']?.runtimeType}',
      );
    }

    // Parse stat keepers array
    // Stat keepers are assigned to league when they accept invitation during league creation (Step 3)
    List<UserModel> statKeepers = [];
    if (json['statKeepers'] != null && json['statKeepers'] is List) {
      final statKeepersList = json['statKeepers'] as List;

      if (statKeepersList.isEmpty) {
        print(
          '   - ℹ️ Stat keepers array is EMPTY - no stat keepers assigned to this league yet',
        );
        print(
          '   - Stat keepers should be assigned when they accept invitation in Step 3 of league creation',
        );
      } else {
        statKeepers = statKeepersList.map((statKeeperJson) {
          try {
            return UserModel.fromJson(statKeeperJson);
          } catch (e) {
            // Return a default user model to avoid breaking the list
            return UserModel(
              id:
                  statKeeperJson['_id']?.toString() ??
                  statKeeperJson['id']?.toString() ??
                  '',
              firstName: statKeeperJson['firstName'],
              lastName: statKeeperJson['lastName'],
              email: statKeeperJson['email'] ?? '',
              phone: statKeeperJson['phone'],
              role: statKeeperJson['role'] ?? 'stat-keeper',
            );
          }
        }).toList();
      }
    } else {
      print(
        '⚠️ Stat keepers field is null or not a List. Type: ${json['statKeepers']?.runtimeType}',
      );
    }

    return LeagueDetailModel(
      id: id,
      leagueName: json['leagueName'] ?? '',
      format: json['format'] ?? '5v5',
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      perPlayerLeagueFee: (json['perPlayerLeagueFee'] ?? 0).toDouble(),
      teams: teams,
      referees: referees,
      statKeepers: statKeepers,
    );
  }
}

