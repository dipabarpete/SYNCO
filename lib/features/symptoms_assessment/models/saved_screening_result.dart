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

/// A locally stored record of the latest completed screening result.
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

  const SavedScreeningResult({
    required this.assessmentType,
    required this.categoryTitle,
    required this.levelLabel,
    required this.rawScore,
    required this.isCompleted,
    required this.completedAt,
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
}
