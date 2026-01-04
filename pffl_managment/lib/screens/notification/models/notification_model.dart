class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String status;
  final String? teamImage;
  final String? leagueLogo;
  final String? league;
  final String? team;
  final String? format;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.status = 'unread',
    this.teamImage,
    this.leagueLogo,
    this.league,
    this.team,
    this.format,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isAccepted => status.toLowerCase() == 'accepted';
  String get displayMessage => body;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    String extractString(dynamic value, {String defaultVal = ''}) {
      if (value == null) return defaultVal;
      if (value is String) return value;
      if (value is Map) {
        return value['name']?.toString() ??
            value['title']?.toString() ??
            value['id']?.toString() ??
            value['_id']?.toString() ??
            defaultVal;
      }
      return value.toString();
    }

    return NotificationModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: extractString(json['title'], defaultVal: 'No Title'),
      body: extractString(
        json['body'] ?? json['message'],
        defaultVal: 'No Content',
      ),
      type: extractString(json['type'], defaultVal: 'info'),
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      status: extractString(json['status'], defaultVal: 'unread'),
      teamImage: json['teamImage']?.toString(),
      leagueLogo: json['leagueLogo']?.toString(),
      league: extractString(json['league'], defaultVal: ''),
      team: extractString(json['team'], defaultVal: ''),
      format: extractString(json['format'], defaultVal: ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'teamImage': teamImage,
      'leagueLogo': leagueLogo,
      'league': league,
      'team': team,
      'format': format,
    };
  }
}
