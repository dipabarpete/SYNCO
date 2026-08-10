import 'early_risk_assessment.dart';

enum UserRole { user, doctor }

enum PcosDiagnosisStatus { diagnosed, notDiagnosed, preferNotToSay }

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
  final String? diagnosedBy;
  final String? diagnosisTimeframe;
  final String? medicationStatus;
  final String? currentMedicationsOrSupplements;
  final List<String> currentConcerns;
  final String? otherConcern;
  final String? periodRegularity;
  final int? averageCycleLengthDays;
  final String? recentSymptomChange;
  final String? labReportAvailability;
  final List<Map<String, dynamic>> labReports;
  final String? primaryGoal;
  final EarlyRiskAssessment? earlyRiskAssessment;
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
    this.diagnosedBy,
    this.diagnosisTimeframe,
    this.medicationStatus,
    this.currentMedicationsOrSupplements,
    this.currentConcerns = const [],
    this.otherConcern,
    this.periodRegularity,
    this.averageCycleLengthDays,
    this.recentSymptomChange,
    this.labReportAvailability,
    this.labReports = const [],
    this.primaryGoal,
    this.earlyRiskAssessment,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      username:
          map['name']?.toString() ?? map['username']?.toString() ?? 'User',
      avatarUrl:
          map['avatar_url']?.toString() ?? map['avatarUrl']?.toString() ?? '',
      email: map['email']?.toString(),
      phone: map['phone']?.toString(),
      onboardingCompleted:
          map['onboarding_completed'] ?? map['onboardingCompleted'] ?? false,
      isPartnerLinked:
          map['is_partner_linked'] ?? map['isPartnerLinked'] ?? false,
      partnerCode:
          map['partner_code']?.toString() ?? map['partnerCode']?.toString(),
      partnerName:
          map['partner_name']?.toString() ?? map['partnerName']?.toString(),
      age: map['age'] != null ? int.tryParse(map['age'].toString()) ?? 24 : 24,
      weightKg: map['weight_kg'] != null
          ? double.tryParse(map['weight_kg'].toString()) ?? 54.5
          : 54.5,
      heightCm: map['height_cm'] != null
          ? double.tryParse(map['height_cm'].toString()) ?? 163.0
          : 163.0,
      role: UserRoleExtension.fromDbValue(map['role']?.toString()),
      diagnosisStatus: PcosDiagnosisStatusExtension.fromDbValue(
        map['diagnosis_status']?.toString(),
      ),
      diagnosedBy: map['diagnosed_by']?.toString(),
      diagnosisTimeframe: map['diagnosis_timeframe']?.toString(),
      medicationStatus: map['medication_status']?.toString(),
      currentMedicationsOrSupplements: map['current_medications_or_supplements']
          ?.toString(),
      currentConcerns:
          (map['current_concerns'] as List<dynamic>?)
              ?.map((concern) => concern.toString())
              .toList() ??
          const [],
      otherConcern: map['other_concern']?.toString(),
      periodRegularity: map['period_regularity']?.toString(),
      averageCycleLengthDays: map['average_cycle_length_days'] == null
          ? null
          : int.tryParse(map['average_cycle_length_days'].toString()),
      recentSymptomChange: map['recent_symptom_change']?.toString(),
      labReportAvailability: map['lab_report_availability']?.toString(),
      labReports:
          (map['lab_reports'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((report) => Map<String, dynamic>.from(report))
              .toList() ??
          const [],
      primaryGoal: map['primary_goal']?.toString(),
      earlyRiskAssessment: map['early_risk_assessment'] is Map
          ? EarlyRiskAssessment.fromMap(
              Map<String, dynamic>.from(map['early_risk_assessment'] as Map),
            )
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
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
      'diagnosed_by': diagnosedBy,
      'diagnosis_timeframe': diagnosisTimeframe,
      'medication_status': medicationStatus,
      'current_medications_or_supplements': currentMedicationsOrSupplements,
      'current_concerns': currentConcerns,
      'other_concern': otherConcern,
      'period_regularity': periodRegularity,
      'average_cycle_length_days': averageCycleLengthDays,
      'recent_symptom_change': recentSymptomChange,
      'lab_report_availability': labReportAvailability,
      'lab_reports': labReports,
      'primary_goal': primaryGoal,
      'early_risk_assessment': earlyRiskAssessment?.toMap(),
      'created_at':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
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
    Object? diagnosedBy = _unset,
    Object? diagnosisTimeframe = _unset,
    Object? medicationStatus = _unset,
    Object? currentMedicationsOrSupplements = _unset,
    List<String>? currentConcerns,
    Object? otherConcern = _unset,
    Object? periodRegularity = _unset,
    Object? averageCycleLengthDays = _unset,
    Object? recentSymptomChange = _unset,
    Object? labReportAvailability = _unset,
    List<Map<String, dynamic>>? labReports,
    Object? primaryGoal = _unset,
    Object? earlyRiskAssessment = _unset,
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
      diagnosedBy: identical(diagnosedBy, _unset)
          ? this.diagnosedBy
          : diagnosedBy as String?,
      diagnosisTimeframe: identical(diagnosisTimeframe, _unset)
          ? this.diagnosisTimeframe
          : diagnosisTimeframe as String?,
      medicationStatus: identical(medicationStatus, _unset)
          ? this.medicationStatus
          : medicationStatus as String?,
      currentMedicationsOrSupplements:
          identical(currentMedicationsOrSupplements, _unset)
          ? this.currentMedicationsOrSupplements
          : currentMedicationsOrSupplements as String?,
      currentConcerns: currentConcerns ?? this.currentConcerns,
      otherConcern: identical(otherConcern, _unset)
          ? this.otherConcern
          : otherConcern as String?,
      periodRegularity: identical(periodRegularity, _unset)
          ? this.periodRegularity
          : periodRegularity as String?,
      averageCycleLengthDays: identical(averageCycleLengthDays, _unset)
          ? this.averageCycleLengthDays
          : averageCycleLengthDays as int?,
      recentSymptomChange: identical(recentSymptomChange, _unset)
          ? this.recentSymptomChange
          : recentSymptomChange as String?,
      labReportAvailability: identical(labReportAvailability, _unset)
          ? this.labReportAvailability
          : labReportAvailability as String?,
      labReports: labReports ?? this.labReports,
      primaryGoal: identical(primaryGoal, _unset)
          ? this.primaryGoal
          : primaryGoal as String?,
      earlyRiskAssessment: identical(earlyRiskAssessment, _unset)
          ? this.earlyRiskAssessment
          : earlyRiskAssessment as EarlyRiskAssessment?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static const Object _unset = Object();
}
