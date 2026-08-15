import 'endometriosis_assessment_result.dart';
import 'endometriosis_result_level.dart';
import 'fibroids_assessment_result.dart';
import 'fibroids_result_level.dart';
import 'pcos_assessment_result.dart';
import 'pcos_result_level.dart';

/// The three symptom screening assessments available in the app.
enum ScreeningAssessmentType {
  pcos,
  endometriosis,
  uterineFibroids,
}

/// A stored record of the latest completed screening result.
///
/// This is intentionally decoupled from the assessment result models so the
/// storage layer can later be swapped for a backend without touching the
/// assessment UI or scoring logic.
class SavedScreeningResult {
  final ScreeningAssessmentType assessmentType;
  final String categoryTitle;
  final String levelLabel;
  final int rawScore;
  final bool isCompleted;
  final DateTime completedAt;

  /// The authenticated user the result belongs to.
  ///
  /// Populated by the backend storage layer; empty when not yet persisted.
  final String userId;

  const SavedScreeningResult({
    required this.assessmentType,
    required this.categoryTitle,
    required this.levelLabel,
    required this.rawScore,
    required this.isCompleted,
    required this.completedAt,
    this.userId = '',
  });

  factory SavedScreeningResult.fromPcos(PcosAssessmentResult result) {
    return SavedScreeningResult(
      assessmentType: ScreeningAssessmentType.pcos,
      categoryTitle: result.categoryTitle,
      levelLabel: result.resultLevel.levelBadgeText,
      rawScore: result.rawScore,
      isCompleted: true,
      completedAt: result.completedAt,
    );
  }

  factory SavedScreeningResult.fromEndometriosis(
      EndometriosisAssessmentResult result) {
    return SavedScreeningResult(
      assessmentType: ScreeningAssessmentType.endometriosis,
      categoryTitle: result.resultTitle,
      levelLabel: result.resultLevel.levelBadgeText,
      rawScore: result.rawScore,
      isCompleted: true,
      completedAt: result.completedAt,
    );
  }

  factory SavedScreeningResult.fromFibroids(
      UterineFibroidAssessmentResult result) {
    return SavedScreeningResult(
      assessmentType: ScreeningAssessmentType.uterineFibroids,
      categoryTitle: result.resultTitle,
      levelLabel: result.resultLevel.levelBadgeText,
      rawScore: result.rawScore,
      isCompleted: true,
      completedAt: result.completedAt,
    );
  }

  /// Serializes this record for backend storage.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'assessment_type': assessmentType.name,
      'category_title': categoryTitle,
      'level_label': levelLabel,
      'raw_score': rawScore,
      'is_completed': isCompleted,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  /// Restores a record previously stored by [toJson].
  factory SavedScreeningResult.fromJson(Map<String, dynamic> json) {
    return SavedScreeningResult(
      assessmentType: ScreeningAssessmentType.values.firstWhere(
        (type) => type.name == json['assessment_type'],
        orElse: () => ScreeningAssessmentType.pcos,
      ),
      categoryTitle: json['category_title'] as String? ?? '',
      levelLabel: json['level_label'] as String? ?? '',
      rawScore: (json['raw_score'] as num?)?.toInt() ?? 0,
      isCompleted: json['is_completed'] as bool? ?? true,
      completedAt:
          DateTime.tryParse(json['completed_at'] as String? ?? '') ??
              DateTime.now(),
      userId: json['user_id'] as String? ?? '',
    );
  }
}
