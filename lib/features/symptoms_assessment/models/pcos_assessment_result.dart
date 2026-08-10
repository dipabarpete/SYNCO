import 'pcos_result_level.dart';

class PcosAssessmentResult {
  final int rawScore;
  final PcosResultLevel resultLevel;
  final String categoryTitle;
  final String categoryDescription;
  final String? categoryRecommendation;
  final String? categoryCta;
  final bool menstrualCluster;
  final bool androgenCluster;
  final bool metabolicCluster;
  final bool clinicalEvidenceCluster;
  final String menstrualStatus;
  final String androgenStatus;
  final String metabolicStatus;
  final String clinicalEvidenceStatus;
  final List<String> explanationBullets;
  final List<String> highSignalSymptoms;
  final List<String> lowerSpecificitySymptoms;
  final List<String> contributingCategories;
  final String nextStepText;
  final String primaryCta;
  final String? secondaryCta;
  final bool hasSpecialCaseNotice;
  final String? specialCaseNoticeText;
  final Map<int, int> answers; // questionIndex -> optionIndex
  final DateTime completedAt;

  const PcosAssessmentResult({
    required this.rawScore,
    required this.resultLevel,
    required this.categoryTitle,
    required this.categoryDescription,
    this.categoryRecommendation,
    this.categoryCta,
    required this.menstrualCluster,
    required this.androgenCluster,
    required this.metabolicCluster,
    required this.clinicalEvidenceCluster,
    required this.menstrualStatus,
    required this.androgenStatus,
    required this.metabolicStatus,
    required this.clinicalEvidenceStatus,
    required this.explanationBullets,
    required this.highSignalSymptoms,
    required this.lowerSpecificitySymptoms,
    required this.contributingCategories,
    required this.nextStepText,
    required this.primaryCta,
    this.secondaryCta,
    required this.hasSpecialCaseNotice,
    this.specialCaseNoticeText,
    required this.answers,
    required this.completedAt,
  });
}
