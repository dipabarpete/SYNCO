class UserProfile {
  final String id;
  final String username;
  final String avatarUrl;
  final bool isPartnerLinked;
  final String? partnerCode;
  final String? partnerName;
  final int age;
  final double weightKg;
  final double heightCm;

  UserProfile({
    required this.id,
    required this.username,
    required this.avatarUrl,
    this.isPartnerLinked = false,
    this.partnerCode,
    this.partnerName,
    this.age = 24,
    this.weightKg = 54.5,
    this.heightCm = 163.0,
  });

  UserProfile copyWith({
    String? username,
    String? avatarUrl,
    bool? isPartnerLinked,
    String? partnerCode,
    String? partnerName,
    int? age,
    double? weightKg,
    double? heightCm,
  }) {
    return UserProfile(
      id: id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPartnerLinked: isPartnerLinked ?? this.isPartnerLinked,
      partnerCode: partnerCode ?? this.partnerCode,
      partnerName: partnerName ?? this.partnerName,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
    );
  }
}
