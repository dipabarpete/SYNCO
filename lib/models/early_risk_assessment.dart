/// Early Risk Assessment answers collected during onboarding for users who
/// have not been formally diagnosed with PCOS/PCOD.
///
/// These responses are contextual pattern information only. They are not a
/// diagnosis and must never be presented as one.
class EarlyRiskAssessment {
  final String? ageRange;
  final double? heightCm;
  final double? weightKg;
  final double? bmi;
  final String? periodRegularity;
  final String? typicalCycleLength;
  final String? periodGap90Days;
  final String? periodChangeHistory;
  final String? facialBodyHairGrowth;
  final String? acneSeverity;
  final String? scalpHairThinning;
  final String? recentWeightChange;
  final List<String> familyConditions;
  final List<String> diagnosedMetabolicConditions;
  final String? physicalActivity;
  final String? sleepDuration;
  final int? stressLevel;
  final String? pregnancyStatus;
  final List<String> reproductiveContext;
  final String? menstrualAffectingCondition;
  final String? menstrualAffectingConditionDetails;

  const EarlyRiskAssessment({
    this.ageRange,
    this.heightCm,
    this.weightKg,
    this.bmi,
    this.periodRegularity,
    this.typicalCycleLength,
    this.periodGap90Days,
    this.periodChangeHistory,
    this.facialBodyHairGrowth,
    this.acneSeverity,
    this.scalpHairThinning,
    this.recentWeightChange,
    this.familyConditions = const [],
    this.diagnosedMetabolicConditions = const [],
    this.physicalActivity,
    this.sleepDuration,
    this.stressLevel,
    this.pregnancyStatus,
    this.reproductiveContext = const [],
    this.menstrualAffectingCondition,
    this.menstrualAffectingConditionDetails,
  });

