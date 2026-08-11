import 'fibroids_result_level.dart';

class UterineFibroidAttentionFlag {
  final String id;
  final String message;

  const UterineFibroidAttentionFlag({
    required this.id,
    required this.message,
  });
}

class UterineFibroidAssessmentResult {
  final int rawScore;
  final UterineFibroidResultLevel resultLevel;
  final String resultTitle;
  final String description;
  final String additionalText;
  final String nextStepText;
  final bool heavyBleedingCluster;
  final bool pelvicPressureCluster;
  final bool bladderBowelCluster;
  final bool anemiaAssociatedCluster;
  final bool fertilityClinicalCluster;
  final List<String> contributingSymptoms;
  final List<String> highSignalSymptoms;
  final List<UterineFibroidAttentionFlag> medicalAttentionFlags;
  final String primaryCta;
  final String? secondaryCta;
  final Map<int, int> answers; // questionIndex -> optionIndex
  final DateTime completedAt;

  const UterineFibroidAssessmentResult({
    required this.rawScore,
    required this.resultLevel,
    required this.resultTitle,
    required this.description,
    required this.additionalText,
    required this.nextStepText,
    required this.heavyBleedingCluster,
    required this.pelvicPressureCluster,
    required this.bladderBowelCluster,
    required this.anemiaAssociatedCluster,
    required this.fertilityClinicalCluster,
    required this.contributingSymptoms,
    required this.highSignalSymptoms,
    required this.medicalAttentionFlags,
    required this.primaryCta,
    this.secondaryCta,
    required this.answers,
    required this.completedAt,
  });

  bool get hasMedicalAttentionFlags => medicalAttentionFlags.isNotEmpty;

  bool get hasHeavyBleedingFlag =>
      medicalAttentionFlags.any((f) => f.id == 'heavyBleeding');

  bool get hasAnemiaFlag =>
      medicalAttentionFlags.any((f) => f.id == 'anemia');

  bool get hasExistingFibroidFlag =>
      medicalAttentionFlags.any((f) => f.id == 'existingFibroid');
}