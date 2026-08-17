import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/backend.dart';
import '../../../models/cycle_data.dart';
import '../../../models/period_record.dart';
import '../../../models/symptom_log.dart';
import '../../../models/user_profile.dart';
import '../../cycle/services/cycle_calculation_service.dart';
import '../../symptoms_assessment/models/saved_screening_result.dart';
import '../models/patient_health_summary.dart';

/// Aggregates a patient's real, existing SYNCO health data into a
/// [PatientHealthSummary] for the doctor-facing clinical overview.
///
/// Authorization: the summary can only be fetched by the doctor attached to
/// the appointment, for the exact patient on that appointment. This mirrors
/// the existing appointment/authorization rules - the same way the doctor's
/// appointment streams only contain their own bookings.
///
/// All data comes from the existing Firestore collections the patient-side
/// features already use (daily_logs period records, symptom_logs, screening
/// results, profile concerns and lab reports). No separate health-data system
/// is created, and missing data is returned as empty/null so the UI can show
/// empty states instead of fabricating information.
class DoctorHealthSummaryService {
  final FirebaseFirestore _db;
  final CycleCalculationService _cycleService;

  DoctorHealthSummaryService({
    FirebaseFirestore? firestore,
    CycleCalculationService? cycleService,
  })  : _db = firestore ?? Backend.firestore ?? FirebaseFirestore.instance,
        _cycleService = cycleService ?? CycleCalculationService();

  /// Base health score, matching the patient dashboard's existing
  /// calculation (see HealthScoreNotifier in dashboard_provider.dart).
  static const int _baseHealthScore = 85;

  /// Fetches the health summary for [userId] attached to [appointmentId].
  ///
  /// Returns `null` when the requesting doctor is not attached to the
  /// appointment (or the appointment does not exist), so no patient data is
  /// ever exposed to unauthorized callers.
  Future<PatientHealthSummary?> fetch({
    required String appointmentId,
    required String userId,
    required String doctorId,
  }) async {
    if (appointmentId.isEmpty || userId.isEmpty || doctorId.isEmpty) {
      return null;
    }

    // Authorization gate: the booking must exist and belong to exactly this
    // doctor and this patient before any patient data is read.
    final booking =
        await _db.collection('bookings').doc(appointmentId).get();
    if (!booking.exists) return null;
    final bookingData = booking.data() ?? {};
    if (bookingData['doctorId'] != doctorId ||
        bookingData['userId'] != userId) {
      return null;
    }

    final profileDoc = await _db.collection('users').doc(userId).get();
    final profile =
        profileDoc.exists ? UserProfile.fromMap(profileDoc.data()!) : null;

    final cycleInsights = await _loadCycleInsights(userId);
    final healthScore = await _loadHealthScore(userId);
    final screenings = await _loadScreenings(userId);

    final concern = _patientConcern(bookingData, profile);

    return PatientHealthSummary(
      authorized: true,
      patientName: profile?.username ?? bookingData['patientName'] ?? '',
      hasCycleHistory: cycleInsights.hasHistory,
      averageCycleLength: cycleInsights.averageCycleLength,
      averagePeriodDuration: cycleInsights.averagePeriodDuration,
      currentPhaseLabel: cycleInsights.currentPhase.displayName,
      lastPeriodStartLabel: cycleInsights.lastPeriodStartDate == null
          ? null
          : CycleCalculationService.shortDate(
              cycleInsights.lastPeriodStartDate!,
            ),
      recentSymptoms: _recentSymptoms(cycleInsights),
      screeningIndicators: _screeningIndicators(screenings),
      healthScore: healthScore,
      reports: _labReports(profile),
      concern: concern,
      recentSymptomChange: profile?.recentSymptomChange,
    );
  }

  // -------------------------------------------------------------------------
  // Cycle
  // -------------------------------------------------------------------------