  factory EarlyRiskAssessment.fromMap(Map<String, dynamic> map) {
    return EarlyRiskAssessment(
      ageRange: map['age_range']?.toString(),
      heightCm: map['height_cm'] != null
          ? double.tryParse(map['height_cm'].toString())
          : null,
      weightKg: map['weight_kg'] != null
          ? double.tryParse(map['weight_kg'].toString())
          : null,
      bmi: map['bmi'] != null ? double.tryParse(map['bmi'].toString()) : null,
      periodRegularity: map['period_regularity']?.toString(),
      typicalCycleLength: map['typical_cycle_length']?.toString(),
      periodGap90Days: map['period_gap_90_days']?.toString(),
      periodChangeHistory: map['period_change_history']?.toString(),
      facialBodyHairGrowth: map['facial_body_hair_growth']?.toString(),
      acneSeverity: map['acne_severity']?.toString(),
      scalpHairThinning: map['scalp_hair_thinning']?.toString(),
      recentWeightChange: map['recent_weight_change']?.toString(),
      familyConditions:
          (map['family_conditions'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      diagnosedMetabolicConditions:
          (map['diagnosed_metabolic_conditions'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      physicalActivity: map['physical_activity']?.toString(),
      sleepDuration: map['sleep_duration']?.toString(),
      stressLevel: map['stress_level'] == null
          ? null
          : int.tryParse(map['stress_level'].toString()),
      pregnancyStatus: map['pregnancy_status']?.toString(),
      reproductiveContext:
          (map['reproductive_context'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      menstrualAffectingCondition: map['menstrual_affecting_condition']
          ?.toString(),
      menstrualAffectingConditionDetails:
          map['menstrual_affecting_condition_details']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'age_range': ageRange,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'bmi': bmi,
      'period_regularity': periodRegularity,
      'typical_cycle_length': typicalCycleLength,
      'period_gap_90_days': periodGap90Days,
      'period_change_history': periodChangeHistory,
      'facial_body_hair_growth': facialBodyHairGrowth,
      'acne_severity': acneSeverity,
      'scalp_hair_thinning': scalpHairThinning,
      'recent_weight_change': recentWeightChange,
      'family_conditions': familyConditions,
      'diagnosed_metabolic_conditions': diagnosedMetabolicConditions,
      'physical_activity': physicalActivity,
      'sleep_duration': sleepDuration,
      'stress_level': stressLevel,
      'pregnancy_status': pregnancyStatus,
      'reproductive_context': reproductiveContext,
      'menstrual_affecting_condition': menstrualAffectingCondition,
      'menstrual_affecting_condition_details':
          menstrualAffectingConditionDetails,
    };
  }

  EarlyRiskAssessment copyWith({
    Object? ageRange = _unset,
    Object? heightCm = _unset,
    Object? weightKg = _unset,
    Object? bmi = _unset,
    Object? periodRegularity = _unset,
    Object? typicalCycleLength = _unset,
    Object? periodGap90Days = _unset,
    Object? periodChangeHistory = _unset,
    Object? facialBodyHairGrowth = _unset,
    Object? acneSeverity = _unset,
    Object? scalpHairThinning = _unset,
    Object? recentWeightChange = _unset,
    List<String>? familyConditions,
    List<String>? diagnosedMetabolicConditions,
    Object? physicalActivity = _unset,
    Object? sleepDuration = _unset,
    Object? stressLevel = _unset,
    Object? pregnancyStatus = _unset,
    List<String>? reproductiveContext,
    Object? menstrualAffectingCondition = _unset,
    Object? menstrualAffectingConditionDetails = _unset,
  }) {
    return EarlyRiskAssessment(
      ageRange: identical(ageRange, _unset)
          ? this.ageRange
          : ageRange as String?,
      heightCm: identical(heightCm, _unset)
          ? this.heightCm
          : heightCm as double?,
      weightKg: identical(weightKg, _unset)
          ? this.weightKg
          : weightKg as double?,
      bmi: identical(bmi, _unset) ? this.bmi : bmi as double?,
      periodRegularity: identical(periodRegularity, _unset)
          ? this.periodRegularity
          : periodRegularity as String?,
      typicalCycleLength: identical(typicalCycleLength, _unset)
          ? this.typicalCycleLength
          : typicalCycleLength as String?,
      periodGap90Days: identical(periodGap90Days, _unset)
          ? this.periodGap90Days
          : periodGap90Days as String?,
      periodChangeHistory: identical(periodChangeHistory, _unset)
          ? this.periodChangeHistory
          : periodChangeHistory as String?,
      facialBodyHairGrowth: identical(facialBodyHairGrowth, _unset)
          ? this.facialBodyHairGrowth
          : facialBodyHairGrowth as String?,
      acneSeverity: identical(acneSeverity, _unset)
          ? this.acneSeverity
          : acneSeverity as String?,
      scalpHairThinning: identical(scalpHairThinning, _unset)
          ? this.scalpHairThinning
          : scalpHairThinning as String?,
      recentWeightChange: identical(recentWeightChange, _unset)
          ? this.recentWeightChange
          : recentWeightChange as String?,
      familyConditions: familyConditions ?? this.familyConditions,
      diagnosedMetabolicConditions:
          diagnosedMetabolicConditions ?? this.diagnosedMetabolicConditions,
      physicalActivity: identical(physicalActivity, _unset)
          ? this.physicalActivity
          : physicalActivity as String?,
      sleepDuration: identical(sleepDuration, _unset)
          ? this.sleepDuration
          : sleepDuration as String?,
      stressLevel: identical(stressLevel, _unset)
          ? this.stressLevel
          : stressLevel as int?,
      pregnancyStatus: identical(pregnancyStatus, _unset)
          ? this.pregnancyStatus
          : pregnancyStatus as String?,
      reproductiveContext: reproductiveContext ?? this.reproductiveContext,
      menstrualAffectingCondition:
          identical(menstrualAffectingCondition, _unset)
          ? this.menstrualAffectingCondition
          : menstrualAffectingCondition as String?,
      menstrualAffectingConditionDetails:
          identical(menstrualAffectingConditionDetails, _unset)
          ? this.menstrualAffectingConditionDetails
          : menstrualAffectingConditionDetails as String?,
    );
  }

  static const Object _unset = Object();
}
