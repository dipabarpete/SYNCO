enum UserRole {
  user,
  doctor,
}

enum PcosDiagnosisStatus {
  diagnosed,
  notDiagnosed,
  preferNotToSay,
}

extension UserRoleExtension on UserRole {
  String toDbValue() {
    switch (this) {
      case UserRole.doctor:
        return 'doctor';
      case UserRole.user:
        return 'user';
    }
  }

  static UserRole fromDbValue(String? value) {
    if (value == 'doctor') return UserRole.doctor;
    return UserRole.user;
  }
}

extension PcosDiagnosisStatusExtension on PcosDiagnosisStatus {
  String toDbValue() {
    switch (this) {
      case PcosDiagnosisStatus.diagnosed:
        return 'diagnosed';
      case PcosDiagnosisStatus.notDiagnosed:
        return 'not_diagnosed';
      case PcosDiagnosisStatus.preferNotToSay:
        return 'prefer_not_to_say';
    }
  }

  static PcosDiagnosisStatus fromDbValue(String? value) {
    switch (value) {
      case 'diagnosed':
        return PcosDiagnosisStatus.diagnosed;
      case 'not_diagnosed':
        return PcosDiagnosisStatus.notDiagnosed;
      case 'prefer_not_to_say':
      default:
        return PcosDiagnosisStatus.preferNotToSay;
    }
  }
}

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
  final UserRole role;
  final PcosDiagnosisStatus diagnosisStatus;
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
    this.role = UserRole.user,
    this.diagnosisStatus = PcosDiagnosisStatus.preferNotToSay,
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
      role: UserRoleExtension.fromDbValue(map['role']?.toString()),
      diagnosisStatus: PcosDiagnosisStatusExtension.fromDbValue(map['diagnosis_status']?.toString()),
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
      'role': role.toDbValue(),
      'diagnosis_status': diagnosisStatus.toDbValue(),
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
    UserRole? role,
    PcosDiagnosisStatus? diagnosisStatus,
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
      role: role ?? this.role,
      diagnosisStatus: diagnosisStatus ?? this.diagnosisStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
