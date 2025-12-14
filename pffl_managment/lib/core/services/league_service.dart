import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

/// Service for league-related API calls
class LeagueService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Get Dio instance with authentication token
  static Future<Dio> _getAuthenticatedDio() async {
    final token = await AuthService.getToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
    return _dio;
  }

  /// Upload logo to Cloudinary
  /// POST /api/upload
  static Future<String?> uploadLogo(File imageFile, {int retryCount = 1}) async {
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
        throw Exception('Invalid file format. Allowed formats: ${allowedExtensions.join(", ")}');
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
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      try {
        final response = await dio.post(
          '/upload',
          data: formData,
        );

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
          print('Logo upload failed, retrying... (${retryCount} retries left)');
          await Future.delayed(Duration(seconds: 2));
          return uploadLogo(imageFile, retryCount: retryCount - 1);
        }
        rethrow;
      }
    } on DioException catch (e) {
      print('Error uploading logo: ${e.message}');
      print('File path: ${imageFile.path}');
      print('File size: ${await imageFile.length()} bytes');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        print('Error status: ${e.response?.statusCode}');
        
        // Provide specific error message based on status code
        if (e.response?.statusCode == 500) {
          throw Exception(
            'Server error during logo upload. Please check:\n'
            '1. Backend Cloudinary configuration (CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET)\n'
            '2. Backend server logs for detailed error\n'
            '3. File size and format are valid'
          );
        } else if (e.response?.statusCode == 401) {
          throw Exception('Authentication failed. Please login again.');
        } else if (e.response?.statusCode == 400) {
          throw Exception('Invalid file format or missing file data.');
        }
      }
      throw Exception('Failed to upload logo: ${e.message}');
    } catch (e) {
      print('General error uploading logo: $e');
      print('File path: ${imageFile.path}');
      throw Exception('Failed to upload logo: ${e.toString()}');
    }
  }

  /// Create a new league
  /// POST /api/league
  static Future<LeagueResponse?> createLeague(Map<String, dynamic> leagueData) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.post(
        '/league',
        data: leagueData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return LeagueResponse.fromJson(data);
      } else {
        print('Failed to create league: ${response.statusMessage}');
        return null;
      }
    } on DioException catch (e) {
      print('Error creating league: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('General error creating league: $e');
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
      print('Error inviting free agent: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      return false;
    } catch (e) {
      print('General error inviting free agent: $e');
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
      final dio = await _getAuthenticatedDio();
      final response = await dio.post(
        '/league/$leagueId/invite/statkeeper',
        data: {
          'statKeeperId': statKeeperId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Error inviting stat keeper: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      return false;
    } catch (e) {
      print('General error inviting stat keeper: $e');
      return false;
    }
  }

  /// Invite team to league
  /// POST /api/league/:leagueId/invite/team
  static Future<bool> inviteTeamToLeague(
    String leagueId,
    String teamId,
  ) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.post(
        '/league/$leagueId/invite/team',
        data: {
          'teamId': teamId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Error inviting team: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      return false;
    } catch (e) {
      print('General error inviting team: $e');
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
        print('Failed to fetch leagues: ${response.statusMessage}');
        return [];
      }
    } on DioException catch (e) {
      print('Error fetching leagues: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      return [];
    } catch (e) {
      print('General error fetching leagues: $e');
      return [];
    }
  }

  /// Get league by ID
  /// GET /api/league/:id
  /// Fetches league with teams that were assigned during league creation (Step 4)
  static Future<LeagueDetailModel?> getLeagueById(String leagueId) async {
    try {
      final dio = await _getAuthenticatedDio();
      print('📡 Fetching league by ID: $leagueId');
      final response = await dio.get('/league/$leagueId');

      if (response.statusCode == 200) {
        final data = response.data;
        print('✅ League API response received');
        
        if (data['data'] != null) {
          final leagueData = data['data'];
          print('📊 League data structure:');
          print('   - League Name: ${leagueData['leagueName']}');
          print('   - Teams field exists: ${leagueData['teams'] != null}');
          print('   - Teams type: ${leagueData['teams']?.runtimeType}');
          
          if (leagueData['teams'] != null) {
            final teamsArray = leagueData['teams'];
            print('   - Teams array length: ${teamsArray is List ? teamsArray.length : 'N/A'}');
            if (teamsArray is List && teamsArray.isNotEmpty) {
              print('   - First team sample: ${teamsArray[0]}');
            } else if (teamsArray is List && teamsArray.isEmpty) {
              print('   - ⚠️ Teams array is EMPTY - no teams assigned to this league');
            }
          } else {
            print('   - ⚠️ Teams field is null or missing');
          }
          
          final league = LeagueDetailModel.fromJson(leagueData);
          print('✅ League parsed successfully. Teams count: ${league.teams.length}');
          if (league.teams.isEmpty) {
            print('   - ⚠️ WARNING: No teams found in league! Teams should be assigned when invited in Step 4.');
          }
          return league;
        }
        print('❌ Response data field is null');
        return null;
      } else {
        print('❌ Failed to fetch league: ${response.statusMessage}');
        return null;
      }
    } on DioException catch (e) {
      print('❌ DioException fetching league: ${e.message}');
      print('❌ Error type: ${e.type}');
      if (e.response != null) {
        print('❌ Error status: ${e.response?.statusCode}');
        print('❌ Error response data: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      print('❌ General error fetching league: $e');
      print('❌ Error type: ${e.runtimeType}');
      return null;
    }
  }

  /// Get all teams
  /// GET /api/team
  static Future<List<TeamModel>> getAllTeams() async {
    try {
      final dio = await _getAuthenticatedDio();
      print('📡 Calling GET /api/team...');
      final response = await dio.get('/team');

      if (response.statusCode == 200) {
        final data = response.data;
        print('✅ API Response received: ${data.toString().substring(0, 200)}...');
        
        if (data['data'] != null) {
          final teamsList = data['data'] as List;
          print('📊 Found ${teamsList.length} teams in response');
          
          if (teamsList.isEmpty) {
            print('⚠️ Teams array is empty');
            return [];
          }
          
          final teams = teamsList
              .map((json) {
                try {
                  print('🔄 Parsing team: ${json['teamName'] ?? 'Unknown'}');
                  return TeamModel.fromJson(json);
                } catch (e) {
                  print('❌ Error parsing team: $e');
                  print('❌ Team JSON: $json');
                  rethrow;
                }
              })
              .toList();
          
          print('✅ Successfully parsed ${teams.length} teams');
          return teams;
        } else {
          print('⚠️ Response data field is null');
          print('📋 Full response: $data');
          return [];
        }
      } else {
        print('❌ Failed to fetch teams: ${response.statusCode} - ${response.statusMessage}');
        print('❌ Response data: ${response.data}');
        return [];
      }
    } on DioException catch (e) {
      print('❌ DioException fetching teams: ${e.message}');
      print('❌ Error type: ${e.type}');
      if (e.response != null) {
        print('❌ Error status: ${e.response?.statusCode}');
        print('❌ Error response data: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('❌ General error fetching teams: $e');
      print('❌ Error type: ${e.runtimeType}');
      rethrow;
    }
  }
}

/// Team model
class TeamModel {
  final String id;
  final String teamName;
  final String? enterCode;
  final String? location;
  final String? skillLevel;
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
    if (squad5v5 != null && squad5v5!.isNotEmpty) {
      return squad5v5!.length;
    }
    if (squad7v7 != null && squad7v7!.isNotEmpty) {
      return squad7v7!.length;
    }
    if (players != null) {
      return players!.length;
    }
    return 0;
  }
}

/// League response model

/// League response model
class LeagueResponse {
  final String message;
  final LeagueModel data;

  LeagueResponse({
    required this.message,
    required this.data,
  });

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
    
    return LeagueModel(
      id: id,
      leagueName: json['leagueName'] ?? '',
      format: json['format'] ?? '5v5',
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      minimumPlayers: json['minimumPlayers'] ?? 0,
      perPlayerLeagueFee: (json['perPlayerLeagueFee'] ?? 0).toDouble(),
      logo: json['logo'],
      status: json['status'] ?? 'pending',
    );
  }
}

/// League detail model with teams
class LeagueDetailModel {
  final String id;
  final String leagueName;
  final String format;
  final DateTime startDate;
  final DateTime endDate;
  final List<TeamModel> teams;

  LeagueDetailModel({
    required this.id,
    required this.leagueName,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.teams,
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
      print('🔄 Parsing ${teamsList.length} teams from league...');
      
      if (teamsList.isEmpty) {
        print('   - ⚠️ Teams array is EMPTY - no teams assigned to this league');
        print('   - Teams should be assigned when invited in Step 4 of league creation');
      } else {
        teams = teamsList.map((teamJson) {
          try {
            print('   - Parsing team: ${teamJson['teamName'] ?? teamJson['_id'] ?? 'Unknown'}');
            return TeamModel.fromJson(teamJson);
          } catch (e) {
            print('   ❌ Error parsing team: $e');
            print('   ❌ Team JSON: $teamJson');
            rethrow;
          }
        }).toList();
        
        print('✅ Successfully parsed ${teams.length} teams');
      }
    } else {
      print('⚠️ Teams field is null or not a List. Type: ${json['teams']?.runtimeType}');
      if (json['teams'] != null) {
        print('⚠️ Teams value: ${json['teams']}');
      }
    }
    
    return LeagueDetailModel(
      id: id,
      leagueName: json['leagueName'] ?? '',
      format: json['format'] ?? '5v5',
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      teams: teams,
    );
  }
}

