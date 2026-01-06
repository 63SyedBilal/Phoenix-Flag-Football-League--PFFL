class PlayerModel {
  final String id;
  final String name;
  final String number;
  final String email;
  final String position;
  final bool isCaptain;
  final String? imageUrl;
  final bool isVerified;
  final bool hasAlert;
  final bool isPaid;
  final int additionalPositionsCount;

  PlayerModel({
    required this.id,
    required this.name,
    required this.number,
    required this.email,
    required this.position,
    this.isCaptain = false,
    this.imageUrl,
    this.isVerified = false,
    this.hasAlert = false,
    this.isPaid = false,
    this.additionalPositionsCount = 0,
  });

  // Add copyWith method
  PlayerModel copyWith({
    String? id,
    String? name,
    String? number,
    String? email,
    String? position,
    bool? isCaptain,
    String? imageUrl,
    bool? isVerified,
    bool? hasAlert,
    bool? isPaid,
    int? additionalPositionsCount,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      email: email ?? this.email,
      position: position ?? this.position,
      isCaptain: isCaptain ?? this.isCaptain,
      imageUrl: imageUrl ?? this.imageUrl,
      isVerified: isVerified ?? this.isVerified,
      hasAlert: hasAlert ?? this.hasAlert,
      isPaid: isPaid ?? this.isPaid,
      additionalPositionsCount:
          additionalPositionsCount ?? this.additionalPositionsCount,
    );
  }

  // Helper for UI display
  String get displayPosition =>
      (position.isNotEmpty && position != 'null') ? position : '-';
}
