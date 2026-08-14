import '../models/saved_screening_result.dart';

/// Storage contract for completed symptom screening results.
///
/// The assessment UI and scoring logic only depend on this abstraction, so a
/// backend-backed implementation can replace the local one later without
/// rewriting the assessment flow.
abstract class ScreeningResultsRepository {
  /// Returns the latest saved result for [type], or null if none yet.
  SavedScreeningResult? latestResult(ScreeningAssessmentType type);

  /// All saved results, keyed by assessment type.
  Map<ScreeningAssessmentType, SavedScreeningResult> get allResults;

  /// Saves (or replaces) the latest result for the assessment type.
  void save(SavedScreeningResult result);
}

/// In-memory implementation of [ScreeningResultsRepository].
///
/// Stores at most one "latest" result per assessment type; saving again for
/// the same type replaces the previous entry.
class LocalScreeningResultsRepository implements ScreeningResultsRepository {
  final Map<ScreeningAssessmentType, SavedScreeningResult> _results = {};

  @override
  SavedScreeningResult? latestResult(ScreeningAssessmentType type) {
    return _results[type];
  }

  @override
  Map<ScreeningAssessmentType, SavedScreeningResult> get allResults =>
      Map.unmodifiable(_results);

  @override
  void save(SavedScreeningResult result) {
    _results[result.assessmentType] = result;
  }
}
