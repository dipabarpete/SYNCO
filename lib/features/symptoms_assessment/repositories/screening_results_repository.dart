import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/backend.dart';
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
  Future<void> save(SavedScreeningResult result);

  /// Fetches the latest results from the backend into memory.
  Future<void> load();
}

/// In-memory implementation of [ScreeningResultsRepository].
///
/// Stores at most one "latest" result per assessment type; saving again for
/// the same type replaces the previous entry. Used as a fallback when no
/// authenticated user or backend is available (e.g. widget tests).
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
  Future<void> save(SavedScreeningResult result) async {
    _results[result.assessmentType] = result;
  }

  @override
  Future<void> load() async {
    // Nothing to fetch; results live in memory only.
  }
}

/// Firestore-backed implementation of [ScreeningResultsRepository].
///
/// Each authenticated user owns one document per assessment type under
/// `users/{userId}/screening_results/{assessmentType}`. Saving again for the
/// same type overwrites that document with the newest completed result, so
/// the user always sees their latest attempt while older history (if any
/// were stored separately) remains untouched.
class FirebaseScreeningResultsRepository
    implements ScreeningResultsRepository {
  FirebaseScreeningResultsRepository({
    required this._firestore,
    required this._userId,
  });

  final FirebaseFirestore _firestore;
  final String _userId;

  final Map<ScreeningAssessmentType, SavedScreeningResult> _results = {};

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore
          .collection('users')
          .doc(_userId)
          .collection('screening_results');

  @override
  SavedScreeningResult? latestResult(ScreeningAssessmentType type) {
    return _results[type];
  }

  @override
  Map<ScreeningAssessmentType, SavedScreeningResult> get allResults =>
      Map.unmodifiable(_results);

  @override
  Future<void> save(SavedScreeningResult result) async {
    final payload = result.toJson();
    payload['user_id'] = _userId;

    // Reflect the result in memory immediately so the UI updates even if
    // the network write is slow or fails.
    _results[result.assessmentType] =
        SavedScreeningResult.fromJson(payload);

    try {
      await _collection
          .doc(result.assessmentType.name)
          .set(payload, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[screening_results] save FAILED: $e');
      rethrow;
    }
  }

  @override
  Future<void> load() async {
    final snapshot = await _collection.get();
    for (final doc in snapshot.docs) {
      final data = Map<String, dynamic>.from(doc.data());
      data['user_id'] = _userId;
      final result = SavedScreeningResult.fromJson(data);
      if (result.isCompleted) {
        _results[result.assessmentType] = result;
      }
    }
  }
}

/// Builds the repository for the currently signed-in user.
///
/// Falls back to an in-memory repository when the user is not signed in or
/// the Firebase client is unavailable, so the assessment flow keeps working
/// everywhere (including tests).
ScreeningResultsRepository buildScreeningResultsRepository() {
  final firestore = Backend.firestore;
  final uid = Backend.auth?.currentUser?.uid;
  if (firestore != null && uid != null) {
    return FirebaseScreeningResultsRepository(
      firestore: firestore,
      userId: uid,
    );
  }
  return LocalScreeningResultsRepository();
}
