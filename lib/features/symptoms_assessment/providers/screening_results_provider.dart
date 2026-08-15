import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/saved_screening_result.dart';
import '../repositories/screening_results_repository.dart';

/// Exposes the [ScreeningResultsRepository] for the currently signed-in user.
///
/// The repository is re-created whenever the authenticated user changes, so
/// each user reads and writes their own persisted screening results.
final screeningResultsRepositoryProvider =
    Provider<ScreeningResultsRepository>((ref) {
  ref.watch(authNotifierProvider);
  return buildScreeningResultsRepository();
});

/// Reactive view of the latest saved screening results, keyed by assessment
/// type. Each assessment keeps its own independent latest result.
final screeningResultsProvider = StateNotifierProvider<ScreeningResultsNotifier,
    Map<ScreeningAssessmentType, SavedScreeningResult>>((ref) {
  return ScreeningResultsNotifier(ref);
});

class ScreeningResultsNotifier
    extends StateNotifier<Map<ScreeningAssessmentType, SavedScreeningResult>> {
  ScreeningResultsNotifier(this._ref) : super(const {}) {
    _sync();

    // Reload the user's results whenever the signed-in user changes
    // (login, logout, restore of a persisted session, etc.).
    _ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (previous?.user?.id != next.user?.id) {
        _sync();
      }
    });
  }

  final Ref _ref;

  Future<void>? _loadFuture;

  ScreeningResultsRepository get _repository =>
      _ref.read(screeningResultsRepositoryProvider);

  /// Fetches the latest persisted results for the current user.
  Future<void> _sync() async {
    final repository = _repository;
    final loadFuture = repository.load();
    _loadFuture = loadFuture;
    try {
      await loadFuture;
    } catch (e) {
      debugPrint('[screening_results] load FAILED: $e');
    }
    if (mounted) {
      state = Map.of(repository.allResults);
    }
  }

  /// Resolves once the latest results have been fetched at least once.
  Future<void> ensureLoaded() async {
    await _loadFuture;
  }

  /// Saves (or replaces) the latest result for its assessment type.
  Future<void> save(SavedScreeningResult result) async {
    final repository = _repository;
    try {
      await repository.save(result);
    } catch (e) {
      debugPrint('[screening_results] save FAILED: $e');
    }
    if (mounted) {
      state = Map.of(repository.allResults);
    }
  }

  SavedScreeningResult? latest(ScreeningAssessmentType type) {
    return _repository.latestResult(type);
  }
}
