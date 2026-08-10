class EndometriosisQuestion {
  final String id;
  final int questionNumber;
  final String section;
  final String question;
  final List<String> options;
  final List<int> scores;
  final bool isScored;
  final Map<String, dynamic>? metadata;

  const EndometriosisQuestion({
    required this.id,
    required this.questionNumber,
    required this.section,
    required this.question,
    required this.options,
    required this.scores,
    this.isScored = true,
    this.metadata,
  });
}
