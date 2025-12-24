class NotificationModel {
  final String id;
  final UserModel? sender;
  final UserModel? receiver;
  final TeamModel? team;
  final LeagueModel? league;
  final Map<String, dynamic>? match;
  final String type;
  final String status;
  final String? format;
  final String? message;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    this.sender,
    this.receiver,
    this.team,
    this.league,
    this.match,
    required this.type,
    required this.status,
    this.format,
    this.message,
    required this.createdAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isAccepted => status.toLowerCase() == 'accepted';
  String get displayMessage => message ?? 'No details available';
  String? get teamImage => team?.image;
  String? get leagueLogo => league?.logo;
  String get teamName => team?.teamName ?? 'Unknown Team';
  String get leagueName => league?.leagueName ?? 'Unknown League';

  String get senderName {
    if (sender == null) return 'Unknown';
    final firstName = sender!.firstName;
    final lastName = sender!.lastName;
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    return sender!.email.isNotEmpty ? sender!.email : 'Unknown';
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? '',
      sender: json['sender'] != null && json['sender'] is Map<String, dynamic>
          ? UserModel.fromJson(json['sender'])
          : null,
      receiver:
          json['receiver'] != null && json['receiver'] is Map<String, dynamic>
          ? UserModel.fromJson(json['receiver'])
          : null,
      team: json['team'] != null && json['team'] is Map<String, dynamic>
          ? TeamModel.fromJson(json['team'])
          : null,
      league: json['league'] != null && json['league'] is Map<String, dynamic>
          ? LeagueModel.fromJson(json['league'])
          : null,
      match: json['match'] != null && json['match'] is Map<String, dynamic>
          ? json['match']
          : null,
      type: json['type']?.toString() ?? 'SYSTEM',
      status: json['status']?.toString() ?? 'pending',
      format: json['format']?.toString(),
      message: json['message']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// Minimal models to support NotificationModel if they don't exist yet or to avoid circular deps.
// In a real scenario, we should import these from their respective files.
// Assuming these classes exist or will be needed.
// For now, I'll use simple Map parsing if imports aren't available, but it's better to expect imports.
// To avoid compilation errors if other models aren't found, I'll define basic structures here
// or rely on imports. Since I don't want to break existing imports without checking,
// I will just use Map<String, dynamic> extraction in a helper or assume standard structure.

// Actually, let's use a safer approach. I'll check if I need to import User/Team/League models.
// A safe simplified inner class approach or using dynamic maps for now is safer if I don't know the exact other model locations/names.
// But given the error "type cast", strong typing is better.
// I'll stick to a robust simpler version that parses known fields safely.

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

class TeamModel {
  final String id;
  final String teamName;
  final String? image;

  TeamModel({required this.id, required this.teamName, this.image});

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['_id']?.toString() ?? '',
      teamName: json['teamName']?.toString() ?? 'Unknown Team',
      image: json['image']?.toString(),
    );
  }
}

class LeagueModel {
  final String id;
  final String leagueName;
  final String? logo;

  LeagueModel({required this.id, required this.leagueName, this.logo});

  factory LeagueModel.fromJson(Map<String, dynamic> json) {
    return LeagueModel(
      id: json['_id']?.toString() ?? '',
      leagueName: json['leagueName']?.toString() ?? 'Unknown League',
      logo: json['logo']?.toString(),
    );
  }
}
