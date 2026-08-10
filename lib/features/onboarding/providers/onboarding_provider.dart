import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/early_risk_assessment.dart';
import '../../../models/user_profile.dart';
import '../../auth/providers/auth_provider.dart';

class OnboardingState {
  final UserRole selectedRole;
  final String userName;
  final PcosDiagnosisStatus? diagnosisStatus;
  final String? diagnosedBy;
  final String? diagnosisTimeframe;
  final String? medicationStatus;
  final String? medicationDetails;
  final List<String> currentConcerns;
  final String? otherConcern;
  final String? periodRegularity;
  final int? averageCycleLengthDays;
  final String? recentSymptomChange;
  final String? labReportAvailability;
  final List<Map<String, dynamic>> labReports;
  final String? primaryGoal;
  final String? ageRange;
  final double? heightCm;
  final double? weightKg;
  final double? bmi;
  final String? periodRegularityRisk;
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
  final bool isUploadingLabReport;
  final bool isSubmitting;
  final String? errorMessage;

  const OnboardingState({
    this.selectedRole = UserRole.user,
    this.userName = '',
    this.diagnosisStatus,
    this.diagnosedBy,
    this.diagnosisTimeframe,
    this.medicationStatus,
    this.medicationDetails,
    this.currentConcerns = const [],
    this.otherConcern,
    this.periodRegularity,
    this.averageCycleLengthDays,
    this.recentSymptomChange,
    this.labReportAvailability,
    this.labReports = const [],
    this.primaryGoal,
    this.ageRange,
    this.heightCm,
    this.weightKg,
    this.bmi,
    this.periodRegularityRisk,
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
    this.isUploadingLabReport = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  OnboardingState copyWith({
    UserRole? selectedRole,
    String? userName,
    PcosDiagnosisStatus? diagnosisStatus,
    Object? diagnosedBy = _unset,
    Object? diagnosisTimeframe = _unset,
    Object? medicationStatus = _unset,
    Object? medicationDetails = _unset,
    List<String>? currentConcerns,
    Object? otherConcern = _unset,
    Object? periodRegularity = _unset,
    Object? averageCycleLengthDays = _unset,
    Object? recentSymptomChange = _unset,
    Object? labReportAvailability = _unset,
    List<Map<String, dynamic>>? labReports,
    Object? primaryGoal = _unset,
    Object? ageRange = _unset,
    Object? heightCm = _unset,
    Object? weightKg = _unset,
    Object? bmi = _unset,
    Object? periodRegularityRisk = _unset,
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
    bool? isUploadingLabReport,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return OnboardingState(
      selectedRole: selectedRole ?? this.selectedRole,
      userName: userName ?? this.userName,
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
      medicationDetails: identical(medicationDetails, _unset)
          ? this.medicationDetails
          : medicationDetails as String?,
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
      periodRegularityRisk: identical(periodRegularityRisk, _unset)
          ? this.periodRegularityRisk
          : periodRegularityRisk as String?,
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
      isUploadingLabReport: isUploadingLabReport ?? this.isUploadingLabReport,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  static const Object _unset = Object();
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      return OnboardingNotifier(ref);
    });

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;

  OnboardingNotifier(this._ref) : super(const OnboardingState());

  void setRole(UserRole role) {
    state = state.copyWith(selectedRole: role);
  }

  void setName(String name) {
    state = state.copyWith(userName: name.trim());
  }

  void setDiagnosisStatus(PcosDiagnosisStatus status) {
    state = state.copyWith(diagnosisStatus: status);
  }

  void setDiagnosedBy(String value) =>
      state = state.copyWith(diagnosedBy: value);

  void setDiagnosisTimeframe(String value) =>
      state = state.copyWith(diagnosisTimeframe: value);

  void setMedicationStatus(String value) {
    state = state.copyWith(
      medicationStatus: value,
      medicationDetails: value == 'yes' ? state.medicationDetails : null,
    );
  }

  void setMedicationDetails(String value) => state = state.copyWith(
    medicationDetails: value.trim().isEmpty ? null : value.trim(),
  );

  void toggleConcern(String concern) {
    final concerns = {...state.currentConcerns};
    if (concern == 'None') {
      state = state.copyWith(
        currentConcerns: concerns.contains('None') ? const [] : const ['None'],
        otherConcern: null,
      );
      return;
    }

    concerns.remove('None');
    if (!concerns.add(concern)) concerns.remove(concern);
    state = state.copyWith(
      currentConcerns: concerns.toList(),
      otherConcern: concerns.contains('Other') ? state.otherConcern : null,
    );
  }

  void setOtherConcern(String value) => state = state.copyWith(
    otherConcern: value.trim().isEmpty ? null : value.trim(),
  );

  void setPeriodRegularity(String value) => state = state.copyWith(
    periodRegularity: value,
    averageCycleLengthDays:
        (value == "I don't get periods currently" ||
            value == 'no_periods_currently')
        ? null
        : state.averageCycleLengthDays,
  );

  void setAverageCycleLengthDays(String value) {
    final days = int.tryParse(value.trim());
    state = state.copyWith(
      averageCycleLengthDays: days != null && days >= 1 && days <= 365
          ? days
          : null,
    );
  }

  void setRecentSymptomChange(String value) =>
      state = state.copyWith(recentSymptomChange: value);

  void setLabReportAvailability(String value) => state = state.copyWith(
    labReportAvailability: value,
    labReports: value == 'yes' ? state.labReports : const [],
  );

  void addLabReport(Map<String, dynamic> report) =>
      state = state.copyWith(labReports: [...state.labReports, report]);

  void removeLabReport(String path) => state = state.copyWith(
    labReports: state.labReports
        .where((report) => report['path'] != path)
        .toList(),
  );

  void setLabReportUploading(bool value) =>
      state = state.copyWith(isUploadingLabReport: value);

  void setPrimaryGoal(String value) =>
      state = state.copyWith(primaryGoal: value);

  // ------ Early Risk Assessment (non-diagnosed branch) ------

  void setAgeRange(String value) => state = state.copyWith(ageRange: value);

  void setHeightCm(String value) {
    final height = double.tryParse(value.trim());
    state = state.copyWith(
      heightCm: height != null && height >= 100 && height <= 250
          ? height
          : null,
    );
    _recomputeBmi();
  }

  void setWeightKg(String value) {
    final weight = double.tryParse(value.trim());
    state = state.copyWith(
      weightKg: weight != null && weight >= 30 && weight <= 300 ? weight : null,
    );
    _recomputeBmi();
  }

  /// BMI is computed internally as contextual information only. It is not a
  /// diagnostic criterion and must never be presented as one.
  void _recomputeBmi() {
    final height = state.heightCm;
    final weight = state.weightKg;
    if (height == null || weight == null || height <= 0) {
      if (state.bmi != null) state = state.copyWith(bmi: null);
      return;
    }
    final heightMeters = height / 100.0;
    final bmi = weight / (heightMeters * heightMeters);
    state = state.copyWith(bmi: double.parse(bmi.toStringAsFixed(1)));
  }

  void setPeriodRegularityRisk(String value) =>
      state = state.copyWith(periodRegularityRisk: value);

  void setTypicalCycleLength(String value) =>
      state = state.copyWith(typicalCycleLength: value);

  void setPeriodGap90Days(String value) =>
      state = state.copyWith(periodGap90Days: value);

  void setPeriodChangeHistory(String value) =>
      state = state.copyWith(periodChangeHistory: value);

  void setFacialBodyHairGrowth(String value) =>
      state = state.copyWith(facialBodyHairGrowth: value);

  void setAcneSeverity(String value) =>
      state = state.copyWith(acneSeverity: value);

  void setScalpHairThinning(String value) =>
      state = state.copyWith(scalpHairThinning: value);

  void setRecentWeightChange(String value) =>
      state = state.copyWith(recentWeightChange: value);

  /// Toggles a value in a multi-select list. Exclusive options ('None' etc.)
  /// clear every other selection; selecting a specific value clears the
  /// exclusive options. Contradictory states are never stored.
  List<String> _toggleExclusiveSelection(
    List<String> current,
    String value,
    List<String> exclusiveOptions,
  ) {
    final isExclusive = exclusiveOptions.contains(value);
    if (isExclusive) {
      if (current.length == 1 && current.first == value) return const [];
      return [value];
    }
    final next = {...current}..removeAll(exclusiveOptions);
    if (!next.add(value)) next.remove(value);
    return next.toList();
  }

  void toggleFamilyCondition(String value) => state = state.copyWith(
    familyConditions: _toggleExclusiveSelection(
      state.familyConditions,
      value,
      const ['None', "Don't know"],
    ),
  );

  void toggleMetabolicCondition(String value) => state = state.copyWith(
    diagnosedMetabolicConditions: _toggleExclusiveSelection(
      state.diagnosedMetabolicConditions,
      value,
      const ['None', "Don't know"],
    ),
  );

  void toggleReproductiveContext(String value) => state = state.copyWith(
    reproductiveContext: _toggleExclusiveSelection(
      state.reproductiveContext,
      value,
      const ['None of these', 'Not sure'],
    ),
  );

  void setPhysicalActivity(String value) =>
      state = state.copyWith(physicalActivity: value);

  void setSleepDuration(String value) =>
      state = state.copyWith(sleepDuration: value);

  void setStressLevel(int value) {
    if (value >= 1 && value <= 5) {
      state = state.copyWith(stressLevel: value);
    }
  }

  void setPregnancyStatus(String value) =>
      state = state.copyWith(pregnancyStatus: value);

  void setMenstrualAffectingCondition(String value) =>
      state = state.copyWith(menstrualAffectingCondition: value);

  void setMenstrualAffectingConditionDetails(String value) =>
      state = state.copyWith(
        menstrualAffectingConditionDetails: value.trim().isEmpty
            ? null
            : value.trim(),
      );

  /// Finalize onboarding state and update the active user profile
  Future<bool> completeOnboarding() async {
    state = state.copyWith(isSubmitting: true);
    try {
      final authNotifier = _ref.read(authNotifierProvider.notifier);
      final currentAuthState = _ref.read(authNotifierProvider);

      final currentProfile =
          currentAuthState.userProfile ??
          UserProfile(
            id: currentAuthState.user?.id ?? 'usr_local',
            username: state.userName.isNotEmpty ? state.userName : 'Synco User',
            avatarUrl: '',
          );

      final updatedProfile = currentProfile.copyWith(
        username: state.userName.isNotEmpty
            ? state.userName
            : currentProfile.username,
        role: state.selectedRole,
        diagnosisStatus:
            state.diagnosisStatus ?? PcosDiagnosisStatus.preferNotToSay,
        diagnosedBy: state.diagnosedBy,
        diagnosisTimeframe: state.diagnosisTimeframe,
        medicationStatus: state.medicationStatus,
        currentMedicationsOrSupplements: state.medicationStatus == 'yes'
            ? state.medicationDetails
            : null,
        currentConcerns: state.currentConcerns,
        otherConcern: state.currentConcerns.contains('Other')
            ? state.otherConcern
            : null,
        periodRegularity: state.periodRegularity,
        averageCycleLengthDays:
            (state.periodRegularity == "I don't get periods currently" ||
                state.periodRegularity == 'no_periods_currently')
            ? null
            : state.averageCycleLengthDays,
        recentSymptomChange: state.recentSymptomChange,
        labReportAvailability: state.labReportAvailability,
        labReports: state.labReportAvailability == 'yes'
            ? state.labReports
            : const [],
        primaryGoal: state.primaryGoal,
        earlyRiskAssessment:
            state.diagnosisStatus != PcosDiagnosisStatus.diagnosed
            ? EarlyRiskAssessment(
                ageRange: state.ageRange,
                heightCm: state.heightCm,
                weightKg: state.weightKg,
                bmi: state.bmi,
                periodRegularity: state.periodRegularityRisk,
                typicalCycleLength: state.typicalCycleLength,
                periodGap90Days: state.periodGap90Days,
                periodChangeHistory: state.periodChangeHistory,
                facialBodyHairGrowth: state.facialBodyHairGrowth,
                acneSeverity: state.acneSeverity,
                scalpHairThinning: state.scalpHairThinning,
                recentWeightChange: state.recentWeightChange,
                familyConditions: state.familyConditions,
                diagnosedMetabolicConditions:
                    state.diagnosedMetabolicConditions,
                physicalActivity: state.physicalActivity,
                sleepDuration: state.sleepDuration,
                stressLevel: state.stressLevel,
                pregnancyStatus: state.pregnancyStatus,
                reproductiveContext: state.reproductiveContext,
                menstrualAffectingCondition: state.menstrualAffectingCondition,
                menstrualAffectingConditionDetails:
                    state.menstrualAffectingConditionDetails,
              )
            : null,
        onboardingCompleted: true,
      );

      // Update in Riverpod AuthNotifier
      final saved = await authNotifier.updateLocalProfile(updatedProfile);
      if (!saved) {
        throw Exception('Could not save onboarding details.');
      }

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to save onboarding details. Please try again.',
      );
      return false;
    }
  }

  void reset() {
    state = const OnboardingState();
  }
}
