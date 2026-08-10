import 'endometriosis_result_level.dart';

class EndometriosisAssessmentResult {
  final int rawScore;
  final EndometriosisResultLevel resultLevel;
  final String resultTitle;
  final String description;
  final String additionalText;
  final String nextStepText;
  final bool painCluster;
  final bool deepPelvicPainCluster;
  final bool bowelCluster;
  final bool urinaryCluster;
  final bool fertilityClinicalCluster;
  final List<String> contributingSymptoms;
  final List<String> highSignalSymptoms;
  final bool hasMedicalAttentionFlags;
  final String? medicalAttentionNotice;
  final String primaryCta;
  final String? secondaryCta;
  final Map<int, int> answers; // questionIndex -> optionIndex
  final DateTime completedAt;

  const EndometriosisAssessmentResult({
    required this.rawScore,
    required this.resultLevel,
    required this.resultTitle,
    required this.description,
    required this.additionalText,
    required this.nextStepText,
    required this.painCluster,
    required this.deepPelvicPainCluster,
    required this.bowelCluster,
    required this.urinaryCluster,
    required this.fertilityClinicalCluster,
    required this.contributingSymptoms,
    required this.highSignalSymptoms,
    required this.hasMedicalAttentionFlags,
    this.medicalAttentionNotice,
    required this.primaryCta,
    this.secondaryCta,
    required this.answers,
    required this.completedAt,
  });
}
