import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/saved_screening_result.dart';
import '../repositories/screening_results_repository.dart';

/// Exposes the [ScreeningResultsRepository] used across the app.
///
/// Swap this provider's implementation to connect the results to a backend
/// later without changing the assessment UI or scoring logic.
final screeningResultsRepositoryProvider =
    Provider<ScreeningResultsRepository>((ref) {
  return LocalScreeningResultsRepository();
});

/// Reactive view of all saved screening results, keyed by assessment type.
final screeningResultsProvider = StateNotifierProvider<ScreeningResultsNotifier,
    Map<ScreeningAssessmentType, SavedScreeningResult>>((ref) {
  return ScreeningResultsNotifier(ref.read(screeningResultsRepositoryProvider));
});

class ScreeningResultsNotifier
    extends StateNotifier<Map<ScreeningAssessmentType, SavedScreeningResult>> {
  ScreeningResultsNotifier(this._repository) : super(_repository.allResults);

  final ScreeningResultsRepository _repository;

  /// Saves or replaces the latest result for its assessment type.
  void save(SavedScreeningResult result) {
    _repository.save(result);
    state = Map.of(_repository.allResults);
  }

  SavedScreeningResult? latest(ScreeningAssessmentType type) {
    return _repository.latestResult(type);
  }
}
