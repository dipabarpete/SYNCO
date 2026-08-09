class UserProfile {
  final String id;
  final String username;
  final String avatarUrl;
  final String? email;
  final String? phone;
  final bool onboardingCompleted;
  final bool isPartnerLinked;
  final String? partnerCode;
  final String? partnerName;
  final int age;
  final double weightKg;
  final double heightCm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.username,
    required this.avatarUrl,
    this.email,
    this.phone,
    this.onboardingCompleted = false,
    this.isPartnerLinked = false,
    this.partnerCode,
    this.partnerName,
    this.age = 24,
    this.weightKg = 54.5,
    this.heightCm = 163.0,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      username: map['name']?.toString() ?? map['username']?.toString() ?? 'User',
      avatarUrl: map['avatar_url']?.toString() ?? map['avatarUrl']?.toString() ?? '',
      email: map['email']?.toString(),
      phone: map['phone']?.toString(),
      onboardingCompleted: map['onboarding_completed'] ?? map['onboardingCompleted'] ?? false,
      isPartnerLinked: map['is_partner_linked'] ?? map['isPartnerLinked'] ?? false,
      partnerCode: map['partner_code']?.toString() ?? map['partnerCode']?.toString(),
      partnerName: map['partner_name']?.toString() ?? map['partnerName']?.toString(),
      age: map['age'] != null ? int.tryParse(map['age'].toString()) ?? 24 : 24,
      weightKg: map['weight_kg'] != null
          ? double.tryParse(map['weight_kg'].toString()) ?? 54.5
          : 54.5,
      heightCm: map['height_cm'] != null
          ? double.tryParse(map['height_cm'].toString()) ?? 163.0
          : 163.0,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': username,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'onboarding_completed': onboardingCompleted,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? username,
    String? avatarUrl,
    String? email,
    String? phone,
    bool? onboardingCompleted,
    bool? isPartnerLinked,
    String? partnerCode,
    String? partnerName,
    int? age,
    double? weightKg,
    double? heightCm,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isPartnerLinked: isPartnerLinked ?? this.isPartnerLinked,
      partnerCode: partnerCode ?? this.partnerCode,
      partnerName: partnerName ?? this.partnerName,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
