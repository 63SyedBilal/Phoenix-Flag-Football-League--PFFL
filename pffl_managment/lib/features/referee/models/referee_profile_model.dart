class RefereeProfileModel {
  final String experience;
  final String emergencyContactName;
  final String emergencyPhone;
  final String? profileImageUrl;
  final bool isRefereeProfileComplete;

  RefereeProfileModel({
    required this.experience,
    required this.emergencyContactName,
    required this.emergencyPhone,
    this.profileImageUrl,
    required this.isRefereeProfileComplete,
  });

  factory RefereeProfileModel.fromJson(Map<String, dynamic> json) {
    return RefereeProfileModel(
      experience: json['experience'] ?? '',
      emergencyContactName: json['emergencyContactName'] ?? '',
      emergencyPhone: json['emergencyPhone'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      isRefereeProfileComplete: json['isRefereeProfileComplete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'experience': experience,
      'emergencyContactName': emergencyContactName,
      'emergencyPhone': emergencyPhone,
      'profileImageUrl': profileImageUrl,
      'isRefereeProfileComplete': isRefereeProfileComplete,
    };
  }
}
