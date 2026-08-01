enum KyraSender {
  user,
  kyra,
}

class KyraMessage {
  final String id;
  final KyraSender sender;
  final String text;
  final DateTime timestamp;
  final List<String>? actionButtons; // Suggested quick replies
  final String? labReportInsight; // Optional lab report analysis summary
  final String? foodRecommendation; // Optional food suggestion card

  KyraMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.actionButtons,
    this.labReportInsight,
    this.foodRecommendation,
  });
}
