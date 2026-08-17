/// Doctor-facing clinical snapshot of a patient's stored SYNCO health data.
///
/// Built from the patient's real existing data (period/cycle history,
/// symptoms, screening results, health score, uploaded reports and concerns)
/// by [DoctorHealthSummaryService]. Every field is `null`/empty when the
/// patient has no data for that section - the UI shows empty states instead
/// of inventing information.
class PatientHealthSummary {
  /// Whether the requesting doctor is authorized to view this summary
  /// (the appointment must belong to them and to this patient).
  final bool authorized;

  final String patientName;

  // --- Cycle ---------------------------------------------------------------
  final bool hasCycleHistory;
  final int averageCycleLength;
  final int averagePeriodDuration;
  final String? currentPhaseLabel;
  final String? lastPeriodStartLabel;

  // --- Recent symptoms ------------------------------------------------------
  final List<String> recentSymptoms;

  // --- Screening indicators -------------------------------------------------
  final List<PatientScreeningIndicator> screeningIndicators;

  // --- Health score ---------------------------------------------------------
  final int? healthScore;

  // --- Reports --------------------------------------------------------------
  final List<PatientReport> reports;

  // --- Patient's concern ----------------------------------------------------
  final String? concern;
  final String? recentSymptomChange;

  const PatientHealthSummary({
    required this.authorized,
    this.patientName = '',
    this.hasCycleHistory = false,
    this.averageCycleLength = 28,
    this.averagePeriodDuration = 5,
    this.currentPhaseLabel,
    this.lastPeriodStartLabel,
    this.recentSymptoms = const [],
    this.screeningIndicators = const [],
    this.healthScore,
    this.reports = const [],
    this.concern,
    this.recentSymptomChange,
  });

  bool get hasNoData =>
      !hasCycleHistory &&
      recentSymptoms.isEmpty &&
      screeningIndicators.isEmpty &&
      healthScore == null &&
      reports.isEmpty &&
      concern == null;
}

/// One screening/assessment indicator (e.g. PCOS - Moderate indicators).
///
/// Presented as an indicator only - never as a diagnosis.
class PatientScreeningIndicator {
  final String name;
  final String levelLabel;

  const PatientScreeningIndicator({
    required this.name,
    required this.levelLabel,
  });
}

/// One uploaded lab report from the patient's profile.
class PatientReport {
  final String name;
  final String? uploadedAt;

  const PatientReport({
    required this.name,
    this.uploadedAt,
  });
}