  /// Loads the patient's period records from their existing daily_logs and
  /// runs the same centralized cycle calculation the patient dashboard uses.
  Future<CycleInsights> _loadCycleInsights(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('daily_logs')
          .orderBy('date', descending: true)
          .get();

      final records = <PeriodRecord>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final periodMap = data['period_logs'];
        if (periodMap is! Map) continue;
        periodMap.forEach((key, value) {
          if (value is Map) {
            records.add(PeriodRecord.fromMap({
              'id': '${doc.id}|$key',
              ...Map<String, dynamic>.from(value),
            }));
          }
        });
      }
      records.sort((a, b) => b.startDate.compareTo(a.startDate));
      return _cycleService.computeInsights(records);
    } catch (e) {
      debugPrint('[doctor_health_summary] cycle load failed: $e');
      return _cycleService.computeInsights(const []);
    }
  }

  /// Most recent unique symptoms logged across the patient's period records.
  static List<String> _recentSymptoms(CycleInsights insights) {
    final seen = <String>{};
    final result = <String>[];
    for (final log in insights.dailySymptomLogs) {
      for (final symptom in log.symptoms) {
        final cleaned = symptom.trim();
        if (cleaned.isEmpty || !seen.add(cleaned)) continue;
        result.add(cleaned);
        if (result.length >= 6) return result;
      }
    }
    return result;
  }

  // -------------------------------------------------------------------------
  // Health score
  // -------------------------------------------------------------------------

  /// Computes the patient's health score from their symptom_logs using the
  /// exact same rules as the existing patient dashboard (base 85, deductions
  /// for severe/high and moderate symptoms in the last 7 days).
  Future<int?> _loadHealthScore(String userId) async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('symptom_logs')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .get();

      if (snapshot.docs.isEmpty) return null;

      var score = _baseHealthScore;
      for (final doc in snapshot.docs) {
        final log = SymptomLog.fromMap(doc.id, doc.data());
        log.symptoms.forEach((key, value) {
          final severity = value.toString().toLowerCase();
          if (severity == 'severe' || severity == 'high') {
            score -= 2;
          } else if (severity == 'moderate') {
            score -= 1;
          }
        });
      }
      return score.clamp(0, 100);
    } catch (e) {
      debugPrint('[doctor_health_summary] health score load failed: $e');
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Screening indicators
  // -------------------------------------------------------------------------

  Future<List<SavedScreeningResult>> _loadScreenings(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('screening_results')
          .get();
      final results = <SavedScreeningResult>[];
      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        data['user_id'] = userId;
        final result = SavedScreeningResult.fromJson(data);
        if (result.isCompleted) results.add(result);
      }
      return results;
    } catch (e) {
      debugPrint('[doctor_health_summary] screening load failed: $e');
      return const [];
    }
  }

  static List<PatientScreeningIndicator> _screeningIndicators(
    List<SavedScreeningResult> results,
  ) {
    const names = {
      ScreeningAssessmentType.pcos: 'PCOS',
      ScreeningAssessmentType.endometriosis: 'Endometriosis',
      ScreeningAssessmentType.uterineFibroids: 'Fibroids',
    };
    return results.map((result) {
      final name = names[result.assessmentType] ?? result.categoryTitle;
      return PatientScreeningIndicator(
        name: name.isEmpty ? result.assessmentType.name : name,
        levelLabel: result.levelLabel,
      );
    }).toList();
  }

  // -------------------------------------------------------------------------
  // Reports
  // -------------------------------------------------------------------------

  static List<PatientReport> _labReports(UserProfile? profile) {
    if (profile == null) return const [];
    return profile.labReports
        .map((report) => PatientReport(
              name: report['name']?.toString() ?? 'Report',
              uploadedAt: report['uploaded_at']?.toString(),
            ))
        .toList();
  }

  // -------------------------------------------------------------------------
  // Concern
  // -------------------------------------------------------------------------

  /// The patient's entered concern: the reason given on the appointment
  /// booking, falling back to the patient's profile concerns. The concern is
  /// displayed as-is and never re-interpreted into a medical conclusion.
  static String? _patientConcern(
    Map<String, dynamic> bookingData,
    UserProfile? profile,
  ) {
    final bookingIssue = bookingData['issue']?.toString().trim() ??
        bookingData['reason']?.toString().trim() ??
        bookingData['reasonForConsultation']?.toString().trim();
    if (bookingIssue != null && bookingIssue.isNotEmpty) {
      return bookingIssue;
    }

    if (profile != null) {
      final other = profile.otherConcern?.trim();
      if (other != null && other.isNotEmpty) return other;
      for (final concern in profile.currentConcerns) {
        final trimmed = concern.trim();
        if (trimmed.isNotEmpty) return trimmed;
      }
    }
    return null;
  }
}
