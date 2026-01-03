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
    return NotificationModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? 'No Title',
      body:
          json['body'] as String? ?? json['message'] as String? ?? 'No Content',
      type: json['type'] as String? ?? 'info',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      status: json['status'] as String? ?? 'unread',
      teamImage: json['teamImage'] as String?,
      leagueLogo: json['leagueLogo'] as String?,
      league: json['league'] as String?,
      team: json['team'] as String?,
      format: json['format'] as String?,
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
