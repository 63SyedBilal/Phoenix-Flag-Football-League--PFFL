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
}
